//
//  VoipInvitationCodeView.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-14.
//
//

#import <UIKit/UIKit.h>

@interface VoipInvitationCodeView : UIView
#define REDEEM_ISSUE_FAILED 4100
#define REDEEM_EXCHANGED 4101
#define REDEEM_EXPIRED 4102
#define REDEEM_NOT_EXIST 4103
#define REDEEM_SERVICE_BAD 4104
@property (nonatomic, assign) BOOL useOldInterface;
@end
