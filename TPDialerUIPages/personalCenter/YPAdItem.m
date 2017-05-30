//
//  YPAdItem.m
//  TouchPalDialer
//
//  Created by siyi on 16/9/26.
//
//

#import "YPAdItem.h"
#import "NSString+TPHandleNil.h"
#import "UserDefaultsManager.h"
#import "IndexJsonUtils.h"
#import "CTUrl.h"
#import "AntiharassmentViewController.h"

#define WHITESPACE_STR @" "

#pragma mark - Class YPAdItem

@implementation YPAdItem
- (id) initWithJson:(NSDictionary *)json {
    self = [super initWithJson:json];
    if (self) {
        _leftAlertType = self.iconLink != nil ? AlertTypeIcon: AlertTypeVector;
        _rightDotCount = [[json objectForKey:@"rightDotCount"] stringValue];
        if ([NSString isNilOrEmpty:_rightDotCount]) {
            _rightDotCount = @" ";
            _rightAlertType = AlertTypeVector;
        } else {
            _rightAlertType = AlertTypeDot;
        }
        _leftFont = [json objectForKey:@"leftFont"];
        if (_leftFont == nil) {
            _leftFont = DEFAULT_LEFT_LABEL_TEXT;
        }
        _titleAlertText = [json objectForKey:@"titleAlert"];
        if (![NSString isNilOrEmpty:self.identifier]) {
            [YPAdItem addClickHiddenInfo:self.identifier];
        }
    }
    return self;
}

- (BOOL) alertVisible {
    if ([LOCAL_ANTIHARASS isEqualToString:self.identifier]) {
        return [AntiharassmentViewController hasNewDBVersion];
    }
    
    NSDictionary* keyDictionary = (NSDictionary*)[UserDefaultsManager objectForKey:YP_AD_ITEM_VISIBLE_KEY];
    NSString* value = [keyDictionary objectForKey:self.identifier];
    BOOL ret = [value boolValue];
    return ret;
}

#pragma mark hiding info
+ (void) addClickHiddenInfo:(NSString*)key {
    if (key == nil) {
        return;
    }
    NSDictionary* keyDictionary = (NSDictionary*)[UserDefaultsManager objectForKey:YP_AD_ITEM_VISIBLE_KEY];
    
    if ([keyDictionary objectForKey:key]) {
        return;
    }
    
    if (keyDictionary == nil) {
        keyDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"true", key, nil];
    } else {
        [keyDictionary setValue:@"true" forKey:key];
    }
    [UserDefaultsManager setObject:keyDictionary forKey:YP_AD_ITEM_VISIBLE_KEY];
}

+ (void) hideClickHiddenInfo:(NSString*)key {
    if (key == nil) {
        return;
    }
    if ([LOCAL_ANTIHARASS isEqualToString:key]
        && [AntiharassmentViewController hasNewDBVersion]) {
        return;
    }
    
    NSDictionary* keyDictionary = (NSDictionary*)[UserDefaultsManager objectForKey:YP_AD_ITEM_VISIBLE_KEY];
    NSString* value = [keyDictionary objectForKey:key];
    
    if ([value boolValue]) {
        [keyDictionary setValue:@"false" forKey:key];
        [UserDefaultsManager setObject:keyDictionary forKey:YP_AD_ITEM_VISIBLE_KEY];
    }
}

+ (void) clearClickHiddenInfo {
    [UserDefaultsManager setObject:nil forKey:YP_AD_ITEM_VISIBLE_KEY];
}


#pragma mark Local Items
+ (instancetype) localSettingItem {
    YPAdItem *localItem = [[YPAdItem alloc] init];
    if (localItem != nil) {
        localItem.leftFont = @"iphone-ttf:iPhoneIcon5:E:24:tp_color_grey_600";
        localItem.rightDotCount = @" ";
        localItem.title = NSLocalizedString(@"tpd_center_cell_settings", @"设置");
        localItem.rightAlertType = AlertTypeVector;
        
        CTUrl *localUrl = [[CTUrl alloc] init];
        localUrl.nativeUrl = @{
                               @"ios": @{
                                       @"controller": @"PersonalCenterController",
                                       },
                               };
        localItem.ctUrl = localUrl;
    }
    return localItem;
}

+ (instancetype) localAntiharassItem {
    YPAdItem *localItem = [[YPAdItem alloc] init];
    if (localItem != nil) {
        localItem.identifier = @"local_antiharass";
        localItem.leftFont = @"iphone-ttf:iPhoneIcon5:R:24:tp_color_grey_600";
        localItem.rightDotCount = @" ";
        localItem.title = NSLocalizedString(
                @"personal_center_setting_disturbance_identification", @"骚扰识别");
        localItem.titleAlertText = nil;
        localItem.rightAlertType = AlertTypeVector;
        
        CTUrl *localUrl = [[CTUrl alloc] init];
        localUrl.nativeUrl = @{
       @"ios": @{
               @"controller": [AntiharassmentViewController controllerClassName],
               },
       };
        localItem.ctUrl = localUrl;
        
        HighLightItem *hlItem = [[HighLightItem alloc] init];
        hlItem.type = @"redpoint";
        localItem.highlightItem = hlItem;
        
        [YPAdItem addClickHiddenInfo:localItem.identifier];
    }
    return localItem;
}

@end
