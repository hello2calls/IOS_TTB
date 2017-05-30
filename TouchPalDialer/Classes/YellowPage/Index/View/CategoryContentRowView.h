//
//  CategoryContentRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-3.
//
//

#ifndef TouchPalDialer_CategoryContentRowView_h
#define TouchPalDialer_CategoryContentRowView_h
@class SubCategoryItem;
@class CategoryContentCellView;
@interface CategoryContentRowView : UIView

@property(nonatomic,retain) NSMutableArray* cellViews;
@property(nonatomic,retain) SubCategoryItem* item;
@property(nonatomic, assign) NSInteger rowIndex;

- (id)initWithFrame:(CGRect)frame andData:(SubCategoryItem*)data andRowIndex:(NSInteger)rowIndex;
- (void) resetDataWithCategoryItem:(SubCategoryItem*)item andRowIndex:(NSInteger)rowIndex;
@end

#endif
