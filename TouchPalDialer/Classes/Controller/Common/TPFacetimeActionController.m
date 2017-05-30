//
//  TPFacetimeActionController.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/8/12.
//
//

#import "TPFacetimeActionController.h"
#import "ContactCacheDataModel.h"
#import "Person.h"
#import "DefaultUIAlertViewHandler.h"
#import "NSString+PhoneNumber.h"

@interface TPFacetimeActionController()

@property (nonatomic,retain) NSArray *facetimeOptions;

@end

static TPFacetimeActionController *instance;

@implementation TPFacetimeActionController
@synthesize facetimeOptions = facetimeOptions_;

+ (void)initialize{
    instance = [[TPFacetimeActionController alloc]init];
}

#pragma mark class methods
+(TPFacetimeActionController*) controller{
    return instance;
}

#pragma mark public methods
-(void)chooseFacetimeActionWithNumbersAndEmails:(NSArray*)numbersAndEmails
                                    presentedBy:(UIViewController*)aViewController
{
    if (numbersAndEmails == nil || [numbersAndEmails count] == 0) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"contact_info_no_facetime", "") message:nil onlyOkButtonActionBlock:nil];
		return;
	}
    self.facetimeOptions = numbersAndEmails;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = NSLocalizedString(@"FaceTime", @"");
    int count = [numbersAndEmails count];
	for (int i = 0; i < count; i++) {
		[actionSheet addButtonWithTitle:[numbersAndEmails objectAtIndex:i]];
	}
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = count;
    actionSheet.delegate = self;
	[actionSheet showInView:aViewController.view];
}

-(void)chooseFacetimeActionByPersonId:(NSInteger)personId
                          presentedBy:(UIViewController *)aViewController
{
    if (personId <= 0) {
        return;
    }
    
    NSMutableArray *options = [NSMutableArray arrayWithCapacity:2];
    
    // Phone Numbers
    NSArray *phoneNumbers = [Person getPhonesByRecordID:personId];
    int phoneNumbersCount = [phoneNumbers count];
    for (int i = 0; i < phoneNumbersCount; i++) {
        LabelDataModel *label_model = [phoneNumbers objectAtIndex:i];
        NSString *phone_str = [(NSString *)label_model.labelValue digitNumber];
        [options addObject:phone_str];
    }
    
    // Emails
    NSArray *emails = [Person getEmailsByRecordID:personId];
    int emailsCount = [emails count];
    for (int i = 0; i < emailsCount; i++) {
        LabelDataModel *emailModel = [emails objectAtIndex:i];
        NSString *email = (NSString *)emailModel.labelValue;
        [options addObject:email];
    }
    
    [self chooseFacetimeActionWithNumbersAndEmails:options presentedBy:aViewController];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    int count = [self.facetimeOptions count];
    if (buttonIndex < count) {
        NSString *number = [self.facetimeOptions objectAtIndex:buttonIndex];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"facetime://%@",number]];
        [[UIApplication sharedApplication] openURL:url];
    }
    actionSheet.delegate = nil;
}

@end
