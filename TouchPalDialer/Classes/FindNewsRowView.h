//
//  FindNewsRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/23.
//
//

#import "YPUIView.h"
#import "VerticallyAlignedLabel.h"
#import "FindNewsSubTitleView.h"
#import "FindNewsItem.h"
#import "FindNewTitleView.h"
#import "FindNewsHeaderView.h"

#define FIND_NEWS_PATH_TAG @"findnews"

@interface FindNewsRowView : YPUIView

@property(nonatomic, strong) FindNewsHeaderView* header;
@property(nonatomic, strong) FindNewTitleView* titleBigImage;
@property(nonatomic, strong) FindNewTitleView* titleRightImage;
@property(nonatomic, strong) FindNewTitleView* titleNoImage;
@property(nonatomic, strong) FindNewsSubTitleView* subTitleLeft;
@property(nonatomic, strong) FindNewsSubTitleView* subTitleLeftNOImage;
@property(nonatomic, strong) FindNewsSubTitleView* subTitleBottom;
@property(nonatomic, strong) UIImageView* bigImage;
@property(nonatomic, strong) UIImageView* rightImage;
@property(nonatomic, strong) NSArray* bottomImages;
@property (nonatomic, strong) UILabel *videoTimeLabel;
@property (nonatomic, strong) UIImageView *videoPlayImageView;

@property(nonatomic, strong) FindNewsItem* item;
@property(nonatomic, strong) NSIndexPath* path;
@property(nonatomic, assign)BOOL isV6;

- (id)initWithFrame:(CGRect)frame andData:(FindNewsItem *)data andIndexPath:(NSIndexPath*)indexPath isV6:(BOOL) v6Version;
- (void) resetDataWithFindNewsItem:(FindNewsItem *)data andIndexPath:indexPath;


@end
