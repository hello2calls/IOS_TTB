//
//  CategoryTitleView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//
#import "SectionCategory.h"
#import "YPBaseButton.h"
#import "YPUIView.h"

@interface CategoryTitleView : YPUIView

@property(nonatomic,retain)SectionCategory* categoryData;
@property(nonatomic,retain)NSIndexPath* rowIndexPath;
@property(nonatomic,retain)NSString *title;;

-(void) drawViews:(SectionCategory*)category;
- (void) resetWithCategoryData:(SectionCategory *)cData andRowIndexPath:(NSIndexPath*)idxPath;
@end