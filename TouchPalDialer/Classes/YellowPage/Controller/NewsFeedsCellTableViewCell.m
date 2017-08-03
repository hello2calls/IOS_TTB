//
//  NewsFeedsCellTableViewCell.m
//  TouchPalDialer
//
//  Created by lin tang on 16/11/24.
//
//

#import "NewsFeedsCellTableViewCell.h"
#import "FindNewsItem.h"
#import "FindNewsListViewController.h"
#import "UITableViewCell+TPDExtension.h"
#import "UIImageView+WebCache.h"
#import "IndexConstant.h"
#import "VerticallyAlignedLabel.h"
#import "TPDialerResourceManager.h"
#import "CTUrl.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "AdInfoModelManager.h"
#import "SSPStat.h"
#import "EdurlManager.h"
#import "CootekNotifications.h"
#import "UIDataManager.h"
#import "TPDVideoPlayController.h"
#import "TouchPalDialerAppDelegate.h"

@interface NewsFeedsCellTableViewCell()
@property(nonatomic, assign) FeedsLayoutType typeLayout;
@property(copy)void (^block)(id);
@property(nonatomic, assign)BOOL pressed;
@property(nonatomic, assign)CGPoint startPoint;

@end


@implementation NewsFeedsCellTableViewCell
@synthesize item;
@synthesize typeLayout;
@synthesize borderView;
@synthesize highlightView;
//@synthesize nativeAdView;
@synthesize pressed;
@synthesize startPoint;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.bounds = [UIScreen mainScreen].bounds;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setFindnewsItem:(FindNewsItem*) newsItem withIndexPath:(NSIndexPath *)path
{
   
    self.item = newsItem;
    self.typeLayout = [NewsFeedsCellTableViewCell typeFromItem:newsItem];
    
    if (self.item.category == CategoryADGDT) {
        [self.item.gdtAdNativeObject attachAd:self.item.gdtAdNativeData toView:self];
    } else if (self.item.category == CategoryADBaidu) {
        NewsFeedsCellTableViewCell* cellView = [self viewWithTag:FIND_NEWS_BAIDU_TAG];
        cellView.item = self.item;
//        [nativeAdView loadAndDisplayNativeAdWithObject:item.baiduAdNativeObject completion:^(NSArray *errors) {
//            if (!errors) {
//                if (nativeAdView) {
//                    [nativeAdView trackImpression];
//                }
//            }
//        }];
    }
    
    if (self.item.topIndex && self.item.topIndex.longValue >= 0) {
         self.highlightView.hidden = NO;
        self.highlightView.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"].CGColor;
        self.highlightView.textColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        self.highlightView.text = @"  置顶  ";
    } else if (self.item.hotKeys.count > 0) {
        self.highlightView.hidden = NO;
         self.highlightView.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"].CGColor;
        self.highlightView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
        if (self.item.hotKeys.count >= 1) {
            self.highlightView.text =
                [NSString stringWithFormat:@"  %@  ", [self.item.hotKeys objectAtIndex:0]];
        }
        
    } else {
        self.highlightView.hidden= YES;
    }
    
    switch (self.typeLayout) {
            case BaiduLeftImageLayoutType:
            case BaiduThreeImageLayoutType:
            case BaiduBigImageLayoutType:
            case NoImageLayoutType:
            case LeftImageLayoutType:
            case ThreeImageLayoutType:
            case BigImageLayoutType:
            case VideoLayoutType:
        {
            long timeLong = 0;
            if (self.item.timestamp && self.item.timestamp.length > 0) {
                timeLong = [self.item.timestamp longLongValue];
            }
            NSString* time = [self revertTimeFormat: timeLong];
            NSString* desc = self.item.subTitle;
            NSString* subTitle = @"  ";
            
            switch (self.item.category) {
                case CategoryNews: {
                    subTitle = [NSString stringWithFormat:@"%@ %@", desc, time];
                    break;
                }
                default:
                    break;
            }
            
            self.tpd_label1.text = newsItem.title;
            self.tpd_label2.text = subTitle;
            switch (self.typeLayout) {
                case LeftImageLayoutType:
                case BaiduLeftImageLayoutType:
                case BigImageLayoutType:
                case BaiduBigImageLayoutType:
                case VideoLayoutType: {
                    UIImage *placeholderImage = [TPDialerResourceManager getImage:@"feeds_video_preview_placeholder_big@3x.png"];
                    if (newsItem.images.count < 1) {
                        break;
                    }
                    NSURL *previewImageURL= [NSURL URLWithString:[newsItem.images objectAtIndex:0]];
                    [((UIImageView *)self.tpd_img1)
                        sd_setImageWithURL:previewImageURL placeholderImage:placeholderImage];
                    switch (self.typeLayout) {
                        case VideoLayoutType: {
                            self.videoTimeLabel.text =
                                [self formattedTimeStringWithSeconds:self.item.duration];
                            break;
                        }
                        default: {
                            break;
                        }
                    }
                    break;
                }
                case ThreeImageLayoutType:
                case BaiduThreeImageLayoutType:
                {
                    if (newsItem.images.count < 3) {
                        break;
                    }
                    [((UIImageView *)self.tpd_img1) sd_setImageWithURL:[NSURL URLWithString:[newsItem.images objectAtIndex:0]]];
                    [((UIImageView *)self.tpd_img2) sd_setImageWithURL:[NSURL URLWithString:[newsItem.images objectAtIndex:1]]];
                    [((UIImageView *)self.tpd_img3) sd_setImageWithURL:[NSURL URLWithString:[newsItem.images objectAtIndex:2]]];
                    break;
                }
                default:
                    break;
            }
            if (newsItem.noBottomBorder) {
                self.borderView.hidden = YES;
            } else {
                self.borderView.hidden = NO;
            }
            break;
        }
        case UpdateRecLayoutType:
        {
            self.tpd_label1.text = @"上次读到这儿，点击刷新";
            if (newsItem.noBottomBorder) {
                self.tpd_label1.hidden = YES;
                self.borderView.hidden = NO;
            } else {
                self.tpd_label1.hidden = NO;
                self.borderView.hidden = YES;
            }
            return;
        }
        default:
            break;
    }
    if (self.item.isClicked) {
        self.tpd_label1.textColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_grey_500"];
    } else {
        self.tpd_label1.textColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_grey_900"];
    }
}


- (NSString *)revertTimeFormat:(long)timesp{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init]; //时间格式化属性
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    long currentTime = [[NSDate date] timeIntervalSince1970];
    long interval = ABS(currentTime - timesp);
    if (interval < 60) {
        return @"1分钟内";
    } else if (interval < 60 * 60) {
        return [NSString stringWithFormat:@"%d分钟前", interval / 60];
    } else if (interval < 24 * 60 * 60) {
        return [NSString stringWithFormat:@"%d小时前", interval / 60 / 20];
    } else {
        [formatter setDateFormat:@"MM-dd HH:mm"]; //    [formatter setDateFormat:@"yyyy-MM-dd HH:MM:ss"];
        if (timesp == 0) {
            return @"";
        }
        return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timesp]]; //当前时间字符串
    }
}


- (NewsFeedsCellTableViewCell *) createCellViewsFromItem:(FindNewsItem *)feedsItem
{
    CGFloat topMargin = FIND_NEWS_TOP_MARGIN;
    CGFloat topMargin2 = FIND_NEWS_MARGIN_TO_IMAGE;
    CGFloat topMargin3 = 20;
    CGFloat leftMargin = FIND_NEWS_LEFT_MARGIN;
    
    CGFloat offset = 4;
    CGFloat threeHeight = INDEX_ROW_HEIGHT_FIND_NEWS_THREE_IMAGE;
    
    if (isIPhone6Resolution()) {
        if (WIDTH_ADAPT  <= 1.01f) {
            topMargin = topMargin - offset;
            topMargin2 = topMargin2 - offset;
            leftMargin = leftMargin - offset;
            topMargin3 = topMargin3 - offset;
            threeHeight = threeHeight - 4;
        }
    }
    
    borderView = [[UIView alloc] init];
    borderView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
    __weak NewsFeedsCellTableViewCell* wSelf = self;
    self.typeLayout = [NewsFeedsCellTableViewCell typeFromItem:feedsItem];
    switch (self.typeLayout) {
        case BaiduLeftImageLayoutType:
        case BaiduBigImageLayoutType:
        case BaiduThreeImageLayoutType:
        {
            NewsFeedsCellTableViewCell* cellView = [[NewsFeedsCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            switch (self.typeLayout) {
                case BaiduThreeImageLayoutType:
                {
                     cellView =  (NewsFeedsCellTableViewCell *)[cellView tpd_tableViewCellStyleLabelImage3Label:@[@"", @"", @"", @"", @""] action:nil reuseId:nil];
                    cellView.tpd_label1.numberOfLines = 2;
                    cellView.tpd_label2.numberOfLines = 1;
                    [cellView.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(threeHeight);
                    }];
                    [cellView.tpd_img2 updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(threeHeight);
                    }];
                    [cellView.tpd_img3 updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(threeHeight);
                    }];
                    [cellView.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(cellView).offset(topMargin);
                        make.bottom.equalTo(cellView.tpd_img1.top).offset(-topMargin2);
                    }];
                    [cellView addSubview:borderView];
                    [borderView updateConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(cellView.bottom).offset(-1);
                        make.left.equalTo(cellView.tpd_img1);
                        make.right.equalTo(cellView.tpd_img3);
                        make.height.mas_equalTo(0.5f);
                    }];
                    break;
                }
                case BaiduBigImageLayoutType:
                {
                    cellView = (NewsFeedsCellTableViewCell *) [cellView tpd_tableViewCellStyleLabelImageLabel:@[@"", @"", @""] action:nil reuseId:nil];
                    cellView.tpd_label1.numberOfLines = 2;
                    cellView.tpd_label2.numberOfLines = 1;
                    [cellView.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
                        make.height.equalTo(INDEX_ROW_HEIGHT_FIND_NEWS_BIG_IMAGE);
                    }];
                    [cellView addSubview:borderView];
                    [borderView updateConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(cellView.bottom).offset(-1);
                        make.left.equalTo(cellView.tpd_label2);
                        make.right.equalTo(cellView.tpd_label2);
                        make.height.mas_equalTo(0.5f);
                    }];
                    break;
                }
                case BaiduLeftImageLayoutType:
                {
                    cellView =  (NewsFeedsCellTableViewCell *)[cellView tpd_tableViewCellStyleImageLabel2:@[@"", @"", @""] action:nil reuseId:nil];
                    cellView.tpd_label1.numberOfLines = 2;
                    cellView.tpd_label2.numberOfLines = 1;
                    
                    cellView.tpd_img1.contentMode = UIViewContentModeScaleAspectFill;
                    [cellView.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(TPScreenWidth() / 3 - INDEX_ROW_WIDTH_FIND_NEWS_ONE_IMAGE_MARGIN);
                        make.height.mas_equalTo(INDEX_ROW_HEIGHT_FIND_NEWS_ONE_IMAGE);
                        make.top.equalTo(cellView).offset(topMargin);
                        make.left.equalTo(cellView).offset(leftMargin);
                    }];
                    [cellView.tpd_label1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(cellView).offset(-leftMargin);
                        make.left.equalTo(cellView.tpd_img1.right).offset(leftMargin);
                        make.top.equalTo(cellView.tpd_img1.top);
                    }];
                    [cellView.tpd_label2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(cellView).offset(-leftMargin);
                        make.left.equalTo(cellView.tpd_img1.right).offset(leftMargin);
                        make.bottom.equalTo(cellView.tpd_img1).offset(-1);
                    }];
                    [cellView addSubview:borderView];
                    [borderView updateConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(cellView.tpd_img1.bottom).offset(topMargin - 1);
                        make.left.equalTo(cellView.tpd_img1);
                        make.right.equalTo(cellView.tpd_label2);
                        make.height.mas_equalTo(0.5f);
                    }];
                    break;
                }
                default:
                    break;
            }
//            nativeAdView = [[BaiduMobAdNativeAdView alloc] init];
//            [self addSubview:nativeAdView];
//            [nativeAdView makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(self);
//            }];
//            
//            if (cellView) {
//                [cellView setTag:FIND_NEWS_BAIDU_TAG];
//                self.tpd_container = cellView.tpd_container;
//                self.tpd_label1 = cellView.tpd_label1;
//                self.tpd_label2 = cellView.tpd_label2;
//                self.tpd_img1 = cellView.tpd_img1;
//                self.tpd_img2 = cellView.tpd_img2;
//                self.tpd_img3 = cellView.tpd_img3;
//                [nativeAdView addSubview:cellView];
//                [cellView makeConstraints:^(MASConstraintMaker *make) {
//                    make.edges.equalTo(nativeAdView);
//                }];
//            }
            
            break;
        }
        case LeftImageLayoutType:
        {
//            [self tpd_withBorderWidth:1.0f color:[UIColor blueColor]];
            [self tpd_tableViewCellStyleImageLabel2:@[@"", @"", @""] action:self.block reuseId:nil];
            self.tpd_label1.numberOfLines = 2;
            self.tpd_label2.numberOfLines = 1;
            [self.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(TPScreenWidth() / 3 - INDEX_ROW_WIDTH_FIND_NEWS_ONE_IMAGE_MARGIN);
                make.left.equalTo(self.tpd_container).offset(leftMargin);
                make.height.mas_equalTo(INDEX_ROW_HEIGHT_FIND_NEWS_ONE_IMAGE);
                make.top.equalTo(self).offset(FIND_NEWS_MARGIN_TO_IMAGE);
            }];
            [self.tpd_label1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-leftMargin);
                make.left.equalTo(self.tpd_img1.right).offset(leftMargin);
                make.top.equalTo(self.tpd_img1.top);
            }];
            [self.tpd_label2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-leftMargin);
                make.left.equalTo(self.tpd_img1.right).offset(leftMargin);
                make.bottom.equalTo(self.tpd_img1).offset(-1);
            }];
            [self addSubview:borderView];
            [borderView updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bottom).offset(-1);
                make.left.equalTo(self.tpd_img1);
                make.right.equalTo(self.tpd_label2);
                make.height.mas_equalTo(0.5f);
            }];
            break;
        }
        case BigImageLayoutType:
        {
//             [self tpd_withBorderWidth:1.0f color:[UIColor greenColor]];
            
            [self tpd_tableViewCellStyleLabelImageLabel:@[@"", @"", @""] action:self.block reuseId:nil];
            self.tpd_label1.numberOfLines = 2;
            self.tpd_label2.numberOfLines = 1;
            [self.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(INDEX_ROW_HEIGHT_FIND_NEWS_BIG_IMAGE);
            }];
            [self addSubview:borderView];
            [borderView updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bottom).offset(-1);
                make.left.equalTo(self.tpd_label2);
                make.right.equalTo(self.tpd_label2);
                make.height.mas_equalTo(0.5f);
            }];
            break;
        }
        case ThreeImageLayoutType:
        {
//            [self tpd_withBorderWidth:1.0f color:[UIColor redColor]];
            [self tpd_tableViewCellStyleLabelImage3Label:@[@"", @"", @"", @"", @""] action:self.block reuseId:nil];
            self.tpd_label1.numberOfLines = 2;
            self.tpd_label2.numberOfLines = 1;
            [self.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(threeHeight);
            }];
            [self.tpd_img2 updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(threeHeight);
            }];
            [self.tpd_img3 updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(threeHeight);
            }];
            [self.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(topMargin);
                make.bottom.equalTo(self.tpd_img1.top).offset(-topMargin2);
            }];
            [self addSubview:borderView];
            [borderView updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bottom).offset(-1);
                make.left.equalTo(self.tpd_img1);
                make.right.equalTo(self.tpd_img3);
                make.height.mas_equalTo(0.5f);
            }];
            break;
        }
        case NoImageLayoutType:
        {
            UIButton* container = [UIButton tpd_buttonStyleCommon];
            [container addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:self.block];
            [self addSubview:container];
            [container updateConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            self.tpd_label1 = [[UILabel alloc] init];
            self.tpd_label2 = [[UILabel alloc] init];
            self.tpd_label1.numberOfLines = 2;
            self.tpd_label2.numberOfLines = 1;
            [container addSubview:self.tpd_label1];
            [container addSubview:self.tpd_label2];
            [self.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(container).offset(leftMargin);
                make.right.equalTo(container).offset(-leftMargin);
                make.top.equalTo(container).offset(topMargin2);
            }];
            
            [self.tpd_label2 updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.tpd_label1.bottom).offset(topMargin3);
                make.left.right.equalTo(self.tpd_label1);
                make.bottom.equalTo(container).offset(-topMargin2);
            }];
            [container addSubview:borderView];
            [borderView updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bottom).offset(-1);
                make.left.equalTo(self.tpd_label2);
                make.right.equalTo(self.tpd_label2);
                make.height.mas_equalTo(0.5f);
            }];
            self.tpd_container = container;
            break;
        }
        case VideoLayoutType:
        {
            [self tpd_tableViewCellStyleLabelImageLabel:@[@"", @"", @""] action:self.block reuseId:nil];
            self.tpd_label1.numberOfLines = 2;
            self.tpd_label2.numberOfLines = 1;
            
            [self.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(INDEX_ROW_HEIGHT_FIND_NEWS_VIDEO);
            }];
            [self addSubview:borderView];
            [borderView updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bottom).offset(-1);
                make.left.equalTo(self.tpd_label2);
                make.right.equalTo(self.tpd_label2);
                make.height.mas_equalTo(0.5f);
            }];
            
            // video play icon
            UIImageView *iconView = [[UIImageView alloc] init];
            iconView.contentMode = UIViewContentModeScaleAspectFit;
            iconView.image = [TPDialerResourceManager getImage:@"feeds_video_play_icon@3x.png"];
            
            // video play time
            CGFloat timeLabelHeight = 16;
            UILabel *timeLabel = [UILabel tpd_commonLabel];
            timeLabel.textAlignment = NSTextAlignmentCenter;
            timeLabel.font = [UIFont systemFontOfSize:10];
            timeLabel.textColor = [UIColor whiteColor];
            timeLabel.backgroundColor = [UIColor colorWithHexString:@"0X000000" alpha:0.5];
            timeLabel.clipsToBounds = YES;
            timeLabel.layer.cornerRadius = timeLabelHeight / 2;
            
            [self.tpd_img1 addSubview:iconView];
            [self.tpd_img1 addSubview:timeLabel];
            
            [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(self.tpd_img1);
                make.size.mas_equalTo(CGSizeMake(42, 42));
            }];
            [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.tpd_img1.mas_right).offset(-12);
                make.bottom.mas_equalTo(self.tpd_img1.mas_bottom).offset(-12);
                make.size.mas_equalTo(CGSizeMake(34, timeLabelHeight));
            }];
            
            self.videoTimeLabel = timeLabel;
            self.videoPlayImageView = iconView;
            
            break;
        }
        case UpdateRecLayoutType:
        {
            UIButton* container = [UIButton tpd_buttonStyleCommon];
            [container addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
                [wSelf touchEvent];
            }];
            [self addSubview:container];
            [container updateConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            self.tpd_label1 =  [[UILabel tpd_commonLabel] tpd_withText:@"" color:RGB2UIColor(0x333333) font:8];
            self.tpd_label1.numberOfLines = 1;
            self.tpd_label1.font = [UIFont systemFontOfSize:14];
            self.tpd_label1.textColor = RGB2UIColor2(255, 138, 102);
            self.tpd_label1.backgroundColor = RGB2UIColor2(255, 241, 230);
            self.tpd_label1.textAlignment = NSTextAlignmentCenter;
            [container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor2(0, 0, 130)] forState:UIControlStateHighlighted];
            [container addSubview:self.tpd_label1];
            [self.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(container);
            }];
            [self addSubview:borderView];
            [borderView updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bottom).offset(-1.0f);
                make.left.equalTo(self).offset(15);
                make.right.equalTo(self).offset(-15);
                make.height.mas_equalTo(0.5f);
            }];
            borderView.hidden = YES;
            return self;
        }
        default:
            break;
    }
    self.tpd_label1.lineBreakMode = NSLineBreakByTruncatingTail;
    self.tpd_label1.textAlignment = NSTextAlignmentLeft;
    self.tpd_label2.lineBreakMode = NSLineBreakByTruncatingTail;
    self.tpd_label2.textAlignment = NSTextAlignmentLeft;
    self.tpd_label2.textColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
     self.tpd_label2.font = [UIFont systemFontOfSize:FIND_NEWS_SUB_TITLE_SIZE];
    
    highlightView = [[UILabel alloc] init];
    [self.tpd_container addSubview:highlightView];
    self.tpd_container.userInteractionEnabled = NO;
    highlightView.layer.borderWidth = 0.5f;
    highlightView.layer.cornerRadius = 9;
    highlightView.font = [UIFont systemFontOfSize:FIND_NEWS_HOT_SIZE];
    [highlightView updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.tpd_label2);
        make.height.mas_equalTo(16);
        make.right.equalTo(self).offset(-16);
    }];
    
    CGFloat titleSize = FIND_NEWS_NEW_TITLE_SIZE;
    if (isIPhone6Resolution()) {
        if (WIDTH_ADAPT <= 1) {
            titleSize -= 1;
        } else if ( WIDTH_ADAPT > 1.1) {
            titleSize += 1;
        }
    }
    
    if ([[UIDevice currentDevice].systemVersion intValue] >= 9) {
        UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:titleSize];
        self.tpd_label1.font = font;
     } else {
        self.tpd_label1.font = [UIFont systemFontOfSize:titleSize];
    }
    self.tpd_img1.backgroundColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
    self.tpd_img2.backgroundColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
    self.tpd_img3.backgroundColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    startPoint = [touch locationInView:self];
    pressed = YES;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (pressed) {
        pressed = NO;
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (pressed) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGRect rect = CGRectMake(startPoint.x - CLICK_CANCELED_OFFSET, startPoint.y - CLICK_CANCELED_OFFSET,  2 * CLICK_CANCELED_OFFSET, 2 * CLICK_CANCELED_OFFSET);
        if (!CGRectContainsPoint(rect,point)) {
            pressed = NO;
            [self setNeedsDisplay];
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (pressed) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            pressed = NO;
            [self setNeedsDisplay];
            
            if ([[UIDataManager instance] checkDoubleClick]) {
                return;
            }
            if (self.item.category != CategoryADBaidu) {
                [self touchEvent];
            }
            
        });
    }
    
}


-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    //highlight
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, RGB2UIColor2(244, 244, 244).CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
}


- (void) touchEvent
{
    
    self.item.isClicked = YES;
    self.item.ctUrl.queryFeedsRedPacket = !self.item.isAd;
    self.item.ctUrl.needFontSizeSettings = YES;
    [self setNeedsDisplay];
    if (self.item.type.integerValue == FIND_NEWS_TYPE_VIDEO) {
        TPDVideoPlayController *vc = [[TPDVideoPlayController alloc] initWithNewItem:self.item];
        [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
        return;
        
    } else if (self.item.appLaunch) {
        NSDictionary* intent = [self.item.appLaunch objectForKey:@"intent"];
        NSString* schema = [intent objectForKey:@"urlIOS"];
        
        BOOL launchApp = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:schema]];
        if (!launchApp) {
            CTUrl* appUrl = [[CTUrl alloc]initWithJson:[self.item.appLaunch objectForKey:@"link"]];
            UIViewController* controller = [appUrl startWebView];
            if (self.item.tu) {
                AdInfoModel* model;
                if (self.item.isAd) {
                    model = [[AdInfoModel alloc]initWithS:self.item.queryId andTu:self.item.ftu andAdid:self.item.adid];
                } else {
                    model = [[AdInfoModel alloc]initWithS:self.item.queryId andTu:self.item.tu andCtid:self.item.newsId];
                }
                [AdInfoModelManager initWithAd:model webController:controller];
            }
        }
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"selected"), Pair(@"url",self.item.appLaunch),
         Pair(@"tu",self.item.tu), Pair(@"ftu",self.item.ftu),
         Pair(@"edurl",self.item.edMonitorUrl), nil];
    } else {
        if (self.item.category == CategoryUpdateRec) {
            [[NSNotificationCenter defaultCenter]postNotificationName:N_FEEDS_REFRESH object:nil];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"selected"), Pair(@"updateRec",@"true"), nil];
            return;
        }
        if (self.item.category == CategoryADGDT) {
            [self.item.gdtAdNativeObject clickAd:self.item.gdtAdNativeData];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"click"), Pair(@"type", @"GDT"),
             Pair(@"tu",self.item.tu), Pair(@"ftu",self.item.ftu),nil];
        } else {
//            self.item.ctUrl.newWebView = NO;
            self.item.ctUrl.isNews = YES;
            UIViewController* controller = [self.item.ctUrl startWebView];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"selected"), Pair(@"url",self.item.ctUrl.url), Pair(@"edurl",self.item.edMonitorUrl),Pair(@"tu",self.item.tu), Pair(@"ftu",self.item.ftu), nil];
            
            if (self.item.tu) {
                AdInfoModel* model;
                if (self.item.isAd) {
                    model = [[AdInfoModel alloc]initWithS:self.item.queryId andTu:self.item.ftu andAdid:self.item.adid];
                } else {
                    model = [[AdInfoModel alloc]initWithS:self.item.queryId andTu:self.item.tu andCtid:self.item.newsId];
                }
                [AdInfoModelManager initWithAd:model webController:controller];
            }
        }
    }
    [self sendSSPClick];
    [[EdurlManager instance] sendCMonitorUrl:self.item];
    [[EdurlManager instance] removeAllNewsRecordWithCloseType:CLICKCT];
    
}

-(void) sendSSPClick
{
    if (!self.item.isAd) {
        return;
    }
    
    NSInteger sspid = SSPID_DAVINCI;
    if (self.item.category == CategoryADGDT) {
        sspid = SSPID_GDT;
    }
    
    [[SSPStat instance] clickWithSSPid:sspid andTu:TU_FEEDS andRank:[self.item.rank integerValue] andS:self.item.sspS andFtu:[self.item.ftu integerValue]];
}



- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = [FindNewsListViewController heightForFindNewsRow:self.item withHeader:NO];
    return CGSizeMake(size.width, height);
}

- (NSString *) formattedTimeStringWithSeconds:(long)duration {
    int minutes = duration / 60;
    int seconds = duration % 60;
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    return timeString;
}

+ (FeedsLayoutType) typeFromItem:(FindNewsItem *)feedsItem
{
    FeedsLayoutType typeLayout = LeftImageLayoutType;
    
    switch (feedsItem.category) {
        case CategoryNews:
        case CategoryADGDT:
        case CategoryADDavinci:
        {
            switch (feedsItem.type.integerValue) {
                case FIND_NEWS_TYPE_THREE_IMAGE:
                    typeLayout = ThreeImageLayoutType;
                    break;
                case FIND_NEWS_TYPE_ONE_IMAGE:
                    typeLayout = LeftImageLayoutType;
                    break;
                case FIND_NEWS_TYPE_BIG_IMAGE:
                    typeLayout = BigImageLayoutType;
                    break;
                case FIND_NEWS_TYPE_NO_IMAGE:
                    typeLayout = NoImageLayoutType;
                    break;
                case FIND_NEWS_TYPE_VIDEO:
                    typeLayout = VideoLayoutType;
                    break;
                default:
                    break;
            }
            break;
        }
        case CategoryADBaidu:
        {
            switch (feedsItem.type.integerValue) {
                case FIND_NEWS_TYPE_THREE_IMAGE:
                    typeLayout = BaiduThreeImageLayoutType;
                    break;
                case FIND_NEWS_TYPE_BIG_IMAGE:
                    typeLayout = BaiduBigImageLayoutType;
                    break;
                default:
                    typeLayout = BaiduLeftImageLayoutType;
                    break;
            }
            break;
        }
            break;
        case CategoryUpdateRec:
            typeLayout = UpdateRecLayoutType;
            break;
        case CategoryVideo:
            typeLayout = VideoLayoutType;
            break;
        default:
            break;
    }
    return typeLayout;
}

+ (NSString *) identifierFromItem:(FindNewsItem*) item
{
    
    NSString* identifer = @"";

    FeedsLayoutType typeLayout = [NewsFeedsCellTableViewCell typeFromItem:item];
    switch (typeLayout) {
        case LeftImageLayoutType:
            identifer = @"feeds_left_image";
            break;
        case ThreeImageLayoutType:
            identifer = @"feeds_three_image";
            break;
        case BigImageLayoutType:
            identifer = @"feeds_big_image";
            break;
        case NoImageLayoutType:
            identifer = @"feeds_no_image";
            break;
        case UpdateRecLayoutType:
            identifer = @"feeds_update_rec";
            break;
        case BaiduLeftImageLayoutType:
            identifer = @"baidu_left_image";
            break;
        case BaiduThreeImageLayoutType:
             identifer = @"baidu_three_image";
            break;
        case BaiduBigImageLayoutType:
            identifer = @"baidu_big_image";
            break;
        case VideoLayoutType:
            identifer = @"feeds_video";
            break;
        default:
            break;
    }
    return identifer;
}

+ (void) registerCellForUITableView:(UITableView*) table
{
    [table registerClass:[NewsFeedsCellTableViewCell class] forCellReuseIdentifier:@"feeds_left_image"];
    [table registerClass:[NewsFeedsCellTableViewCell class] forCellReuseIdentifier:@"feeds_three_image"];
    [table registerClass:[NewsFeedsCellTableViewCell class] forCellReuseIdentifier:@"feeds_big_image"];
    [table registerClass:[NewsFeedsCellTableViewCell class] forCellReuseIdentifier:@"feeds_no_image"];
    [table registerClass:[NewsFeedsCellTableViewCell class] forCellReuseIdentifier:@"feeds_update_rec"];
    [table registerClass:[NewsFeedsCellTableViewCell class] forCellReuseIdentifier:@"baidu_left_image"];
    [table registerClass:[NewsFeedsCellTableViewCell class] forCellReuseIdentifier:@"baidu_three_image"];
    [table registerClass:[NewsFeedsCellTableViewCell class] forCellReuseIdentifier:@"baidu_big_image"];
    [table registerClass:[NewsFeedsCellTableViewCell class] forCellReuseIdentifier:@"feeds_video"];
}
@end
