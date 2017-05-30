//
//  RemoveCallsCommand.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "OperationCommandBase.h"
#import "CooTekPopUpSheet.h"

@interface RemoveCallsCommand : OperationCommandBase<CooTekPopUpSheetDelegate>
+ (NSArray *)getTheFirstANDLastCallTimeWithPersonID:(int) personId orPhoneNumber:(NSString *)phoneNumber;
@end
