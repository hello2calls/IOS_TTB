//
//  RightTopItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/16.
//
//

#import <Foundation/Foundation.h>
#import "CTUrl.h"
#import "IndexFilter.h"
#import "HighLightItem.h"

@interface RightTopItem : NSObject<NSCopying, NSMutableCopying, NSCoding>
@property(nonatomic, retain) CTUrl* ctUrl;
@property(nonatomic, retain) NSString* text;
@property(nonatomic, retain) IndexFilter* filter;
@property(nonatomic,retain) UIColor* highlightIconBgColor;
@property(nonatomic, retain) HighLightItem* highlightItem;

-(BOOL) isValid;
- (id) initWithJson:(NSDictionary*)json;
@end
