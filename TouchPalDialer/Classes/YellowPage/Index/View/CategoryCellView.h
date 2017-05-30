//
//  CategoryCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//
#ifndef TouchPalDialer_CategoryCellView_h
#define TouchPalDialer_CategoryCellView_h

#import "CategoryItem.h"
#import "TPUIButton.h"
#import "VerticallyAlignedLabel.h"
#import "SectionCategory.h"
#import "YPBaseButton.h"
#import "YPUIView.h"

@interface CategoryCellView : YPUIView

- (void) drawView:(CategoryItem*) categoryItem;
- (void) resetWithCategoryData:(SectionCategory*)cData andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx;
@end

#endif
