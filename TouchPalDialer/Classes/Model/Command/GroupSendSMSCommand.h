//
//  SendSMSCommand.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "GroupOperationCommandBase.h"
#import "CooTekPopUpSheet.h"
#import "TPWebShareController.h"

@interface GroupSendSMSCommand : GroupOperationCommandBase<CooTekPopUpSheetDelegate, CommonMultiSelectProtocol, SelectViewProtocalDelegate>


- (void)onClickedWithMessage:(NSString *)message resultCallback:(ShareResultCallback)resultBack;
@end
