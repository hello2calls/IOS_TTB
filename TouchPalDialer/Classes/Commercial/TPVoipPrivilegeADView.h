//
//  TPVoipPrivilegeADView.h
//  TouchPalDialer
//
//  Created by siyi on 16/1/12.
//
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HangupCommercialModel.h"

#ifndef TPVoipPrivilegeADView_h
#define TPVoipPrivilegeADView_h

#define VOIP_VIP_AD @"voip_vip_ad"

#define CARD_TYPE_VOIP_VIP @"VOIP-VIP"

//max delay for receiving the push noti in seconds
#define VOIP_VIP_LIMIT_MAX_DELAY (2 * 60)

@protocol TPVoipPrivilegeADViewDelegate
- (void) cancelTask;
- (void) confirmTask;
@end

@interface TPVoipPrivilegeADView : UIView <TPVoipPrivilegeADViewDelegate>
- (instancetype) initWithFrame:(CGRect)frame data:(HangupCommercialModel*) modelData callType:(NSString *) callType;
- (instancetype) initWithModelData:(HangupCommercialModel *) modelData callType:(NSString *) callType;
- (instancetype) initWithModelData:(HangupCommercialModel *) modelData;
- (void) showInView:(UIView* ) view;
- (void) showInAppWindow;
- (void) dismiss;

@property (nonatomic) id<TPVoipPrivilegeADViewDelegate> delegate;
@end



#endif /* TPVoipPrivilegeADView_h */
