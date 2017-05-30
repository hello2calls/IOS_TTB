//
//  TPClearCallLogActionController.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/8/12.
//
//

#import "TPClearCallLogActionController.h"
#import "WhereDataModel.h"
#import "DataBaseModel.h"
#import "CallLog.h"
#import "PhoneNumber.h"

#define ALERT_VIEW_DELETE_KNOWN_CALLLOG_TAG  2263834
#define ALERT_VIEW_DELETE_UNKNOWN_CALLLOG_TAG  2263835

@interface TPClearCallLogActionController()
@property (nonatomic,assign) NSInteger personId;
@property (nonatomic,retain) NSString *phoneNumber;

-(UIAlertView*) uiAlertView;
@end

static TPClearCallLogActionController *instance;

@implementation TPClearCallLogActionController
@synthesize personId = personId_;
@synthesize phoneNumber = phoneNumber_;

+ (void)initialize{
    instance = [[TPClearCallLogActionController alloc]init];
}

#pragma mark class methods
+(TPClearCallLogActionController*) controller{
    return instance;
}

#pragma mark private methods
-(UIAlertView *)uiAlertView
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm to remove all these call logs?",@"")
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel")
                                           otherButtonTitles:NSLocalizedString(@"Ok",@"Ok" ), nil];
    
    return alert;
}

#pragma mark public methods
-(void) clearCallLogOfKnownContactByPersonId:(NSInteger)personId{
    if (personId<=0) {
        return;
    }
    self.personId = personId;
    
    UIAlertView *alert = [self uiAlertView];
    alert.tag = ALERT_VIEW_DELETE_KNOWN_CALLLOG_TAG;
    [alert show];
}

-(void) clearCallLogOfUnknownContactByPhoneNumber:(NSString*)phoneNumber{
    if (phoneNumber == nil || [phoneNumber length] == 0) {
        return;
    }
    self.phoneNumber = phoneNumber;
    UIAlertView *alert = [self uiAlertView];
    alert.tag = ALERT_VIEW_DELETE_UNKNOWN_CALLLOG_TAG;
    [alert show];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (buttonIndex==1) {
		if (alertView.tag == ALERT_VIEW_DELETE_KNOWN_CALLLOG_TAG) {
			WhereDataModel *condition = [[WhereDataModel alloc] init];
			condition.fieldKey = [DataBaseModel getKWhereKeyPersonID];
			condition.oper = [DataBaseModel getKWhereOperationEqual];
			condition.fieldValue = [NSString stringWithFormat:@"%d",self.personId];
			NSArray *conditon_arr = [NSArray arrayWithObject:condition];
			[CallLog deleteCalllogByConditional:conditon_arr];
		}else if (alertView.tag == ALERT_VIEW_DELETE_UNKNOWN_CALLLOG_TAG){
			WhereDataModel *condition_1 = [[WhereDataModel alloc] init];
			condition_1.fieldKey = [DataBaseModel getKWhereKeyPersonID];
			condition_1.oper = [DataBaseModel getKWhereOperationEqual];
			condition_1.fieldValue = [NSString stringWithFormat:@"%d",-1];
			
			WhereDataModel *condition_2 = [[WhereDataModel alloc] init];
			condition_2.fieldKey = [DataBaseModel getKWhereKeyPhoneNumber];
            
            if ([[[PhoneNumber sharedInstance] getOriginalNumber:self.phoneNumber] length] >= 7) {
                condition_2.oper = [DataBaseModel getKWhereOperationLike];
                condition_2.fieldValue = [[PhoneNumber sharedInstance] getOriginalNumber:self.phoneNumber];
            } else {
                condition_2.oper = [DataBaseModel getKWhereOperationEqual];
                condition_2.fieldValue = [DataBaseModel getFormatNumber:self.phoneNumber];
            }

			NSArray *conditon_arr = [NSArray arrayWithObjects:condition_1, condition_2, nil];
			[CallLog deleteCalllogByConditional:conditon_arr];
		}
	}
    alertView.delegate = nil;
}

@end
