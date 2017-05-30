//
//  NewCategoryRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#ifndef TouchPalDialer_NewCategoryRowView_h
#define TouchPalDialer_NewCategoryRowView_h

@class SectionNewCategory;
@interface NewCategoryRowView : UIView

- (id)initWithFrame:(CGRect)frame andData:(SectionNewCategory*)data andIndexPath:(NSIndexPath*)indexPath andHeader:(BOOL)show;
- (void) resetDataWithCategoryItem:(SectionNewCategory*)item andIndexPath:(NSIndexPath*)indexPath;
+ (int) getCategoryTag:(NSIndexPath *)indexPath;

@property (nonatomic, retain) NSMutableArray* categorySubViews;
@property (nonatomic, copy) NSIndexPath* rowIndexPath;
@property (nonatomic, retain) SectionNewCategory* categoryData;

@end

#endif
