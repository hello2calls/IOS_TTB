//
//  ViewModelGenerator.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/11.
//
//
#import <Foundation/Foundation.h>
#import "CallAvatarView.h"
@interface HangupModel : NSObject
@property (nonatomic, assign) int callDur;
@property (nonatomic, assign) int errorCode;
@property (nonatomic, assign) BOOL isPal;
@property (nonatomic, assign) BOOL isIncomingCall;
@property (nonatomic, assign) int remainMinute;
@property (nonatomic, assign) BOOL isBackCall;
@property (nonatomic, assign) int errorCompansate;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) BOOL usingNewBackCallMode;
@property (nonatomic, assign) BOOL isp2pCall;
@property (nonatomic, assign) UserType userType;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) BOOL prepare;
@end

@interface HeaderViewModel : NSObject
@property (nonatomic, strong)NSAttributedString *mainAttrString;
@property (nonatomic, strong)NSAttributedString *altAttrString;
@property (nonatomic, strong)UIColor *backgroundColor;
@property (nonatomic, strong)UIColor *mainTextColor;
@property (nonatomic, strong)UIColor *altTextColor;
@property (nonatomic, strong)NSString *mainText;
@property (nonatomic, strong)NSString *altText;
@end

@interface MiddleViewModel : NSObject
@property (nonatomic, assign) BOOL highlightText;
@property (nonatomic, assign) BOOL isError;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *altText;
@end

typedef enum{
    NO_LOADING,
    LOADING,
    LOADING_DONE,
    LOADING_DONE_HIDE,
}MainButtonState;

@interface MainActionViewModel : NSObject
@property (nonatomic, strong) NSString *mainButtonTitle;
@property (nonatomic, copy) void(^onMainButtonClick)(void);
@property (nonatomic, assign) MainButtonState buttonState;
@property (nonatomic, assign) BOOL lightBg;
@property (nonatomic, strong) NSString *spitGuideText;
@property (nonatomic, strong) NSString *redialGuideText;
@property (nonatomic, copy) void(^onRedialButtonClick)(void);
@property (nonatomic, copy) void(^onSpitButtonClick)(void);
@property (nonatomic, copy) void(^onHideButtonClick)(void);
@end

@protocol ModelChangeDelegate
- (void)close;
- (void)closeAnimate;
@end

@interface HangupViewModelGenerator : NSObject
@property(nonatomic,retain)HangupModel *hangupModel;
- (id)initWithHangupModel:(HangupModel *)hangupModel andDelegate:(id<ModelChangeDelegate>)delegate;
- (id)initWithshowBackCallOrFeatureProviderHangupModel:(HangupModel *)hangupModel andDelegate:(id<ModelChangeDelegate>)delegate;
- (id)initTocheckVoipErrorWithHangupModel:(HangupModel *)hangupModel;

- (HeaderViewModel *)getHeaderModel;

- (MiddleViewModel *)getMiddleModel;

- (MainActionViewModel *)getMainActionViewModel;

- (UIImage *)getBgImage;

- (NSString *)getErrorCode;

- (UIColor *)bottomCoverColor;
- (id ) getModelGenerator; // can not use `BaseHangupModelGenerator` as the return type for circular dependency
@end
