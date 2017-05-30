//
//  FindRedPacketManager.m
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import "FeedsRedPacketManager.h"
#import "NSOperationQueue+Completion.h"
#import "YPFeedsTask.h"
#import "UserDefaultsManager.h"
#import "DialogUtil.h"
#import "FeedsRedPacketShowPopUpView.h"
#import "FindNewsListViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPAdControlRequestParams.h"
#import "FeedsRedPacketOpenPopUpView.h"
#import "UserDefaultKeys.h"
#import "DialerUsageRecord.h"
#import "UsageConst.h"
#import "UIView+Toast.h"
#import "FeedsRedPacketLoginController.h"
#import "TPFilterRecorder.h"

#define FEEDS_ACQUIRE_TYPE_LOCK @"FEEDS_ACQUIRE_TYPE_LOCK"

@interface FeedsRedPacketManager()
{
    NSOperationQueue* managerQueue;
}
@end


@implementation FeedsRedPacketManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        managerQueue = [NSOperationQueue new];
        managerQueue.maxConcurrentOperationCount = 4;
    }
    return self;
}

- (void) queryFeedsRedPacketByType:(YPRedPacketType)type withBlock:(void (^)(FindNewsBonusResult *))block
{
    if ([[NSDate date] timeIntervalSince1970] - [UserDefaultsManager intValueForKey:[NSString stringWithFormat:@"%@%d", FEEDS_ACQUIRE_TYPE_LOCK, type] defaultValue:0] < 60) {
        if (block) {
            block(nil);
        }
        return;
    }
    
    //
    NSMutableDictionary* tasks = [NSMutableDictionary new];
    
    YPFeedsTask* taskLst = [[YPFeedsTask alloc] init];
    [taskLst setBonusType:YP_RED_PACKET_FEEDS_LIST];
    [taskLst setRequestType:YP_RED_PACKET_REQUEST_QUERY];
    
    YPFeedsTask* taskDetail = [[YPFeedsTask alloc] init];
    [taskDetail setBonusType:YP_RED_PACKET_FEEDS_DETAIL];
    [taskDetail setRequestType:YP_RED_PACKET_REQUEST_QUERY];
    
    if (type == YP_RED_PACKET_FEEDS_ALL) {
        [managerQueue addOperation:taskLst];
        [managerQueue addOperation:taskDetail];
        [tasks setObject:taskLst forKey:FEEDS_TYPE_LIST];
        [tasks setObject:taskDetail forKey:FEEDS_TYPE_DETAIL];
    } else if (type == YP_RED_PACKET_FEEDS_LIST) {
        [managerQueue addOperation:taskLst];
        [tasks setObject:taskLst forKey:FEEDS_TYPE_LIST];
    } else if (type == YP_RED_PACKET_FEEDS_DETAIL){
        [managerQueue addOperation:taskDetail];
        [tasks setObject:taskDetail forKey:FEEDS_TYPE_DETAIL];
    }
    
    [managerQueue setCompletion:^{
        for (NSString* key in tasks.allKeys) {
            YPFeedsTask* task = [tasks objectForKey:key];
            FindNewsBonusResult* bonusResult = [task getBonusResult];
            
            NSDateFormatter*df = [[NSDateFormatter alloc]init];//格式化
            [df setDateFormat:FEEDS_DATE_FORMAT];
            if (block != nil) {
                if (bonusResult) {
                    if ([bonusResult checkBonus]) {
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:FEEDS_DATE_FORMAT];
                        NSString* current = [df stringFromDate:[NSDate date]];
                        if (![current isEqualToString:[UserDefaultsManager stringForKey:FEEDS_QEURY_RED_PACKET_TIME]]) {
                            [UserDefaultsManager setObject:current forKey:FEEDS_QEURY_RED_PACKET_TIME];
                            [UserDefaultsManager setBoolValue:[bonusResult checkBonus] forKey:key];
                            [UserDefaultsManager setBoolValue:[bonusResult checkBonus] forKey:FEEDS_QEURY_RED_PACKET_ALL];
                        }
                    } else {
                        [UserDefaultsManager setBoolValue:NO forKey:key];
                    }
                }
                
                dispatch_sync(dispatch_get_main_queue(), ^(){
                    block(bonusResult);
                });
            }
        }
    }];
    
}

- (void) acquireFeedsRedPacketByType:(YPRedPacketType)type withQueryResult:(FindNewsBonusResult *)queryResult withBlock:(void (^)(FindNewsBonusResult *))block
{
    __block YPFeedsTask* taskLst = [[YPFeedsTask alloc] init];
    [taskLst setBonusType:type];
    [taskLst setQueryResult:queryResult];
    [taskLst setRequestType:YP_RED_PACKET_REQUEST_ACQUIRE];
    [managerQueue addOperation:taskLst];
    
    [managerQueue setCompletion:^{
        FindNewsBonusResult* bonusResult = [taskLst getBonusResult];
        if (block) {
            dispatch_sync(dispatch_get_main_queue(), ^(){
                if (bonusResult && [bonusResult checkBonus]) {
                    [UserDefaultsManager setIntValue:[[NSDate date] timeIntervalSince1970] forKey:[NSString stringWithFormat:@"%@%d", FEEDS_ACQUIRE_TYPE_LOCK, type]];
                }
                block(bonusResult);
            });
            
        }
    }];
    
}

+ (void) checkRedPacket
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:FEEDS_DATE_FORMAT];
    NSString* current = [df stringFromDate:[NSDate date]];
    if (![current isEqualToString:[UserDefaultsManager stringForKey:FEEDS_QEURY_RED_PACKET_TIME]] || ![UserDefaultsManager boolValueForKey:FEEDS_QEURY_RED_PACKET_ALL defaultValue:NO]) {
        [[FeedsRedPacketManager new] queryFeedsRedPacketByType:YP_RED_PACKET_FEEDS_ALL withBlock:nil];
        [UserDefaultsManager setBoolValue:NO forKey:FEEDS_TYPE_LIST];
        [UserDefaultsManager setBoolValue:NO forKey:FEEDS_TYPE_DETAIL];
        [UserDefaultsManager setBoolValue:NO forKey:FEEDS_QEURY_RED_PACKET_ALL];
    }
}

+ (void) showRedPacketGuaji
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:FEEDS_DATE_FORMAT];
    NSString* current = [df stringFromDate:[NSDate date]];
    if ([current isEqualToString:[UserDefaultsManager stringForKey:FEEDS_QEURY_RED_PACKET_TIME]]) {
        if ([UserDefaultsManager boolValueForKey:FEEDS_TYPE_LIST defaultValue:NO] || [UserDefaultsManager boolValueForKey:FEEDS_TYPE_DETAIL defaultValue:NO]) {
            FeedsRedPacketShowPopUpView* view = [[FeedsRedPacketShowPopUpView alloc] initWithContent:@"看天天头条" content2:@"天天领红包"];
            
            __weak FeedsRedPacketShowPopUpView* wRedPacketView = view;
            view.imageView.block = ^(){
                [wRedPacketView closeSelf];
                FindNewsListViewController* controller = [[FindNewsListViewController alloc] init];
                controller.tu = [NSString stringWithFormat:@"%d", DSP_FEEDS_GUAJI];
                [TouchPalDialerAppDelegate pushViewController:controller animated:YES];
                [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_CLICK_GUAJI_RED_PACKET];
            };
            view.block = ^{
                [wRedPacketView closeSelf];
                [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_CANCEL_GUAJI_RED_PACKET];
            };
            [DialogUtil showDialogWithContentView:view inRootView:nil];
            
            [UserDefaultsManager setBoolValue:NO forKey:FEEDS_TYPE_LIST];
            [UserDefaultsManager setBoolValue:NO forKey:FEEDS_TYPE_DETAIL];
        }
    }
}

+ (void) showRedPacket: (UIView *) iconView withType:(YPRedPacketType)type withQueryResult:(FindNewsBonusResult *)queryResult withLoginBlock:(void(^)(void))block
{
    
    NSString* typeStr =  [NSString stringWithFormat:@"%d", type];
    if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_FROM, LOGIN_FROM_FEEDS_RED_PACKET), nil];
        FeedsRedPacketLoginController *feedRedPacketLogin = [FeedsRedPacketLoginController new];
        feedRedPacketLogin.type = type;
        feedRedPacketLogin.afterLoginBlock = block;
        [LoginController checkLoginWithDelegate:feedRedPacketLogin];
        [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name",FEEDS_CLICK_SHOW_RED_PACKET), Pair(@"type", typeStr), Pair(@"isLogined", @"false"), nil];
        return;
    }
    
    __weak UIView* weakView = iconView;
    FeedsRedPacketShowPopUpView* view = [[FeedsRedPacketShowPopUpView alloc] initWithContent:@"看天天头条" content2:@"天天领红包"];
    __weak FeedsRedPacketShowPopUpView* wShowView = view;
    [DialogUtil showDialogWithContentView:view inRootView:nil];
    view.block = ^{
         [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name", FEEDS_CANCEL_SHOW_RED_PACKET), Pair(@"type", typeStr), nil];
        [wShowView closeSelf];
        weakView.hidden = NO;
    };
    view.closeView.block = ^{
         [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name", FEEDS_CANCEL_SHOW_RED_PACKET), Pair(@"type", typeStr), nil];
        [wShowView closeSelf];
        weakView.hidden = NO;
    };
    
    view.imageView.block = ^{
         [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name", FEEDS_CLICK_SHOW_RED_PACKET), Pair(@"type", typeStr), nil];
        [wShowView drawContent:@"" content2:@"打开中 . . ."];
        if (wShowView) {
            wShowView.block = ^{
                
            };
            wShowView.closeView.block = nil;
            wShowView.imageView.block = nil;
        }
        
        [[FeedsRedPacketManager new] acquireFeedsRedPacketByType:type withQueryResult:queryResult withBlock:^(FindNewsBonusResult * result) {
            [wShowView closeSelf];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [FeedsRedPacketManager openRedPacket:weakView withType:type withResult:result];
            });
        }];
    };
    
    weakView.hidden = YES;
}

+ (void) openRedPacket: (UIView *) iconView withType:(YPRedPacketType)type withResult:(FindNewsBonusResult *)result;
{
    __weak UIView* weakView = iconView;
    NSString* typeStr = [NSString stringWithFormat:@"%d", type];
    
    if (!result || ![result checkBonus]) {
        [[[UIApplication sharedApplication].delegate window]
         makeToast:@"红包领取失败，请稍后重试..." duration:3.0 position:nil];
        weakView.hidden = NO;
        NSString* errorCode = [result getResultCode].stringValue;
         [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name", FEEDS_DISPLAY_OPEN_RED_PACKET), Pair(@"type", typeStr), Pair(@"error_code", errorCode), nil];
        return;
    }
    
    [UserDefaultsManager setBoolValue:NO forKey:FEEDS_QEURY_RED_PACKET_ALL];
    
    [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name", FEEDS_DISPLAY_OPEN_RED_PACKET), Pair(@"type", typeStr), nil];
    
    NSString* content = @"";
    if (type == YP_RED_PACKET_FEEDS_LIST) {
        content = @"看新闻详情还可领红包哦" ;
    } else if (type == YP_RED_PACKET_FEEDS_DETAIL){
        content = @"看天天头条 天天领红包";
    }
    
    FeedsRedPacketOpenPopUpView* view = [[FeedsRedPacketOpenPopUpView alloc] initWithContent:content andResult:result];
    __weak FeedsRedPacketOpenPopUpView* wShowView = view;
    [DialogUtil showDialogWithContentView:view inRootView:nil];
    
    view.block = ^{
        [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name", FEEDS_CLICK_OPEN_RED_PACKET), Pair(@"type", typeStr), nil];
        [wShowView closeSelf];
    };
    view.closeView.block = ^{
        [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name", FEEDS_CLICK_OPEN_RED_PACKET), Pair(@"type", typeStr), nil];
        [wShowView closeSelf];
    };
    
    view.imageView.block = ^{
        
    };
    
    weakView.hidden = YES;
}

@end
