//
//  TouchLifeShareMgr.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/20.
//
//

#import "TouchLifeShareMgr.h"
#import "LocalStorage.h"
#import "UserDefaultKeys.h"
#import "SeattleFeatureExecutor.h"
#import "VoipShareAllView.h"
#import "TouchPalDialerAppDelegate.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"
#import "ShareData.h"
#import "PreShareFactory.h"
#import "CooTekServerDef.h"
#import "FunctionUtility.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
//#import "TouchPalVersionInfo.h"


#define SHARE_QUERY @"/share/query"
#define TOUCH_DEBUG_URL @"http://121.52.235.231:40714"


@interface TouchLifeShareMgr()
@property (nonatomic, strong)NSMutableDictionary *shares;
@end

@implementation TouchLifeShareMgr
static TouchLifeShareMgr *sMgr;
+ (void)initialize {
    sMgr = [[TouchLifeShareMgr alloc] init];
}

+ (id)instance {
    return sMgr;
}

- (void)removeSharesObject:(TouchLifeShare *)object {
    [_shares removeObjectForKey:@(object.hash)];
}

- (TouchLifeShare *)newTouchLifeShare {
    if (_shares == nil) {
        _shares = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    TouchLifeShare *share = [[TouchLifeShare alloc] init];
    [_shares setObject:share forKey:@(share.hash)];
    return share;
}

- (void)shareWithRef:(NSUInteger)ref {
    TouchLifeShare *share = [_shares objectForKey:@(ref)];
    if (share) {
        [share notify];
    }
}


@end

@interface TouchLifeShare() <NSURLConnectionDataDelegate>

@end

@implementation TouchLifeShare {
    NSURLConnection *_con;
    NSMutableData *_data;
    NSDictionary *_responseBody;
    BOOL _notifyAuto;
    NSTimer *_timer;
    PreShareView *_shareView;
}

- (NSDictionary *)generateShareRequestParamWithCallNumber:(NSString *)phone callDuration:(NSInteger)dur isVoipCall:(BOOL)isVoipCall
{
    double now = [[NSDate date] timeIntervalSince1970];
    double nextUpdate = [UserDefaultsManager doubleValueForKey:SHARE_CHECK_NEXT_UPDATE_TIME];
    if (now < nextUpdate) {
        return nil;
    }
    
    double longtitude = [[LocalStorage getItemWithKey:QUERY_PARAM_LONGITUDE] doubleValue];
    double latitude = [[LocalStorage getItemWithKey:QUERY_PARAM_LATITUDE] doubleValue];
    NSString *city = @"";
    NSString *add = @"";
    if (now*1000 - [[LocalStorage getItemWithKey:NATIVE_PARAM_CITY_CACHE_TIME] longLongValue] <= 3*86400*1000) {
        city = [LocalStorage getItemWithKey:NATIVE_PARAM_CITY];
        add = [LocalStorage getItemWithKey:NATIVE_PARAM_ADDR];
    }
    if (!add || add.length == 0) {
        add = @"";
    }
    if (!city || city.length == 0) {
        city = @"";
    }
    NSDictionary *dict = @{@"longitude": @(longtitude), @"latitude": @(latitude), @"city":city, @"address":add,\
                           @"scene_limit":@"CALL", @"call_type": (isVoipCall ? @"voip" : @"normal"),\
                           SHARE_REQUEST_TARGET_NUMBER:phone?:@"",SHARE_REQUEST_DURATION:@(dur),
                           @"version":TOUCHLIFE_SHARE_VERSION,
                           @"system":@"iOS",@"device":[FunctionUtility deviceName]};
    
    return dict;
}

- (void)checkShareWithRequestParam:(NSDictionary *)param
{
    if ( ! param || ! [param count] ) {
        cootek_log(@"the body is send para is null");
        return;
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
    NSString *paras = [[NSString alloc] initWithBytes:[data bytes] length:data.length encoding:NSUTF8StringEncoding];;
    cootek_log(@"the body is send para: %@ and error:%@", paras, error);
    [self checkShare:paras notifyAuto:YES];
}

- (void)checkShare:(id)paras notifyAuto:(BOOL)notifyAuto {
    _notifyAuto = notifyAuto;
    NSData *postData = nil;
    if ([paras isKindOfClass:[NSString class]]) {
        postData = [paras dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        postData = paras;
    }
    NSString *postLen = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *domain = [NSString stringWithFormat:@"http://%@",COOTEK_DYNAMIC_LIFE_SERVICE];
    if (USE_DEBUG_SERVER) {
        domain = TOUCH_DEBUG_URL;
    }
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?_token=%@", domain, SHARE_QUERY, [SeattleFeatureExecutor getToken]]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLen forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    cootek_log(@"the body is send: %@", paras);
    _con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(stopConnection) userInfo:nil repeats:NO];
}

- (void)notify {
    if (_responseBody == nil) {
        [self finishShare];
        return;
    }
    ShareData *shareData = [[ShareData alloc] initWithInstantBonusType:_responseBody[INSTANT_BONUS_TYPE_KEY] instantBonusQuantity:_responseBody[INSTANT_BONUS_QUANTITY_KEY] shareBonusMessage:_responseBody[SHARE_BONUS_CONTENT_KEY] shareBonusQuantity:_responseBody[SHARE_BONUS_QUANTITY_KEY] shareBonusHint:_responseBody[SHARE_BONUS_HINT_KEY] shareMessage:_responseBody[SHARE_MESSAGE_KEY] shareUrl:_responseBody[SHARE_URL_KEY] shareTitle:_responseBody[SHARE_TITLE_KEY] shareImageUrl:_responseBody[SHARE_IMAGE_URL_KEY] shareButtonTitle:_responseBody[SHARE_BUTTON_TITLE_KEY] uiVersion:_responseBody[UI_VERSION]];
    _shareView = [PreShareFactory showPreShareView:shareData inParent:[TouchPalDialerAppDelegate naviController].topViewController.view];
    __weak TouchLifeShare *bself = self;
    _shareView.shareBlock = ^ {
        [bself clickShare];
    };
    _shareView.cancelBlock = ^ {
        [bself clickCancel];
    };
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self stopConnection];
}

- (void)stopConnection {
    [_con cancel];
    _con = nil;
    [self stopTimer];
    [self finishShare];
    if (_netOperResultBlock) {
        _netOperResultBlock(NO);
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_data == nil) {
        _data = [[NSMutableData alloc] init];
    }
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self stopTimer];
    if (_data == nil) {
        [self finishShare];
        return;
    }
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:_data options:0 error:NULL];
    _data = nil;
    cootek_log(@"the body is: %@", response);
    int resultCode = 0;
    if (response) {
        resultCode = [response[@"result_code"] intValue];
        NSDictionary *result = response[@"result"];
        if (result) {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:result];
            if ([tempDict[SHARE_BONUS_QUANTITY_KEY] isKindOfClass:[NSNumber class]]) {
                tempDict[SHARE_BONUS_QUANTITY_KEY] = [tempDict[SHARE_BONUS_QUANTITY_KEY] stringValue];
            }
            _responseBody = tempDict;
            double nextupdate = [result[NEXT_QUERY_TIME_KEY] doubleValue];
            if (nextupdate > 0) {
                NSLog(@"set nextupdate time to %f", nextupdate);
                [UserDefaultsManager setDoubleValue:nextupdate forKey:SHARE_CHECK_NEXT_UPDATE_TIME];
            }
        }
        if (resultCode == 2000 && _notifyAuto) {
            [self notify];
        }
    }
    if (resultCode != 2000) {
        [self finishShare];
    }
    if (_netOperResultBlock) {
        _netOperResultBlock(resultCode == 2000);
    }
}

- (NSDictionary *)getData {
    return _responseBody;
}

- (void)clickShare {
    if ([_responseBody[SHARE_URL_KEY] length] > 0) {
        ShareResultCallback callBack = ^(ShareResult ret, NSString *source, NSString *error) {
            switch (ret) {
                case ShareSuccess:
                    [DialerUsageRecord recordpath:EV_PACKAGE_PATH kvs:Pair(@"package_id", _responseBody[PACKAGE_ID_KEY]), Pair(@"action", @"success"), Pair(@"source", source), nil];
                    break;
                case ShareFail:
                    [DialerUsageRecord recordpath:EV_PACKAGE_PATH kvs:Pair(@"package_id",_responseBody[PACKAGE_ID_KEY]),Pair(@"action", @"fail"), Pair(@"source", source), nil];
                    break;
                case ShareCancel:
                    [DialerUsageRecord recordpath:EV_PACKAGE_PATH kvs:Pair(@"package_id",_responseBody[PACKAGE_ID_KEY]),Pair(@"action", @"cancel"), Pair(@"source", source), nil];
                    break;
                default:
                    break;
            }
        };
        VoipShareAllView *shareAllView = [[VoipShareAllView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) title:_responseBody[SHARE_TITLE_KEY] msg:_responseBody[SHARE_MESSAGE_KEY] url:_responseBody[SHARE_URL_KEY] buttonArray:_responseBody[BOX_SHARE_LIST_KEY]];
        shareAllView.shareResultCallback = [callBack copy];
        [shareAllView setHeadTitle:_responseBody[BOX_SHARE_TITLE_KEY]];
        shareAllView.imageUrl = _responseBody[SHARE_IMAGE_URL_KEY];
        shareAllView.fromWhere = _responseBody[PACKAGE_ID_KEY];
        [[TouchPalDialerAppDelegate naviController].topViewController.view addSubview:shareAllView];
        [DialerUsageRecord recordpath:EV_PACKAGE_PATH kvs:Pair(@"package_id", _responseBody[PACKAGE_ID_KEY]),Pair(@"action", @"click_share"), nil];
    }
    [self finishShare];
}

- (void)clickCancel {
    [DialerUsageRecord recordpath:EV_PACKAGE_PATH kvs:Pair(@"package_id", _responseBody[PACKAGE_ID_KEY]),Pair(@"action", @"click_cancel"), nil];
    [self finishShare];
}

- (void)finishShare  {
    [sMgr removeSharesObject:self];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (NSDictionary *)testResponse {
    return @{INSTANT_BONUS_TYPE_KEY: @"type", INSTANT_BONUS_QUANTITY_KEY: @"10", SHARE_BONUS_HINT_KEY: @"hello, i'm hint", SHARE_BONUS_QUANTITY_KEY: @"10", SHARE_BONUS_CONTENT_KEY : @"hello bonus content", SHARE_MESSAGE_KEY : @"for share message", SHARE_TITLE_KEY: @"for share title", SHARE_URL_KEY : @"www.baidu.com", SHARE_IMAGE_URL_KEY : @"for share image url"};
}



@end
