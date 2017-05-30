//
//  CallAvatarView.m
//  TouchPalDialer
//
//  Created by siyi on 16/4/20.
//
//

#import "CallAvatarView.h"
#import "UILabel+DynamicHeight.h"
#import "UILabel+TPHelper.h"
#import "TPDialerResourceManager.h"
#import "NumberPersonMappingModel.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "UserDefaultsManager.h"
#import "NSString+TPHandleNil.h"
#import "UILabel+DynamicHeight.h"
#import "CallProceedingDisplay.h"
#import "PersonalCenterUtility.h"
#import "PhoneNumber.h"
#import "TPDLib.h"
#import <Masonry.h>
#import <BlocksKit.h>

#import "FunctionUtility.h"
#import "TPDFamilyInfo.h"
@implementation CallAvatarView {
    BOOL _animationStopped;
    BOOL _isReigstered;
    BOOL _isActive;
    BOOL _isFadding;
    
    NSInteger _colorIndex;
}

- (instancetype) initWithCallMode:(CallMode)callMode
                           number:(NSString *)number {
    
    CGRect frame = CGRectMake(0, 0, AVATAR_DIAMETER, AVATAR_DIAMETER);
    self = [super initWithFrame:frame];
    if (self) {
        _callMode = callMode;
        _number = number;
        _colorIndex = 0;
        
        _animationStopped = NO;
        _isReigstered = NO;
        _isActive = YES;
        _isFadding = NO;
        
        // alloc
        _avatarView = [[UIButton alloc] initWithFrame:frame];
        _avatarView.layer.cornerRadius = _avatarView.frame.size.width / 2;
        _avatarView.clipsToBounds = YES;
        _avatarView.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30];
        _avatarView.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        _avatarView.backgroundColor = [UIColor clearColor];
        _avatarView.layer.borderColor = [UIColor clearColor].CGColor;
        _avatarView.layer.borderWidth = 1;
        
        UIFont *font = [UIFont fontWithName:@"iPhoneIcon2" size:20];
        _decorLabel = [[UILabel alloc] initWithTitle:@"S" font:font isFillContentSize:YES];
        _decorLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_yellow_700"];
        _decorLabel.backgroundColor = [UIColor clearColor];
        _decorLabel.hidden = YES;
        [_decorLabel adjustSizeByFillContent];
        _decorLabel.frame = CGRectMake(
                        AVATAR_DIAMETER - _decorLabel.frame.size.width / 2,
                        AVATAR_DIAMETER - _decorLabel.frame.size.height,
                        _decorLabel.frame.size.width,
                        _decorLabel.frame.size.height);
        
        // settings
        [self setCallMode:callMode];
        
        // view tree
        [self addSubview:_avatarView];
        [self addSubview:_decorLabel];
        
    }
    return self;
}

- (void) setCallMode:(CallMode)callMode {
    _callMode = callMode;
    
    NSString *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:nil];
    if (callMode == CallModeTestType) {
        _isMe = ![self.number isEqualToString:NSLocalizedString(@"touchpal_test_number", @"触宝测试专线")];
    } else {
        _isMe = (accountName != nil) &&  [self.number isEqualToString:accountName];
    }
    
    if (_isMe) {
        // it is me
        _animationStopped = YES;
        NSString *userPhotoName = [UserDefaultsManager stringForKey:PERSON_PROFILE_URL];
        if ([NSString isNilOrEmpty:userPhotoName]) {
            int userType = -1;
            if (callMode == CallModeTestType) {
                userType = OTHER_INACTIVE;
            } else {
                userType = OTHER_ACTIVE;
            }
            [self setUserType:userType];
        } else {
            [self setAvatarText:userPhotoName borderColorString:@"" backgroundColorString:@""];
        }
        if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]) {
            _decorLabel.hidden = NO;
        }
    } else {
        // the other
        if (callMode == CallModeTestType) {
            [self setUserType:OTHER_ACTIVE];
        } else {
            [self setUserType:OTHER_UNKNOWN];
        }
        _decorLabel.hidden = YES;
    }
}

- (void) setAcitve:(BOOL)isActive isRegistered:(BOOL)registered {
    if (!isActive) {
        [self setAvatarText:@"I" borderColorString:@"tp_color_white_transparency_500" backgroundColorString:@"tp_color_grey_500"];
        
    } else if (registered) {
        [self setAvatarText:@"I" borderColorString:@"tp_white" backgroundColorString:@"tp_color_light_blue_500"];
    }
}

- (void) setAvatarText:(NSString *)text borderColorString:(NSString *)bordercolorStyle backgroundColorString:(NSString *)bgColorStyle {
    if (!_avatarView) {
        return;
    }
    if ([NSString isNilOrEmpty:text]) {
        [_avatarView setBackgroundImage:nil forState:UIControlStateNormal];
        
    } else {
        UIImage *userPhoto = [PersonalCenterUtility getHeadViewPhotoWithName:text];
        if (_isMe && userPhoto != nil) {
            [_avatarView setBackgroundImage:userPhoto forState:UIControlStateNormal];
        } else {
            _avatarView.alpha = 0.5;
            [_avatarView setTitle:text forState:UIControlStateNormal];
        }
    }
    
    if ([NSString isNilOrEmpty:bgColorStyle]) {
        _avatarView.backgroundColor = [UIColor clearColor];
    } else {
        _avatarView.backgroundColor = [TPDialerResourceManager getColorForStyle:bgColorStyle];
    }
    
    if ([NSString isNilOrEmpty:bordercolorStyle]) {
        _avatarView.layer.borderColor = [UIColor clearColor].CGColor;
    } else {
        _avatarView.layer.borderColor = [TPDialerResourceManager getColorForStyle:bordercolorStyle].CGColor;
    }
}

- (void) setUserType:(UserType)userType{
    [[TPDFamilyInfo familyInfoSignal] subscribeNext:^(id x) {
        TPDFamilyInfo* f = x;
        if([f isFamilyNumber:_number]){
            _avatarView.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:30];
            [self setAvatarText:@"s" borderColorString:@"tp_color_white" backgroundColorString:@"0xfc5c8d"];
            return;
        }
        
    }];
    switch (userType) {
        case OTHER_INACTIVE: {
            // 不活跃用户
            [self setAvatarText:@"I" borderColorString:@"tp_color_white_transparency_500" backgroundColorString:@"tp_color_grey_500"];
            break;
        }
        case OTHER_ACTIVE: {
            // 触宝好友
            [self setAvatarText:@"I" borderColorString:@"tp_color_white" backgroundColorString:@"tp_color_blue_500"];
            break;
        }
        case OTHER_OVERSEA: {
            // 国际长途
            [self setAvatarText:@"9" borderColorString:@"tp_color_white_transparency_500" backgroundColorString:@"tp_color_cyan_500"];
            break;
        }
        case OTHTER_CALLING_ACTIVE: {
            // c2c来电
            [self setAvatarText:@"I" borderColorString:@"tp_color_white" backgroundColorString:@"tp_color_blue_500"];
            break;
        }
        case OTHER_UNKNOWN: {
            // 未知用户
            [self setAvatarText:@"9" borderColorString:@"tp_color_white_transparency_500" backgroundColorString:@"tp_color_grey_500"];
            break;
        }
        default:
            break;
    }

}

- (void) startFadding {
    if (self.callMode == CallModeOutgoingCall) {
        if (self.userType == OTHER_OVERSEA) {
            return;
        }
    }
    if (_animationStopped) {
        _avatarView.alpha = 1;
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
//        cootek_log(@"calling_page, startFadding, _avatarView.alpha: %f", _avatarView.alpha);
        if (_animationStopped) {
            _avatarView.alpha = 1;
            return;
        }
        if (_avatarView.alpha > 0.5) {
            _avatarView.alpha = 0.5;
        } else {
            _avatarView.alpha = 0.8;
        }
        
    } completion:^(BOOL finished) {
        [self startFadding];
    }];
}

- (void) stopFadding {
    _animationStopped = YES;
}

@end



/// ------------------------ CallAvatarGroup ------------------------ ///
@interface CallAvatarGroup ()
@property (nonatomic, strong) NSTimer* animationTimer;
@end


@implementation CallAvatarGroup {
    BOOL _animationStopped;
    NSAttributedString *_dotAttributedString;
    NSAttributedString *_arrowAttributedString;
    UILabel *_dotLineLabel;
    NSString *_arrowFontChar;
    NSString *_dotFontChar;
    NSInteger _benchCount;
    NSString *_benchString;
}

- (instancetype) initWithCallMode:(CallMode)callMode callerNumber:(NSString *)callerNumber otherNumArr:(NSArray *)otherNumArr {
    self = [super init];
    if (self) {
        CGRect frame = CGRectMake(0, 0, TPScreenWidth(), AVATAR_DIAMETER+50);
        self.frame = frame;
        
        _callerView = [[CallAvatarView alloc] initWithCallMode:callMode number:callerNumber];
        
        NSMutableArray* avatarArr = [NSMutableArray array];
        [avatarArr addObject:[[_callerView tpd_withSize:CGSizeMake(AVATAR_DIAMETER, AVATAR_DIAMETER)] tpd_wrapper]];
        
        NSMutableArray* nameArr = [NSMutableArray array];
        UILabel* namelabel = [[UILabel tpd_commonLabel] tpd_withText:@"我" color:[TPDialerResourceManager getColorForStyle:@"tp_color_white"]];
        namelabel.textAlignment = NSTextAlignmentCenter;
        namelabel.numberOfLines = 1;
        
        [nameArr addObject:namelabel];
        
        NSMutableArray* weightArr = [NSMutableArray array];
        [weightArr addObject:@1];
        for (NSString* otherNumber in otherNumArr) {
            CallAvatarView* other = [[CallAvatarView alloc] initWithCallMode:callMode number:otherNumber];
            [avatarArr addObject:[[other tpd_withSize:CGSizeMake(AVATAR_DIAMETER, AVATAR_DIAMETER)] tpd_wrapper]];
            
            
            int personId = [NumberPersonMappingModel queryContactIDByNumber:otherNumber];
            if (personId > 0) {
                ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personId];
                UILabel* nameLabel = [[UILabel tpd_commonLabel] tpd_withText:contact.displayName color:[TPDialerResourceManager getColorForStyle:@"tp_color_white"]];
                nameLabel.numberOfLines = 1;
                nameLabel.textAlignment = NSTextAlignmentCenter;
                nameLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
                [nameArr addObject:nameLabel];
            }else{
                UILabel* nameLabel = [[UILabel tpd_commonLabel] tpd_withText:otherNumber color:[TPDialerResourceManager getColorForStyle:@"tp_color_white"]];
                nameLabel.numberOfLines = 1;
                nameLabel.textAlignment = NSTextAlignmentCenter;
                nameLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
                
                [nameArr addObject:nameLabel];
            }
            
            [weightArr addObject:@1];
        }
        
        
        UIView* avatarLine = [UIView tpd_horizontalGroupFullScreenForIOS7:avatarArr horizontalPadding:0 verticalPadding:0 interPadding:0 weightArr:weightArr];
        
        UIView* nameLine = [UIView tpd_horizontalGroupFullScreenForIOS7:nameArr horizontalPadding:0 verticalPadding:0 interPadding:0 weightArr:weightArr];
        
        NSString *initString = @"正在呼叫";
        if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]
            || (callMode == CallModeIncomingCall) ) {
            initString = @" ";
        }
        _statusLabel = [[UILabel alloc] initWithTitle:initString fontSize:14];
        [self setTextColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"]];
        
        [self addSubview:avatarLine];
        [self addSubview:nameLine];
        [self addSubview:_statusLabel];
        
        [avatarLine makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(60);
        }];
        
        [nameLine makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(avatarLine.bottom).offset(10);
        }];
        
        _arrowAttributedString = [[NSAttributedString alloc] initWithString:@""];
        _dotAttributedString = [[NSAttributedString alloc] initWithString:@""];
        
        [_statusLabel makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(namelabel.bottom).offset(30);
            make.centerX.bottom.equalTo(self);
        }];
        
    }
    
    return self;
}



- (instancetype) initWithCallMode:(CallMode)callMode callerNumber:(NSString *)callerNumber calleeNumber:(NSString *)calleeNumber {
    self = [super init];
    if (self) {
        _animationStopped = NO;
        _benchCount = 0;

        CGRect frame = CGRectMake(0, 0, STATUS_INFO_BOX_WIDTH, AVATAR_DIAMETER);
        self.frame = frame;
        
        // left avatar view
        _callerView = [[CallAvatarView alloc] initWithCallMode:callMode number:callerNumber];
        
        _dotLineLabel = [[UILabel alloc] init];
        _dotLineLabel.clipsToBounds = YES;
        _dotLineLabel.hidden = YES;
        _dotLineLabel.textAlignment = NSTextAlignmentLeft;
        _dotLineLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _dotLineLabel.backgroundColor = [UIColor clearColor];
        _dotLineLabel.attributedText = _dotAttributedString;
        
        
        // status label
        NSString *initString = @"正在呼叫";
        if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]
            || (callMode == CallModeIncomingCall) ) {
            initString = @" ";
        }
        _statusLabel = [[UILabel alloc] initWithTitle:initString fontSize:14];
        
        // right avatar view
        _calleeView = [[CallAvatarView alloc] initWithCallMode:callMode number:calleeNumber];
        
        
        // view settings
        [self setTextColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"]];
        
        if (!_callerView.isMe) {
            _otherAvatarView = _callerView;
        } else if(!_calleeView.isMe) {
            _otherAvatarView = _calleeView;
        }
        
        // view tree
        [self addSubview:_callerView];
        [self addSubview:_calleeView];
        [self addSubview:_dotLineLabel];
        [self addSubview:_statusLabel];
        
        [_callerView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX).offset(-100);
            make.width.height.equalTo(AVATAR_DIAMETER);
            make.top.equalTo(self);
        }];
        
        [_calleeView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX).offset(100);
            make.width.height.equalTo(AVATAR_DIAMETER);
            make.top.equalTo(self);
        }];
        
        [_statusLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.top.equalTo(self);
        }];
        
        [_dotLineLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(_statusLabel.bottom).offset(20);
            make.width.equalTo(80);
        }];
        
        
        
    }
    return self;
}

- (void) setArrowStringAtIndex:(NSInteger)index {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:_dotAttributedString];
    if (index == -1) {
        [attrString appendAttributedString:_arrowAttributedString];
    } else {
        [attrString insertAttributedString:_arrowAttributedString atIndex:index];
    }
    [_dotLineLabel setAttributedText:attrString];
}

- (void) setStatusString:(NSString *)statusString {
    _statusString = statusString;
    _statusLabel.text = statusString;
}

- (void) setStatusString:(NSString *)statusString statusColor:(UIColor *)statusColor {
    _statusString = statusString;
    _statusLabel.text = statusString;
    _statusLabel.textColor = statusColor;
}

- (void) setTextColor:(UIColor *)textColor {
    if (!textColor) {
        return;
    }
    _statusLabel.textColor = textColor;
    _dotLineLabel.textColor = textColor;
}

- (UIView *) getDotByFrame:(CGRect)frame bgColor:(UIColor *)bgColor {
    UIView *dot = [[UIView alloc] initWithFrame:frame];
    dot.backgroundColor = bgColor;
    dot.layer.cornerRadius = (frame.size.width) / 2;
    dot.clipsToBounds = YES;
    return dot;
}

- (void) startMovingArrow {
    _dotLineLabel.hidden = NO;
    __block int i=0;
    self.animationTimer = [NSTimer bk_scheduledTimerWithTimeInterval:0.4 block:^(NSTimer *timer) {
        NSMutableString* s = [@"" mutableCopy];
        for (int j=0; j<4; j++) {
            if (j==i) {
                [s appendString:@"qq"];
            }else{
                [s appendString:@"pp"];
            }
        }
        [_dotLineLabel setFont:[UIFont fontWithName:@"iPhoneIcon1" size:14]];
        _dotLineLabel.text = s;
        i = (i+1)%4;
        
    } repeats:YES];
    
    
}

- (void) stopMovingArrow {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void) startFadding {
    if (_otherAvatarView) {
        [_otherAvatarView startFadding];
    }
}

- (void) stopFadding {
    if (_otherAvatarView) {
        [_otherAvatarView stopFadding];
    }
}


@end
