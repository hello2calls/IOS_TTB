//
//  SubBannerItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15/11/12.
//
//

#import "sectionbase.h"
#import "CTUrl.h"
#import "IndexFilter.h"
#import "HighLightItem.h"
#import "BaseItem.h"

@interface SubBannerItem : BaseItem
@property(nonatomic, retain) NSString* titleColor;
@property(nonatomic, retain) NSString* subTitleColor;
@property(nonatomic, retain) NSString* desc;
@property(nonatomic, retain) NSString* descColor;
@property(nonatomic, retain) NSString* image;
@property(nonatomic, retain) NSString* bigImage;

- (id) initWithJson:(NSDictionary*)json;

@end
