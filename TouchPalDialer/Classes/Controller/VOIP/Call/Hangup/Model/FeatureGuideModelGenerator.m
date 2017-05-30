//
//  FeatureGuideModelGenerator.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/7/29.
//
//

#import "FeatureGuideModelGenerator.h"
#import "UserDefaultsManager.h"
#import "VoipShareAllView.h"
#import "TouchPalDialerAppDelegate.h"
#import "HandlerWebViewController.h"
#import "TPDialerResourceManager.h"
#import "HangupCommercialManager.h"
#import "DialerUsageRecord.h"
#import "FunctionUtility.h"
#import "TouchPalVersionInfo.h"
#import "PersonInfoDescViewController.h"
#import "LocalStorage.h"
#import "SeattleFeatureExecutor.h"
#import "Reachability.h"
#import "VoipUtils.h"

#define FEATURE_VIP 1
#define FEATURE_INVITE_PERSON 2

#define FEATURE_MAX FEATURE_INVITE_PERSON
#define FEATURE_MIN FEATURE_VIP



@implementation FeatureGuideModelGenerator {
    DefaultProvider* _provider;
    BOOL _isFirstNomalHangup;
}

- (id)initWithHangupModel:(HangupModel *)model andIfFirstNormalHangup:(BOOL)isFirst{
    self = [super initWithHangupModel:model];
    if (self) {
        _isFirstNomalHangup = isFirst;
        if (_isFirstNomalHangup) {
            _provider = [[FeatureGuideSpit alloc] init];
            //need tell show if got commercial
            [[HangupCommercialManager instance] tellShow:NO];
            [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_SHOW, @(0)), nil];
        }

        else if([[HangupCommercialManager instance] checkIfResourceReady]){
            _provider = [[CommercialGuide alloc] init];
        } else {
            _provider = [self getProvider];
        }
        _provider.manager = self;
    }
    return self;
}

- (id)initWithshowBackCallOrFeatureProviderHangupModel:(HangupModel *)model{
    self = [super initWithHangupModel:model];
    if (self) {
        if (_isFirstNomalHangup) {
            _provider = [[FeatureGuideSpit alloc] init];
            //need tell show if got commercial
            [[HangupCommercialManager instance] tellShow:NO];
            [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_SHOW, @(0)), nil];
        }
        else {
            _provider = [self getProvider];
        }
        _provider.manager = self;
    }
    return self;
}

- (HeaderViewModel *)getHeaderModel {
    HeaderViewModel *model = [super getHeaderModel];
    if ([_provider respondsToSelector:@selector(headerAltText)]) {
        NSString *altText = [_provider headerAltText];
        if (altText.length > 0) {
            model.altText = altText;
        }
    }
    if (self.hangupModel.isp2pCall) {
        model.mainText = @"通话结束";
        model.mainAttrString = nil;
    }
    return model;
}

- (MiddleViewModel *)getMiddleModel {
    MiddleViewModel *model = [[MiddleViewModel alloc] init];
    model.icon = [self getGuideIconImage];
    model.text = [self getDescriptText];
    model.altText = [self getDescriptTextAlt];
    model.highlightText = !_isFirstNomalHangup;
    return model;
}

- (MainActionViewModel *)getMainActionViewModel {
    MainActionViewModel * model = [[MainActionViewModel alloc] init];
    if (_isFirstNomalHangup) {
        model.spitGuideText = @"有问题，要吐槽？";
        model.lightBg = YES;
    } else {
        model.mainButtonTitle = [self getActionText];
        model.onMainButtonClick = [self getActionBlock];
        if ([_provider isKindOfClass:[VipCallProvider class]]) {
            model.lightBg = YES;
        }
    }
    return model;
}

- (UIImage *)getBgImage {
    return [self getGuideBgImage];
}

- (DefaultProvider *)getProvider {
    BOOL ifVIP = [UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO];
    DefaultProvider *provider = nil;
    if (ifVIP) {
        provider = [[FeatureInvitePerson alloc] init];
        [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_SHOW, @(FEATURE_INVITE_PERSON)), nil];
    }else{
        provider = [[VipCallProvider alloc] init];
        [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_SHOW, @(FEATURE_VIP)), nil];
    }
    return provider;
}

- (UIImage *)getGuideBgImage {
    if ([(id)_provider respondsToSelector:@selector(guideBgImage)]) {
        return [_provider guideBgImage];
    }
    return nil;
}

- (UIImage *)getGuideIconImage {
    if ([(id)_provider respondsToSelector:@selector(guideIconImage)]) {
        return [_provider guideIconImage];
    }
    return nil;
}

- (NSString *)getActionText {
    if ([(id)_provider respondsToSelector:@selector(actionText)]) {
        return [_provider actionText];
    }
    return nil;
}

- (void(^)(void))getActionBlock {
    if ([(id)_provider respondsToSelector:@selector(actionBlock)]) {
        return [_provider actionBlock];
    }
    return nil;
}

- (NSString *)getDescriptText {
    if ([(id)_provider respondsToSelector:@selector(descriptText)]) {
        return [_provider descriptText];
    }
    return nil;
}

- (NSString *)getDescriptTextAlt {
    if ([(id)_provider respondsToSelector:@selector(descriptTextAlt)]) {
        return [_provider descriptTextAlt];
    } else {
        return nil;
    }
}

+ (void)share {
    HandlerWebViewController *webVC = [[HandlerWebViewController alloc] init];
    NSString *url = USE_DEBUG_SERVER ? TEST_INVITE_REWARDS_WEB : INVITE_REWARDS_WEB;
    webVC.url_string = [url stringByAppendingString:@"?share_from=HangUp"];
    UIViewController *topVC = [TouchPalDialerAppDelegate naviController].topViewController;
    webVC.header_title = NSLocalizedString(@"invite_friends", @"邀请有奖");
    [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:YES];
    [FunctionUtility removeFromStackViewController:topVC];
    [DialerUsageRecord recordpath:PATH_INVITE_PAGE kvs:Pair(@"invite_page_from", @(4)), nil];
}

@end

@implementation DefaultProvider

@end


@implementation VipCallProvider

- (UIImage *)guideBgImage {
    return [TPDialerResourceManager getImage:@"hangup_vip_guide@2x.png"];
}

- (NSString *)actionText {
    return @"立即获取VIP";
}

- (void(^)(void))actionBlock {
    __weak VipCallProvider *bself = self;
    return ^{
        NSString *string = [VIP_URL stringByReplacingOccurrencesOfString:@"auth_token" withString:[SeattleFeatureExecutor getToken]];
        if ([LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]!=nil&&![[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]isEqualToString:@""]) {
            string = [string stringByReplacingOccurrencesOfString:@"全国" withString:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
        }
        
        HandlerWebViewController  *vipWebViewVC = [[HandlerWebViewController alloc]init];
        vipWebViewVC.url_string =[string  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        vipWebViewVC.header_title = @"赚钱中心";
        [[TouchPalDialerAppDelegate naviController] pushViewController:vipWebViewVC animated:YES];
        [bself.manager.changeDelegate close];
        [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_CLICK, @(FEATURE_VIP)), nil];
    };
}

- (NSString *)descriptText {
    return nil;
}

- (NSString *)descriptTextAlt {
    return nil;
}

@end


@implementation ForeignUserProvider

- (UIImage *)guideIconImage {
    return [TPDialerResourceManager getImage:@"hangup_foreign_guide@2x.png"];
}

- (NSString *)actionText {
    return @"告诉朋友";
}

- (void(^)(void))actionBlock {
    return  ^{
        [FeatureGuideModelGenerator share];
    };
}

- (NSString *)descriptText {
    return @"出国漫游也能免费打回国";
}

- (NSString *)descriptTextAlt {
    return @"同行小伙伴一起用触宝，接听也免费";
}

@end


@implementation FeatureNumberDisplay

- (UIImage *)guideIconImage {
    return [TPDialerResourceManager getImage:@"hangup_display_number_guide@2x.png"];
}

- (NSString *)actionText {
    return @"立即邀请";
}

- (NSString *)descriptText {
    return @"去电显号秘籍";
}

- (NSString *)descriptTextAlt {
    return @"触宝好友间优先显号，避免被拒接";
}

- (void(^)(void))actionBlock {
    return  ^{
        [FeatureGuideModelGenerator share];
    };
}


@end

@implementation FeatureInvitePerson

- (UIImage *)guideBgImage {
    return [TPDialerResourceManager getImage:@"hangup_invite_guide@2x.png"];
}

- (NSString *)actionText {
    return @"立即邀请";
}

- (NSString *)descriptText {
    return nil;
}

- (void(^)(void))actionBlock {
    return  ^{
        [FeatureGuideModelGenerator share];
        [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_CLICK, @(FEATURE_INVITE_PERSON)), nil];
    };
}


@end

@implementation FeatureGuideSpit

- (UIImage *)guideIconImage {
    return [TPDialerResourceManager getImage:@"hangup_guide_spit@2x.png"];
}

- (NSString *)descriptText {
    return @"走向完美的路上总是充满挑战\n不显好？有杂音？立即吐槽！";
}


@end

@implementation CommercialGuide

- (UIImage *)guideBgImage {
    return [[HangupCommercialManager instance] getImage];
}

- (NSString *)actionText {
    return [[HangupCommercialManager instance] getClickText];
}

- (NSString *)headerAltText {
    return [[HangupCommercialManager instance] getGuideText];
}

- (void(^)(void))actionBlock {
    if ([self actionText].length == 0) {
        return nil;
    }
    __weak CommercialGuide *bself = self;
    return ^ {
        [[HangupCommercialManager instance] handleClickWithCloseBlock:^{
                [bself.manager.changeDelegate close];
        }];
    };
}


@end
