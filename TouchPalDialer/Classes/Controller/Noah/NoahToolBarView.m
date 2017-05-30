//
//  NoahToolBarView.m
//  TouchPalDialer
//
//  Created by game3108 on 14-12-18.
//
//

#import "NoahToolBarView.h"
#import "TPDialerResourceManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "PersonalCenterController.h"
#import "TouchPalDialerAppDelegate.h"
#import "HandlerWebViewController.h"
#import "DialerViewController.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"
#import "DialerGuideAnimationUtil.h"
#import "SkinSettingViewController.h"

#define kToolBarStyle         @"style"
#define kToolBarStyleGeneral  @"general"
#define kToolBarStyleWarning  @"warning"
#define kToolBarStyleActivity @"activity"
#define kToolBarStyleCustom   @"custom"

#define kCustomStyle          @"customstyle"
#define kStyleBackgroudColor  @"backgroudcolor"
#define kStyleTextcolor       @"textcolor"
#define kStyleTextfontsize    @"textfontsize"
#define kStyleLeftIcon        @"lefticon"
#define kStyleRightIcon       @"righticon"
#define kStyleIconFontsize    @"fontsize"
#define kStyleIconFontcolor   @"fontcolor"
#define kStyleIconFontname    @"fontname"
#define kStyleIconText        @"text"

#define DELTA_DISTANCE 50


@interface NoahToolBarView(){
    BOOL onTouchMove;

    NSString *toastId;
    BOOL allowClean;
    NSString *tag;
    NSString *display;
    NSString *summary;
    NSString *actionConfirm;
    BOOL _isCleaned;
}
@end


@implementation NoahToolBarView
#pragma mark LifeCyle

- (instancetype)initWithFrame:(CGRect)frame andToolbarToast:(ToolbarToast*) toolbarToast andDelegate:(id<NoahToolBarViewDelegate>) delegate{
    self = [super initWithFrame:frame];
    if (self) {
        toastId = toolbarToast.toastId;
        _delegate = delegate;
        [[NoahManager sharedPSInstance] shown:toastId];
        onTouchMove = NO;
        _isCleaned = NO;

        self.backgroundColor = [UIColor grayColor];
        allowClean = toolbarToast.allowClean;
        tag = toolbarToast.tag;
        display = toolbarToast.display;
        summary = toolbarToast.summary;
        actionConfirm = toolbarToast.actionConfirm;


        if (actionConfirm){
            __weak id<NoahToolBarViewDelegate> blockDelegate = delegate;
            void(^actionConfirmBlock)() = ^(){
                [blockDelegate closeNoahToolBar];
            };
            [[NoahManager sharedInstance].actionConformDic setObject:[actionConfirmBlock copy] forKey:toastId];
        }

        [self configViewWith:toolbarToast];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andLocaMessage:(NSDictionary *)mesDic andDelegate:(id<NoahToolBarViewDelegate>) delegate{
    self.priority=((NSString *) mesDic[@"priority"]).integerValue;
    self = [super initWithFrame:frame];
    if (self) {
    _delegate = delegate;
    [[NoahManager sharedPSInstance] shown:toastId];
    onTouchMove = NO;
    _isCleaned = NO;
    toastId = mesDic[@"toastId"];

    self.backgroundColor = [UIColor grayColor];
    allowClean = ((NSString *)mesDic[@"allowClean"]).boolValue;
    display = mesDic[@"display"];

    summary = mesDic[@"summary"];
    // backgroud image
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    [self addSubview:imageView];

    // backgroud view
    UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:bgView];

    // left icon
    UILabel *leftIcon = [[UILabel alloc] init];
    leftIcon.backgroundColor = [UIColor clearColor];
    [self addSubview:leftIcon];

    // text
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:textLabel];

    // right icon
    UILabel *rightIcon = [[UILabel alloc] init];
    rightIcon.backgroundColor = [UIColor clearColor];
    [self addSubview:rightIcon];

    // right button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:rightButton];

    NSDictionary *styleDic = [self parsrStyleWithTag:@"0"];


    bgView.backgroundColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleBackgroudColor]];

    CGFloat xx = 10;
    CGFloat leftIconWidth = [styleDic[kStyleLeftIcon][kStyleIconFontsize] floatValue];
    NSString *leftFontName = styleDic[kStyleLeftIcon][kStyleIconFontname];
    leftIcon.frame = CGRectMake(xx, 0, leftIconWidth, self.bounds.size.height);
    leftIcon.font = [UIFont fontWithName:leftFontName size:leftIconWidth];
    leftIcon.textColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleLeftIcon][kStyleIconFontcolor]];
    leftIcon.text = styleDic[kStyleLeftIcon][kStyleIconText];

    CGFloat rightIconWidth = [styleDic[kStyleRightIcon][kStyleIconFontsize] floatValue];
    NSString *rightFontName = styleDic[kStyleRightIcon][kStyleIconFontname];
    rightIcon.frame = CGRectMake(self.bounds.size.width - 15 - rightIconWidth, 0, rightIconWidth, self.bounds.size.height);
    rightIcon.font = [UIFont fontWithName:rightFontName size:rightIconWidth];
    rightIcon.textColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleRightIcon][kStyleIconFontcolor]];
    rightIcon.text = styleDic[kStyleRightIcon][kStyleIconText];


    if (allowClean) {
        rightIcon.font = [UIFont fontWithName:@"iPhoneIcon2" size:rightIconWidth];
        rightIcon.textColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleRightIcon][kStyleIconFontcolor]];
        rightIcon.text = @"t";
        rightButton.frame = CGRectMake(self.bounds.size.width - rightIconWidth - 20, 0, rightIconWidth + 20, self.bounds.size.height);;
        [rightButton addTarget:self action:@selector(cleanNoahToolBar) forControlEvents:UIControlEventTouchUpInside];
    }

    xx += (leftIconWidth + 5);
    textLabel.frame = CGRectMake(xx, 0, self.bounds.size.width - 15 - rightIconWidth - 5 - xx, self.bounds.size.height);
    textLabel.font = [UIFont systemFontOfSize:[styleDic[kStyleTextfontsize] floatValue]];
    textLabel.textColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleTextcolor]];
    textLabel.text = mesDic[@"display"];

    }
    return  self;
}

- (void)configViewWith:(ToolbarToast *)toast
{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    // backgroud image
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    [self addSubview:imageView];

    // backgroud view
    UIView *bgView = [[UIView alloc] initWithFrame:frame];
    [self addSubview:bgView];

    // left icon
    UILabel *leftIcon = [[UILabel alloc] init];
    leftIcon.backgroundColor = [UIColor clearColor];
    [self addSubview:leftIcon];

    // text
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:textLabel];

    // right icon
    UILabel *rightIcon = [[UILabel alloc] init];
    rightIcon.backgroundColor = [UIColor clearColor];
    [self addSubview:rightIcon];

    // right button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:rightButton];

    NSDictionary *styleDic = [self parsrStyleWithTag:toast.tag];

    NSString *imgUrl = [[NoahManager sharedPSInstance] getPresentImagePath:toastId];

    bgView.backgroundColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleBackgroudColor]];

    CGFloat xx = 10;
    CGFloat leftIconWidth = [styleDic[kStyleLeftIcon][kStyleIconFontsize] floatValue];
    NSString *leftFontName = styleDic[kStyleLeftIcon][kStyleIconFontname];
    leftIcon.frame = CGRectMake(xx, 0, leftIconWidth, frame.size.height);
    leftIcon.font = [UIFont fontWithName:leftFontName size:leftIconWidth];
    leftIcon.textColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleLeftIcon][kStyleIconFontcolor]];
    leftIcon.text = styleDic[kStyleLeftIcon][kStyleIconText];

    CGFloat rightIconWidth = [styleDic[kStyleRightIcon][kStyleIconFontsize] floatValue];
    NSString *rightFontName = styleDic[kStyleRightIcon][kStyleIconFontname];
    rightIcon.frame = CGRectMake(frame.size.width - 15 - rightIconWidth, 0, rightIconWidth, frame.size.height);
    rightIcon.font = [UIFont fontWithName:rightFontName size:rightIconWidth];
    rightIcon.textColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleRightIcon][kStyleIconFontcolor]];
    rightIcon.text = styleDic[kStyleRightIcon][kStyleIconText];


    if (allowClean) {
        rightIcon.font = [UIFont fontWithName:@"iPhoneIcon2" size:rightIconWidth];
        rightIcon.textColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleRightIcon][kStyleIconFontcolor]];
        rightIcon.text = @"t";
        rightButton.frame = CGRectMake(frame.size.width - rightIconWidth - 20, 0, rightIconWidth + 20, frame.size.height);;
        [rightButton addTarget:self action:@selector(cleanNoahToolBar) forControlEvents:UIControlEventTouchUpInside];
    }

    xx += (leftIconWidth + 5);
    textLabel.frame = CGRectMake(xx, 0, frame.size.width - 15 - rightIconWidth - 5 - xx, frame.size.height);
    textLabel.font = [UIFont systemFontOfSize:[styleDic[kStyleTextfontsize] floatValue]];
    textLabel.textColor = [TPDialerResourceManager getColorForStyle:styleDic[kStyleTextcolor]];
    textLabel.text = toast.display;
    if (imgUrl){
        NSString *documentsDir = [[NoahManager sharedInstance] storagePath];
        UIImage *image = [UIImage imageWithContentsOfFile:[documentsDir stringByAppendingPathComponent:imgUrl]];
        self.frame = CGRectMake(0, 0,frame.size.width, image.size.height*(frame.size.width)/image.size.width);

        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,frame.size.width, image.size.height*(frame.size.width)/image.size.width)];
        [self addSubview:imageView];

        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self bringSubviewToFront:imageView];

        if (allowClean) {
            UIButton *rightBigButton = [UIButton buttonWithType:UIButtonTypeCustom];
            rightBigButton.backgroundColor = [UIColor clearColor];
            rightBigButton.frame = CGRectMake(self.frame.size.width-50, 0, 50, self.frame.size.height);
            [rightBigButton setImage:[TPDialerResourceManager getImage:@"inapp_advert_close_normal@2x.png"] forState:(UIControlStateNormal)];
            [rightBigButton setImage:[TPDialerResourceManager getImage:@"inapp_advert_close_pressedl@2x.png"] forState:(UIControlStateHighlighted)];
            [rightBigButton addTarget:self action:@selector(cleanNoahToolBar) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:rightBigButton];
        }

    }

}

- (NSDictionary *)parsrStyleWithTag:(NSString *)tagStyle
{
    if ([tagStyle isKindOfClass:[NSDictionary class]]){
        tagStyle = ((NSDictionary*) tagStyle)[@"content"];
    }

    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[tagStyle ? : @"" dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];


    NSString        *style = dic[kToolBarStyle];

    NSDictionary *defaultSytle = @{
        kStyleBackgroudColor:@"0xe5f4ff",
        kStyleTextcolor:@"tp_color_black_transparency_800",
        kStyleTextfontsize:@14,
        kStyleLeftIcon:@{
            kStyleIconFontsize:@20,
            kStyleIconFontcolor:@"tp_color_light_blue_400",
            kStyleIconFontname:@"iPhoneIcon3",
            kStyleIconText:@"5"
        },

        kStyleRightIcon:@{
            kStyleIconFontsize:@18,
            kStyleIconFontcolor:@"tp_color_black_transparency_600",
            kStyleIconFontname:@"iPhoneIcon2",
            kStyleIconText:@"n",
        }
    };
    NSDictionary *ret = nil;

    if ([style isEqualToString:kToolBarStyleActivity]) {
        ret = @{
            kStyleBackgroudColor:@"0xfff1e3",
            kStyleTextcolor:@"tp_color_black_transparency_800",
            kStyleTextfontsize:@14,
            kStyleLeftIcon:@{
                kStyleIconFontsize:@20,
                kStyleIconFontcolor:@"tp_color_orange_500",
                kStyleIconFontname:@"iPhoneIcon1",
                kStyleIconText:@"h"
            },

            kStyleRightIcon:@{
                kStyleIconFontsize:@18,
                kStyleIconFontcolor:@"tp_color_black_transparency_600",
                kStyleIconFontname:@"iPhoneIcon2",
                kStyleIconText:@"t",
            }
        };
    } else if ([style isEqualToString:kToolBarStyleWarning]) {
        ret = @{
            kStyleBackgroudColor:@"0xffebed",
            kStyleTextcolor:@"tp_color_black_transparency_800",
            kStyleTextfontsize:@14,
            kStyleLeftIcon:@{
                kStyleIconFontsize:@20,
                kStyleIconFontcolor:@"tp_color_red_300",
                kStyleIconFontname:@"iPhoneIcon2",
                kStyleIconText:@"B"
            },

            kStyleRightIcon:@{
                kStyleIconFontsize:@18,
                kStyleIconFontcolor:@"tp_color_black_transparency_600",
                kStyleIconFontname:@"iPhoneIcon2",
                kStyleIconText:@"n",
            }
        };
    } else if ([style isEqualToString:kToolBarStyleCustom]) {
        ret = dic[kCustomStyle];
        ret = ret.count ? ret : defaultSytle;
    } else {
        // default style
        ret = defaultSytle;
    }

    return ret;
}

-(void)dealloc{
    if (actionConfirm){
        [[[NoahManager sharedInstance] actionConformDic] removeObjectForKey:toastId];
    }
    if (!_isCleaned) {
        [[NoahManager sharedPSInstance] closed:toastId];
    }
}

#pragma mark Action

- (void) cleanNoahToolBar{
    [[NoahManager sharedPSInstance] cleaned:toastId];
    if (self.priority==1) {
        [UserDefaultsManager setIntValue:2 forKey:had_show_test_inapp_guide];
    }else if(self.priority==2){
        [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_HAS_SHOWN];
    }
    [UserDefaultsManager setBoolValue:YES forKey:toastId];
    _isCleaned = YES;
    [_delegate closeNoahToolBar];

}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!onTouchMove){
        if ([toastId rangeOfString:@"showGuideView"].length>0) {

        }else if([toastId rangeOfString:@"inAppPush"].length>0){
            if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME].length==0) {
                [DialerUsageRecord recordpath:PATH_INAPP_TESTFREECALL_GUDIE kvs:Pair(KEY_ACTION,UNREGESTER_CLICK), nil];
            }else{
                [DialerUsageRecord recordpath:PATH_INAPP_TESTFREECALL_GUDIE kvs:Pair(KEY_ACTION,REGESTER_CLICK), nil];
            }
            [UserDefaultsManager setIntValue:2 forKey:had_show_test_inapp_guide];
            NSString *pushUrl  =[toastId substringFromIndex:[toastId rangeOfString:@"inAppPush"].length];
            HandlerWebViewController *inAppPushController = [[HandlerWebViewController alloc]init];
            inAppPushController.url_string = pushUrl;
            inAppPushController.header_title =summary;
            [[TouchPalDialerAppDelegate naviController] pushViewController:inAppPushController animated:YES];
        }else if([toastId rangeOfString:@"showDialerGuideAnimation"].length>0){
            [DialerUsageRecord recordpath:PATH_DIALER_GUIDE_ANIMATION kvs:Pair(KEY_DIALER_GUIDE_INAPP, OK), nil];
            [DialerGuideAnimationUtil showGuideAnimation];
        } else if([toastId rangeOfString:@"skin_ad_message_id"].length > 0) {
            SkinSettingViewController *vc = [[SkinSettingViewController alloc] init];
            vc.startPage = LOCAL_TAB_SKIN_INDEX;
            [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
        }
        else{
            [[NoahManager sharedPSInstance] clicked:toastId];
        }
        if ( !actionConfirm ){
            [self cleanNoahToolBar];
        }
    }else{
        onTouchMove = NO;
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y < -DELTA_DISTANCE || point.y > self.frame.size.height + DELTA_DISTANCE) {
        onTouchMove = YES;
    } else {
        onTouchMove = NO;
    }
    [super touchesMoved:touches withEvent:event];
}

@end
