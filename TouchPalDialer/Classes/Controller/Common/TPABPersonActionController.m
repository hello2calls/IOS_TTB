 //
//  TPABPersonActionController.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/7/12.
//
//

#import "TPABPersonActionController.h"
#import "UINavigationController+TP.h"
#import "TPAddressBookWrapper.h"
#import "Person.h"
#import "PersonDBA.h"
#import "SyncContactInApp.h"
#import "BasicUtil.h"
#import "CootekNotifications.h"
#import "FunctionUtility.h"
#import "CallerIDModel.h"
#import "TPDialerResourceManager.h"

#define ACTION_SHEET_NEW_NUMBER_TAG 4749301
#define ACTION_SHEET_EDIT_DELETE_TAG 4749302

static TPABPersonActionController *instance_ = nil;

@interface TPABPersonActionController()
@property(nonatomic,copy) void(^afterChooseAction)(void);
@property(nonatomic,retain)NSString *addingNumber;
@property(nonatomic,assign)NSInteger editingDeletingPersonId;
@property(nonatomic,retain)UIViewController *presentingViewController;
- (void)refreshAfterCreatingOrEditingPerson:(ABRecordRef)person;
- (void)cancelPressed;
@end

@implementation TPABPersonActionController
@synthesize afterChooseAction;
@synthesize addingNumber = addingNumber_;
@synthesize editingDeletingPersonId = editingDeletingPersonId_;
@synthesize presentingViewController = presentingViewController_;

#pragma mark singleton lifecycle
+ (TPABPersonActionController *)controller
{
    return instance_;
}

+ (void)initialize
{
    instance_ = [[self alloc] init];
}

#pragma mark public methods
-(void)addNewPersonPresentedBy:(UIViewController *)aViewController
{
    [self addNewPersonWithNumber:nil name:nil presentedBy:aViewController];
}

-(void)addNewPersonWithNumber:(NSString *)number
                  presentedBy:(UIViewController *)aViewController
{
    [self addNewPersonWithNumber:number name:nil presentedBy:aViewController];
}

-(void)addNewPersonWithNumber:(NSString *)number
                         name:(NSString *)name
                  presentedBy:(UIViewController *)aViewController
{
    self.presentingViewController = aViewController;
    if (!IOS9) {
    
        ABRecordRef aRecord = ABPersonCreate();
        double version = [[UIDevice currentDevice].systemVersion doubleValue];
        if (version < 8.0f) {
            ABRecordSetValue(aRecord, kABPersonNoteProperty, (CFStringRef)@" ", NULL);
            ABRecordSetValue(aRecord, kABPersonJobTitleProperty, (CFStringRef)@"", NULL);
        }
        
        if (number && [number length] != 0) {
            ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(number), kABPersonPhoneMobileLabel, NULL);
            ABRecordSetValue(aRecord, kABPersonPhoneProperty, multi, NULL);
            SAFE_CFRELEASE_NULL(multi);
        }
        if (name && [name length] != 0) {
            ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(name), NULL);
        }
        
        ABNewPersonViewController *pickerNew = [[ABNewPersonViewController alloc] init];
        pickerNew.newPersonViewDelegate = self;
        pickerNew.addressBook=[TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        pickerNew.displayedPerson = aRecord;
        
        UINavigationController *tmp_nav = [[UINavigationController alloc] initWithRootViewController:pickerNew];
//        [tmp_nav configureHeaderSkin];
       [FunctionUtility setStatusBarStyleToDefault:YES];
        [self.presentingViewController presentViewController:tmp_nav animated:YES completion:^(){
            
        }];
        
        
        CFRelease(aRecord);
    } else {
        
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        if (number && [number length] != 0) {
            CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:number]];
            contact.phoneNumbers = @[phoneNumber];
        }
        if (name && [name length] != 0) {
            contact.givenName = name;
        }
        CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
        controller.delegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        [FunctionUtility setStatusBarStyleToDefault:YES];
        [self.presentingViewController presentViewController:navigation animated:YES completion:^{
            
        }];
    }
}

-(void)addToExistingContactWithNewNumber:(NSString *)number
                             presentedBy:(UIViewController*)aViewController{
    if (!number || [number length] == 0) {
        return;
    }
    self.addingNumber = number;
    self.presentingViewController = aViewController;
    if (!IOS9) {
        ABPeoplePickerNavigationController *peoplePicker =  [[ABPeoplePickerNavigationController alloc] init];
        peoplePicker.addressBook=[TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        peoplePicker.peoplePickerDelegate = self;
//        [peoplePicker configureHeaderSkin];
        
        [self.presentingViewController presentViewController:peoplePicker animated:YES completion:^(){}];
    } else {
        CNContactPickerViewController *controller = [[CNContactPickerViewController alloc] init];
        controller.delegate = self;
        [self.presentingViewController presentViewController:controller animated:YES completion:^{}];
    }
}

-(void)chooseAddActionWithNewNumber:(NSString *)number
                        presentedBy:(UIViewController*)aViewController
                afterChooseAction:(void (^)())actionBlock
{
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
    self.afterChooseAction = actionBlock;
    
    if (!number || [number length] == 0) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_HIDE_PHONE_PAD object:nil];
    UIActionSheet* actionSheet =
    [[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                  destructiveButtonTitle:nil
                       otherButtonTitles:NSLocalizedString(@"Create new contact", @""),
     NSLocalizedString(@"Add to existing contact", @""),nil];
    
    actionSheet.tag = ACTION_SHEET_NEW_NUMBER_TAG;
    self.addingNumber = number;
    self.presentingViewController = aViewController;
    [actionSheet showInView:self.presentingViewController.view]; //topViewController
}

-(void)chooseAddActionWithNewNumber:(NSString *)number
                        presentedBy:(UIViewController*)aViewController
{
    [self chooseAddActionWithNewNumber:number presentedBy:aViewController afterChooseAction:nil];
}

-(void)chooseEditDeleteActionById:(NSInteger)personID
                      presentedBy:(UIViewController*)aViewController
                afterChooseAction:(void (^)())actionBlock
{
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
    self.afterChooseAction = actionBlock;
    //[[NSNotificationCenter defaultCenter] postNotificationName:N_HIDE_PHONE_PAD object:nil];
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = self;
    [sheet addButtonWithTitle:NSLocalizedString(@"Edit contact", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"Delete contact", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    sheet.destructiveButtonIndex = 1;
    sheet.cancelButtonIndex = 2;
	sheet.tag = ACTION_SHEET_EDIT_DELETE_TAG;
    self.editingDeletingPersonId = personID;
    self.presentingViewController = aViewController;
	[sheet showInView:self.presentingViewController.view];
}

-(void)chooseEditDeleteActionById:(NSInteger)personID
                      presentedBy:(UIViewController*)aViewController
{
    [self chooseEditDeleteActionById:personID presentedBy:aViewController afterChooseAction:nil];
}


-(void)editPersonById:(NSInteger)personID
          presentedBy:(UIViewController*)aViewController
{
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
	if (personID && [Person isExistsPerson:personID]) {
        if (!IOS9) {
            [self editPersonByRecord:[Person recordRefByPersonID:personID]
                         presentedBy:aViewController];
        } else {
            [self editCNPersonByRecord:personID
                         presentedBy:aViewController];
        }
        
	}
}

-(void)editCNPersonByRecord:(NSInteger)personID
              presentedBy:(UIViewController*)aViewController
{
    CNContact *contact = [PersonDBA getContactByPersonID:personID];
    [self popIos9ContactViewController:contact andTitle:NSLocalizedString(@"Edit contact",@"") presentedBy:aViewController];
}

- (void)popIos9ContactViewController:(CNContact*)contact andTitle:(NSString*)title presentedBy:(UIViewController*)aViewController{
    CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
    controller.delegate = self;
    controller.title = title;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.presentingViewController = aViewController;
    [FunctionUtility setStatusBarStyleToDefault:YES];
    [self.presentingViewController presentViewController:navigation animated:YES completion:^(){}];
}

-(void)editPersonByRecord:(ABRecordRef)person
              presentedBy:(UIViewController*)aViewController
{
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self ;
    
    picker.displayedPerson = person;
    UIBarButtonItem *leftBut = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel",@"")
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelPressed)];
    //这部分可以适配皮肤添加颜色。。。
//    leftBut.tintColor = [UIColor whiteColor];
//    picker.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    picker.navigationItem.leftBarButtonItem = leftBut;
    picker.navigationItem.title = NSLocalizedString(@"Edit contact",@"");
    picker.addressBook=[TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
       
    UINavigationController *tmp_nav = [[UINavigationController alloc] initWithRootViewController:picker];
//    [tmp_nav configureHeaderSkin];
    
    self.presentingViewController = aViewController;
    [FunctionUtility setStatusBarStyleToDefault:YES];
    [self.presentingViewController presentViewController:tmp_nav animated:YES completion:^(){}];
}


-(void)addPersonByRecord:(ABRecordRef)person
              presentedBy:(UIViewController*)aViewController
{
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self ;
    
    picker.displayedPerson = person;
    UIBarButtonItem *leftBut = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel",@"")
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelPressed)];
    //这部分可以适配皮肤添加颜色。。。
    //    leftBut.tintColor = [UIColor whiteColor];
    //    picker.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    picker.navigationItem.leftBarButtonItem = leftBut;
    picker.navigationItem.title = NSLocalizedString(@"Create new contact",@"");
    picker.addressBook=[TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    
    UINavigationController *tmp_nav = [[UINavigationController alloc] initWithRootViewController:picker];
    //    [tmp_nav configureHeaderSkin];
    
    self.presentingViewController = aViewController;
    [FunctionUtility setStatusBarStyleToDefault:YES];
    [self.presentingViewController presentViewController:tmp_nav animated:YES completion:^(){}];
}


-(void)refreshAfterCreatingOrEditingPerson:(ABRecordRef)person{
    
    if (person != nil) {
        ABAddressBookRef addressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        CFStringRef note = ABRecordCopyValue(person, kABPersonNoteProperty);
        NSString *noteString = (__bridge NSString *)note;
        noteString = [noteString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (noteString && noteString.length != 0 ) {
            ABRecordSetValue(person, kABPersonNoteProperty, (__bridge CFStringRef)noteString, NULL);
            ABAddressBookAddRecord(addressBook, person, NULL);
        }
        if (note) {
            CFRelease(note);
        }
        ABAddressBookSave(addressBook, NULL);
		[SyncContactInApp editPerson:[PersonDBA contactCacheDataModelByRecord:person]];
	} else {
        ABAddressBookRef addressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        ABAddressBookRevert(addressBook);
    }
}

- (void)refreshAfterCreatingOrEditingContact:(CNContact*)contact{
    if (contact) {
        [FunctionUtility updateStatusBarStyle];
        [SyncContactInApp editPerson:[PersonDBA contactCacheDataModelByContact:contact]];
    }
}

- (void)cancelPressed {
    [self refreshAfterCreatingOrEditingPerson:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == ACTION_SHEET_NEW_NUMBER_TAG) {
        if (!self.addingNumber || [self.addingNumber length] == 0) {
            return;
        }
        if (buttonIndex == 0) {
            CallerIDInfoModel *info = [CallerIDModel  queryCallerIDByNumberWithOutNotification:self.addingNumber];
            NSString *name = info.name;
            [self addNewPersonWithNumber:self.addingNumber name:name presentedBy:self.presentingViewController];
        } else if (buttonIndex == 1) {
            [self addToExistingContactWithNewNumber:self.addingNumber presentedBy:self.presentingViewController];
        }
    } else if (actionSheet.tag == ACTION_SHEET_EDIT_DELETE_TAG) {
        if (buttonIndex == 0) {
            [self editPersonById:self.editingDeletingPersonId presentedBy:self.presentingViewController];
		} else if (buttonIndex == 1) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm to delete?",@"")
															message:nil
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel")
												  otherButtonTitles:NSLocalizedString(@"Ok",@"Ok" ), nil];
			[alert show];
		}
    }
    
    if (afterChooseAction) {
        afterChooseAction();
        self.afterChooseAction = nil;
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:N_RESTORE_PHONE_PAD object:nil];
}

#pragma mark ABNewPersonDelegate
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController
       didCompleteWithNewPerson:(ABRecordRef)person;
{
    [self refreshAfterCreatingOrEditingPerson:person];
    if  (target != nil) {
        if (person != nil) {
            [target doAfterAction:person];
        } else  {
            [target doAfterCancel];
        }
        target = nil;
    }

     [FunctionUtility setStatusBarStyleToDefault:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
     shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [peoplePicker dismissViewControllerAnimated:NO completion:^(){}];
    [self popEidtPerson:person];
    return NO;
}

#pragma CNContactViewControllerDelegate
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact {
    [self.presentingViewController dismissViewControllerAnimated:NO completion:^(){}];
    NSInteger personID = [[contact valueForKey:@"iOSLegacyIdentifier"] integerValue];
    ABRecordRef person = [Person recordRefByPersonID:personID];
    if  (target != nil) {
        if (person != nil) {
            [target doAfterAction:person];
        } else  {
            [target doAfterCancel];
        }
        target = nil;
    }

    [FunctionUtility setAppHeaderStyle];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self refreshAfterCreatingOrEditingContact:contact];
    });
    
}

#pragma CNContactPickerDelegate
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    [picker dismissViewControllerAnimated:NO completion:^(){}];
    CNMutableContact *mutableContact = [contact mutableCopy];
    [self popEidtContact:mutableContact];
}

// should not be called.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:^(){}];
}

-(void)setTarget:(id)targetId
{
    target = targetId;
}

//avaliable for ios8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person {
    [peoplePicker dismissViewControllerAnimated:NO completion:^(){}];
    [self popEidtPerson:person];
}

//avaliable for ios8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
}

- (void)popEidtPerson:(ABRecordRef)person {
    ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    ABRecordRef tempPerson = ABAddressBookGetPersonWithRecordID(ab, ABRecordGetRecordID(person));
    
    if (self.addingNumber && [self.addingNumber length] != 0) {
        ABMultiValueRef multiReadFrom = ABRecordCopyValue(tempPerson, kABPersonPhoneProperty);
        ABMutableMultiValueRef multiWriteTo = ABMultiValueCreateMutable(kABStringPropertyType);
        for (CFIndex i = 0; i < ABMultiValueGetCount(multiReadFrom); i++) {
            CFStringRef phoneLabel = ABMultiValueCopyLabelAtIndex(multiReadFrom, i);
            CFStringRef phoneNumber = ABMultiValueCopyValueAtIndex(multiReadFrom, i);
            ABMultiValueAddValueAndLabel(multiWriteTo, phoneNumber, phoneLabel, NULL);
            SAFE_CFRELEASE_NULL(phoneLabel);
            SAFE_CFRELEASE_NULL(phoneNumber);
        }
        ABMultiValueAddValueAndLabel(multiWriteTo,(__bridge CFStringRef)self.addingNumber, kABOtherLabel, NULL);
        ABRecordSetValue(tempPerson, kABPersonPhoneProperty, multiWriteTo, NULL);
        SAFE_CFRELEASE_NULL(multiReadFrom);
        SAFE_CFRELEASE_NULL(multiWriteTo);
        [self editPersonByRecord:tempPerson presentedBy:self.presentingViewController];
        
    }
}

- (void)popEidtContact:(CNMutableContact*)contact {
    
    if (self.addingNumber && [self.addingNumber length] != 0) {
        CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:self.addingNumber]];
        NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithArray:contact.phoneNumbers];
        [phoneNumbers addObject:phoneNumber];
        contact.phoneNumbers = phoneNumbers;
        [self popIos9ContactViewController:contact andTitle:NSLocalizedString(@"Edit contact",@"") presentedBy:self.presentingViewController];
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (buttonIndex==1) {
        if ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (NSInteger)(0.01*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [Person deletePersonByRecordID:self.editingDeletingPersonId];
                [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                                    object:nil
                                                                  userInfo:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Person deletePersonByRecordID:self.editingDeletingPersonId];
                [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                                object:nil
                                                              userInfo:nil];
            });
        }
	}
}

@end
