//
//  BaseItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#ifndef TouchPalDialer_BaseItem_h
#define TouchPalDialer_BaseItem_h
#import "HighLightItem.h"

@class CTUrl;
@class IndexFilter;
@interface BaseItem : NSObject<NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic,retain) NSString* identifier;
@property(nonatomic,retain) NSString* title;
@property(nonatomic,retain) NSString* subTitle;
@property(nonatomic,retain) NSString* iconLink;
@property(nonatomic,retain) NSString* iconPath;
@property(nonatomic, retain) NSString* font;
@property(nonatomic ,retain) NSString* fontColor;
@property(nonatomic,retain) CTUrl* ctUrl;
@property(nonatomic, retain) NSMutableArray* edMonitorUrl;
@property(nonatomic, retain) IndexFilter* filter;
@property(nonatomic,retain) UIColor* iconBgColor;
@property(nonatomic,retain) UIColor* highlightIconBgColor;
@property(nonatomic, retain) HighLightItem* highlightItem;
@property(nonatomic, retain) NSString* curl;
@property(nonatomic, retain) NSMutableArray* cMonitorUrl;
@property(nonatomic, strong) NSString *tu;
@property(nonatomic, strong) NSString *s;
@property(nonatomic, strong) NSString *adid;
@property(nonatomic, assign) BOOL reloadAssetAfterBack;

- (id) initWithJson:(NSDictionary*) json;
- (BOOL) isValid;
- (void) hideClickHiddenInfo;
- (BOOL) shouldShowHighLight;

@end
#endif
