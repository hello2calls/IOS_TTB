//
//  CategoryItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//
#ifndef TouchPalDialer_Category_h
#define TouchPalDialer_Category_h

#import "sectionbase.h"

@interface SectionCategory : SectionBase

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* style;
@property(nonatomic, assign) BOOL isOpened;

- (id) initWithJson: (NSDictionary*) json;
- (int) getRowHeight;
- (int) getRowCount;
+ (NSMutableArray*) getCategoryItemsFromDictionaryArray:(NSMutableArray*)array;
@end

#endif