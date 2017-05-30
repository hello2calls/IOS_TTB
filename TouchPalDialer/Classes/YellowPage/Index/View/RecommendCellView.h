//
//  RecommendCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#import "YPUIView.h"
#import "IconFontImageView.h"
#import "VerticallyAlignedLabel.h"
@class CategoryItem;

@interface RecommendCellView : YPUIView

@property (nonatomic, retain) CategoryItem* categoryData;
@property (nonatomic, retain) UIImage* icon;
- (id)initWithFrame:(CGRect)frame andData:(CategoryItem*)item;
- (void) drawViewWithIndex:(int)index andisLastRow:(BOOL)isLastRow andItem:(CategoryItem *)item;
- (void) redrawHighLight;
@end