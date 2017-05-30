//
//  CategoryRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//
#import "CategoryTitleView.h"
#import "CategoryCellView.h"
#import "BaseRowView.h"

@interface CategoryRowView : UIView

- (id)initWithFrame:(CGRect)frame andData:(SectionCategory*)data andIndexPath:(NSIndexPath*)indexPath;
- (void) resetDataWithCategoryItem:(SectionCategory*)item andIndexPath:(NSIndexPath*)indexPath;

@property (nonatomic, retain) CategoryTitleView* categoryTitleView;
@property (nonatomic, retain) NSMutableArray* categorySubViews;
@property (nonatomic, copy) NSIndexPath* rowIndexPath;
@property (nonatomic, retain) SectionCategory* categoryData;
@end
