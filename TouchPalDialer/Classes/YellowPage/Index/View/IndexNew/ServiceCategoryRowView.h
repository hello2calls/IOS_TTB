//
//  ServiceCategoryRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/11/10.
//
//

#import <UIKit/UIKit.h>
#import "SectionService.h"

@interface ServiceCategoryRowView : UIView

@property(nonatomic, strong)SectionService* service;
@property(nonatomic, strong)NSIndexPath* indexPath;
@property(nonatomic, strong)NSMutableArray* categorySubViews;
@property(nonatomic, strong)UIView* emptyView;

- (void) resetDataWithCategoryItem:(SectionService *)service andIndexPath:(NSIndexPath*)indexPath andIsLastCategory:(BOOL)isLastCategory;

@end
