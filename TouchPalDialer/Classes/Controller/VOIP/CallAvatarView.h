//
//  CallAvatarView.h
//  TouchPalDialer
//
//  Created by siyi on 16/4/20.
//
//

#ifndef CallAvatarView_h
#define CallAvatarView_h

typedef NS_ENUM(NSInteger, UserType) {
    ME_PLAIN,
    ME_VIP,
    OTHER_UNKNOWN,
    OTHER_OVERSEA,
    OTHER_INACTIVE,
    OTHER_ACTIVE,
    OTHTER_CALLING_ACTIVE,
};

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CallViewController.h"

#define AVATAR_DIAMETER (60)


@interface CallAvatarView : UIView
- (instancetype) initWithCallMode:(CallMode)callMode
                           number:(NSString *)number;

@property (nonatomic) UIButton *avatarView;
@property (nonatomic) UILabel *decorLabel;
@property (nonatomic, assign) BOOL isMe;

@property (nonatomic, assign) CallMode callMode;
@property (nonatomic) NSString *number;
@property (nonatomic, assign) UserType userType;

- (void) startFadding;
- (void) stopFadding;

@end


@interface CallAvatarGroup : UIView
- (instancetype) initWithCallMode:(CallMode)callMode callerNumber:(NSString *)callerNumber calleeNumber:(NSString *)calleeNumber;
- (instancetype) initWithCallMode:(CallMode)callMode callerNumber:(NSString *)callerNumber otherNumArr:(NSArray *)otherNumArr;

@property (nonatomic) CallAvatarView *callerView;
@property (nonatomic) CallAvatarView *thisAvatarView;
@property (nonatomic) CallAvatarView *calleeView;
@property (nonatomic) CallAvatarView *thatAvatarView;
@property (nonatomic) UILabel *statusLabel;
@property (nonatomic) UIColor *textColor;

@property (nonatomic) NSString *statusString;
@property (nonatomic) CallAvatarView *otherAvatarView;

- (void) startMovingArrow;
- (void) stopMovingArrow;

- (void) startFadding;
- (void) stopFadding;

- (void) setStatusString:(NSString *)statusString statusColor:(UIColor *)statusColor;
@end

#endif /* CallAvatarView_h */
