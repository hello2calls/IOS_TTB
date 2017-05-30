//
//  SubBannerCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/11/11.
//
//

#import "YPUIView.h"
#import "SectionSubBanner.h"
#import "SubBannerItem.h"

@interface SubBannerCellView : YPUIView

@property(nonatomic, strong) SubBannerItem* item;

- (void) resetWithData:(SubBannerItem* )data withColumn:(int)column withTotalCount:(NSInteger)allColum;
@end
