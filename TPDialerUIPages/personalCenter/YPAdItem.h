//
//  YPAdItem.h
//  TouchPalDialer
//
//  Created by siyi on 16/9/26.
//
//

#ifndef YPAdItem_h
#define YPAdItem_h

#import <Foundation/Foundation.h>
#import "BaseItem.h"
#import "HighLightItem.h"

NS_ENUM(NSInteger, AdShowInfoType) {
    kShowInfoDot,
    kShowInfoIcon,
    kShowInfoVector,
};

#define SHOW_INFO_TYPE_DOT @"dot"
#define SHOW_INFO_TYPE_ICON @"icon"
#define SHOW_INFO_TYPE_VECTOR @"vector"

#define DEFAULT_RIGHT_LABEL_TEXT @"iphone-ttf:iPhoneIcon4:K:22:tp_color_grey_600"
#define DEFAULT_LEFT_LABEL_TEXT @"iphone-ttf:iPhoneIcon2:i:22:tp_color_grey_600"

#define LOCAL_ANTIHARASS @"local_antiharass"

typedef NS_ENUM(NSInteger, ADCellAlertType) {
    AlertTypeUnknown,
    AlertTypeVector,
    AlertTypeDot,
    AlertTypeIcon,
};


@interface YPAdItem : BaseItem

+ (instancetype) localSettingItem;
+ (instancetype) localAntiharassItem;


+ (void) addClickHiddenInfo:(NSString*)key;
+ (void) hideClickHiddenInfo:(NSString*)key;
+ (void) clearClickHiddenInfo;

@property (nonatomic, strong, readwrite) NSString *rightDotCount;
@property (nonatomic, strong, readwrite) NSString *leftFont;

@property (nonatomic, assign, readonly) BOOL alertVisible;

@property (nonatomic, assign) ADCellAlertType leftAlertType;
@property (nonatomic, assign) ADCellAlertType rightAlertType;

@property (nonatomic, strong, readwrite) NSString *titleAlertText;


@end



#endif /* YPAdItem_h */
