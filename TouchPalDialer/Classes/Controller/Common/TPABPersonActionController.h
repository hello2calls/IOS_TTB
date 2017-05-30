//
//  TPABPersonActionController.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/7/12.
//
//

#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/CNContactViewController.h>
#import <ContactsUI/CNContactPickerViewController.h>

@protocol TPABPersonActionDelegate <NSObject>

@optional

- (void)doAfterAction:(ABRecordRef)person;
- (void)doAfterCancel;

@end

@interface TPABPersonActionController : NSObject<ABNewPersonViewControllerDelegate,
                                                 ABPeoplePickerNavigationControllerDelegate,
                                                 UIActionSheetDelegate,
                                                 CNContactViewControllerDelegate,
                                                 CNContactPickerDelegate,
UIAlertViewDelegate> {
    id <TPABPersonActionDelegate> target;
}

// singleton
+(TPABPersonActionController*) controller;

-(void)setTarget:(id)targetId;
-(void)addNewPersonPresentedBy:(UIViewController*)aViewController;
-(void)addNewPersonWithNumber:(NSString*)number
                  presentedBy:(UIViewController*)aViewController;
-(void)addNewPersonWithNumber:(NSString *)number
                         name:(NSString*)name
                  presentedBy:(UIViewController *)aViewController;
-(void)addToExistingContactWithNewNumber:(NSString *)number
                             presentedBy:(UIViewController*)aViewController;
-(void)chooseAddActionWithNewNumber:(NSString *)number
                     presentedBy:(UIViewController*)aViewController;
-(void)chooseAddActionWithNewNumber:(NSString *)number
                        presentedBy:(UIViewController*)aViewController
                  afterChooseAction:(void (^)())actionBlock;
-(void)chooseEditDeleteActionById:(NSInteger)personID
                      presentedBy:(UIViewController*)aViewController;
-(void)chooseEditDeleteActionById:(NSInteger)personID
                      presentedBy:(UIViewController*)aViewController
                afterChooseAction:(void (^)())actionBlock;
-(void)editPersonById:(NSInteger)personID
          presentedBy:(UIViewController*)aViewController;
-(void)editPersonByRecord:(ABRecordRef)person
                presentedBy:(UIViewController*)aViewController;
-(void)addPersonByRecord:(ABRecordRef)person
             presentedBy:(UIViewController*)aViewController;

@end
