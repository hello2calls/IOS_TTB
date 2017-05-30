//
//  CategoryContentCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-3.
//
//

#ifndef TouchPalDialer_CategoryContentCellView_h
#define TouchPalDialer_CategoryContentCellView_h

#import "YPUIView.h"

@class CategoryItem;
@interface CategoryContentCellView : YPUIView

- (void) drawView:(CategoryItem*) categoryItem andRoxIndex:(NSInteger)rowIdx;
- (void) resetWithCategoryData:(CategoryItem*)data andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx;

@end

#endif
