//
//  CategorySubItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#import "SectionGroup.h"
#import "SectionBase.h"
#import "BaseItem.h"

@class CTUrl;
@class HighLightItem;
@class IndexFilter;


@interface CategoryItem : BaseItem
@property(nonatomic, retain) NSArray* classify;
@property(nonatomic, retain) NSString* type;
@property(nonatomic, retain) NSMutableArray* subItems;
@property(nonatomic, retain) NSString* disabledIcon;
@property(nonatomic, retain) NSNumber* index;



- (id) initWithJson:(NSDictionary*) json;
- (UIViewController *) startWebView;
@end
