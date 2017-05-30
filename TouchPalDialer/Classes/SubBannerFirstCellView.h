//
//  SubBannerFirstCellView.h
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 15/12/16.
//
//

#ifndef SubBannerFirstCellView_h
#define SubBannerFirstCellView_h
#import "YPUIView.h"
#import "SubBannerItem.h"
#import "SectionSubBanner.h"

@interface SubBannerFirstCellView : YPUIView
@property(nonatomic, strong) SubBannerItem* item;
@property(nonatomic, assign) NSInteger row;
@property(nonatomic, assign) NSInteger column;

- (void) resetWithData:(SubBannerItem* )data withColumn:(int)column withTotalCount:(NSInteger)allColum;
@end

#endif /* SubBannerFirstCellView_h */