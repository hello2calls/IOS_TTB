//
//  SubBannerRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/11/11.
//
//

#import <UIKit/UIKit.h>
#import "SectionSubBanner.h"

@interface SubBannerRowView : UIView

@property(nonatomic, strong) SectionSubBanner* banner;
@property(nonatomic, strong) NSIndexPath* indexPath;
@property(nonatomic, strong) NSMutableArray* subViews;

- (void) resetDataWithItem:(SectionSubBanner*)item andIndexPath:(NSIndexPath*)indexPath;
@end
