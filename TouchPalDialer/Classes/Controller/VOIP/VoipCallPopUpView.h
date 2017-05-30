//
//  VoipCallPopUpView.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-13.
//
//

#import <UIKit/UIKit.h>
#import "CallLogDataModel.h"


#define VOIP_POPUP_VIEW_HEIGHT (266)
#define TEST_VOIP_POPUP_VIEW_HEIGHT (233)
#define MARGIN_TOP_OF_SETTING_LABEL (25)

#define CALL_BUTTON_HEIGHT (56)
#define MARGIN_BOTTOM_OF_FREE_CALL_BUTTON (14)
#define MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON (24)

#define POPUP_HEIGHT_ADAPT (TPScreenHeight()/640.0)
#define POPUP_VIEW_SCALE_RATIO (POPUP_HEIGHT_ADAPT > 1 ? 1 : POPUP_HEIGHT_ADAPT)

@protocol VoipCallPopUpViewDelegate <NSObject>
- (void)onClickFreeCallButton:(NSArray *)number;
- (void)onClickNormalCallButton;
- (void)onClickCancelButton;
- (void)onClickInviteButton;
@end


enum{
    VOIP_ENABLE = 0,
    VOIP_PRE_17 = 1,
    VOIP_XINJIANG = 2,
    VOIP_OVERSEA = 3,
    VOIP_LANDLINE = 4,
    VOIP_SERVICE = 5,
    VOIP_PASS = 6,
};

@interface VoipCallPopUpView : UIView
@property(nonatomic,assign) id<VoipCallPopUpViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame andCallLog:(CallLogDataModel*)callLog andType:(NSInteger)type;
- (id)initWithFrame:(CGRect)frame andTestCallName:(NSString *)name;
- (void)sendVoipButtonClickMessage;
@end
