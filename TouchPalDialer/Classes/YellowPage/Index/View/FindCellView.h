//
//  FavouriteCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-6-25.
//
//

#ifndef TouchPalDialer_FindCellView_h
#define TouchPalDialer_FindCellView_h

#import "YPUIView.h"
#import "SectionFind.h"

@class CategoryItem;
@interface FindCellView : YPUIView

- (void) drawView:(CategoryItem*) item;
- (void) resetWithFindData:(SectionFind*)data andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx;

@end

#endif
