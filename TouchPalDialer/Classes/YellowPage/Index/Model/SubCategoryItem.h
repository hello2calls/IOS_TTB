//
//  SubCategoryItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-2.
//
//

#ifndef TouchPalDialer_SubCategoryItem_h
#define TouchPalDialer_SubCategoryItem_h
#import "BaseItem.h"

@interface SubCategoryItem : BaseItem

@property(nonatomic, retain)NSString* type;
@property(nonatomic, retain)NSNumber* index;
@property(nonatomic, retain)NSMutableArray* cellCategories;

@end

#endif
