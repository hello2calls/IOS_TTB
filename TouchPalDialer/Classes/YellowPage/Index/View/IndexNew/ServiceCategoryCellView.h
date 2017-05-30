//
//  ServiceCategoryCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/11/10.
//
//

#import "YPUIView.h"
#import "CategoryItem.h"

@interface ServiceCategoryCellView : YPUIView

@property(nonatomic, assign) NSInteger row;
@property(nonatomic, assign) NSInteger column;
@property(nonatomic, strong) NSArray* categories;
- (void) resetWithCategoryData:(NSArray *)categoryArray andRowIndex:(NSInteger)row andColumnIndex:(NSInteger)column;
- (void) drawView:(CategoryItem*) categoryItem;
@end
