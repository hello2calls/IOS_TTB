//
//  NewCategoryCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-2.
//
//

#ifndef TouchPalDialer_NewCategoryCellView_h
#define TouchPalDialer_NewCategoryCellView_h
#import "YPUIView.h"

@class NewCategoryItem;
@class SectionNewCategory;
@interface NewCategoryCellView : YPUIView

- (void) drawView:(NewCategoryItem*) categoryItem;
- (void) resetWithCategoryData:(SectionNewCategory*)data andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx;

@end

#endif
