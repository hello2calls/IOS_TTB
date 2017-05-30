//
//  SectionNewCategory.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#ifndef TouchPalDialer_SectionNewCategory_h
#define TouchPalDialer_SectionNewCategory_h
#import "SectionBase.h"

@class IndexFilter;
@interface SectionNewCategory : SectionBase

@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) NSNumber* count;

- (id) initWithJson:(NSDictionary*) json;
@end

#endif
