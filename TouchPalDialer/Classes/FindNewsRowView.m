//
//  FindNewsRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/23.
//
//

#import "FindNewsRowView.h"
#import "FindNewsItem.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "CTUrl.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "UpdateService.h"
#import "SectionGroup.h"
#import "IndexData.h"
#import "SectionFindNews.h"
#import "EdurlManager.h"
#import "AdInfoModelManager.h"
#import "UIImageView+WebCache.h"
#import "FindNewsListViewController.h"
#import "BaiduMobAdNativeAdView.h"
#import "SSPStat.h"
#import "TPDialerResourceManager.h"
#import <DateTools.h>

@interface FindNewsRowView()
{
    BaiduMobAdNativeAdView* baiduView;
}

@end

@implementation FindNewsRowView

@synthesize titleBigImage;
@synthesize titleRightImage;
@synthesize titleNoImage;
@synthesize subTitleLeft;
@synthesize subTitleLeftNOImage;
@synthesize subTitleBottom;
@synthesize bigImage;
@synthesize rightImage;
@synthesize bottomImages;

- (id)initWithFrame:(CGRect)frame andData:(FindNewsItem *)data andIndexPath:(NSIndexPath*)indexPath isV6:(BOOL)v6Version
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.isV6 = v6Version;
        self.backgroundColor = [UIColor clearColor];
        [self resetDataWithFindNewsItem:data andIndexPath:indexPath];
        if(CategoryADBaidu != data.category) {
            [self setTag:FIND_NEWS_TAG];
        } else {
            [self setTag:FIND_NEWS_BAIDU_TAG];
        }
    }
    
    return self;
}

- (void) resetFrame
{
//    for (id object in self.subviews)
//    {
//        [object removeFromSuperview];
//    }
    
    CGFloat totleHeight = [FindNewsListViewController heightForFindNewsRow:self.item withHeader:self.path.row == 0 && self.path.section > 0];
    
    //TODO 为了适配首页以外的触宝新闻，对第一条的显示加了section大于0的判定，在触宝新闻里section＝0，所以可以过滤掉触宝新闻
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, totleHeight);
    
    if (totleHeight < 0.01f) {
        return ;
    }
    
    CGFloat startX = FIND_NEWS_LEFT_MARGIN;
    CGFloat startY = FIND_NEWS_TOP_MARGIN;
    if (self.path.row == 0 && self.path.section > 0) {
        if (!self.header) {
        self.header = [[FindNewsHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, INDEX_ROW_HEIGHT_FIND_NEWS_HEADER)];
        [self addSubview:self.header];
        } else {
            self.header.frame = CGRectMake(0, 0, self.frame.size.width, INDEX_ROW_HEIGHT_FIND_NEWS_HEADER);
        }
        
        
        [self.header drawTitle:FIND_NEWS_TITLE];
        self.header.hidden = NO;
        startY = startY + INDEX_ROW_HEIGHT_FIND_NEWS_HEADER;
    } else {
        self.header.hidden = YES;
    }
    
    
    CGFloat titleHeight = [FindNewTitleView getHeightByTitle:self.item.title withWidth:self.frame.size.width - 2 * FIND_NEWS_LEFT_MARGIN] + 1;
    
        if (self.titleBigImage) {
            self.titleBigImage.frame = CGRectMake(startX, startY, self.frame.size.width - 2 * FIND_NEWS_LEFT_MARGIN , titleHeight);
        } else {
    self.titleBigImage = [[FindNewTitleView alloc]initWithFrame:CGRectMake(startX, startY, self.frame.size.width - FIND_NEWS_LEFT_MARGIN * 2, titleHeight)];
    [self addSubview:self.titleBigImage];
        }
    
    CGFloat width = (self.frame.size.width - FIND_NEWS_LEFT_MARGIN * 2) / 3 - 2;
    
    CGFloat rightHeight = [FindNewTitleView getHeightByTitle:self.item.title withWidth:self.frame.size.width - startX - width - 2 * FIND_NEWS_LEFT_MARGIN] + 5;
    
        if (self.titleRightImage) {
            self.titleRightImage.frame = CGRectMake(startX, startY, self.frame.size.width - startX - width - 2 * FIND_NEWS_LEFT_MARGIN, rightHeight);
        } else {
    
    
    CGFloat rgithImageStartY = startY + (self.frame.size.height - FIND_NEWS_TOP_MARGIN - startY - rightHeight - 20) / 2;
    self.titleRightImage = [[FindNewTitleView alloc]initWithFrame:CGRectMake(startX, rgithImageStartY, self.frame.size.width - startX - width - 2 * FIND_NEWS_LEFT_MARGIN, rightHeight)];
    [self addSubview:self.titleRightImage];
        }
    
        if (self.subTitleLeftNOImage) {
            self.subTitleLeftNOImage.frame = CGRectMake(0, self.frame.size.height - 35, self.frame.size.width - 2*FIND_NEWS_LEFT_MARGIN, 35);
        } else {
    self.subTitleLeftNOImage = [[FindNewsSubTitleView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 35, self.frame.size.width - 2*FIND_NEWS_LEFT_MARGIN, 35)];
    [self addSubview:self.subTitleLeftNOImage];
        }
    
        if (self.titleNoImage) {
            self.titleNoImage.frame = CGRectMake(startX, startY, self.frame.size.width - FIND_NEWS_LEFT_MARGIN * 2, titleHeight);
        } else {
    self.titleNoImage = [[FindNewTitleView alloc]initWithFrame:CGRectMake(startX, startY, self.frame.size.width - FIND_NEWS_LEFT_MARGIN * 2, titleHeight)];
    [self addSubview:self.titleNoImage];
        }
    
        if (self.subTitleLeft) {
            self.subTitleLeft.frame = CGRectMake(0, self.titleRightImage.frame.origin.y + self.titleRightImage.frame.size.height,  self.frame.size.width - width - 2 * FIND_NEWS_LEFT_MARGIN, 20);
        } else {
    self.subTitleLeft = [[FindNewsSubTitleView alloc]initWithFrame:CGRectMake(0, self.titleRightImage.frame.origin.y + self.titleRightImage.frame.size.height,  self.frame.size.width - width - 2 * FIND_NEWS_LEFT_MARGIN, 20)];
    [self addSubview:self.subTitleLeft];
        }
    
        if (self.subTitleBottom) {
            self.subTitleBottom.frame = CGRectMake(0, self.frame.size.height - 30, self.frame.size.width - 2*FIND_NEWS_LEFT_MARGIN, 40);
        } else {
    self.subTitleBottom = [[FindNewsSubTitleView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width - 2*FIND_NEWS_LEFT_MARGIN, 40)];
    [self addSubview:self.subTitleBottom];
        }
    
        if (self.bigImage) {
            self.bigImage.frame = CGRectMake(startX, self.titleBigImage.frame.origin.y + self.titleBigImage.frame.size.height + FIND_NEWS_MARGIN_TO_IMAGE, self.frame.size.width - 2*FIND_NEWS_LEFT_MARGIN, self.frame.size.height - self.titleBigImage.frame.size.height - self.subTitleBottom.frame.size.height - 2 * FIND_NEWS_MARGIN_TO_IMAGE);
        } else {
    self.bigImage = [[UIImageView alloc]initWithFrame:CGRectMake(startX, self.titleBigImage.frame.origin.y + self.titleBigImage.frame.size.height + FIND_NEWS_MARGIN_TO_IMAGE, self.frame.size.width - 2*FIND_NEWS_LEFT_MARGIN, self.frame.size.height - self.titleBigImage.frame.size.height - self.subTitleBottom.frame.size.height - 2 * FIND_NEWS_MARGIN_TO_IMAGE)];
    [self addSubview:self.bigImage];
        }
    
        if (self.rightImage) {
            self.rightImage.frame = CGRectMake(self.frame.size.width - width - FIND_NEWS_LEFT_MARGIN, startY, width, self.frame.size.height - FIND_NEWS_TOP_MARGIN - startY);
        } else {
    self.rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - width - FIND_NEWS_LEFT_MARGIN, startY, width, self.frame.size.height - FIND_NEWS_TOP_MARGIN - startY)];
    [self addSubview:self.rightImage];
        }
    
    startX = FIND_NEWS_LEFT_MARGIN;
    startY = self.titleBigImage.frame.origin.y + self.titleBigImage.frame.size.height;
    CGFloat height = self.subTitleBottom.frame.origin.y - self.titleBigImage.frame.origin.y - self.titleBigImage.frame.size.height - 2 * FIND_NEWS_TOP_MARGIN;
        if (self.bottomImages) {
            for (UIView* view in self.bottomImages) {
                view.frame = CGRectMake(startX, startY + FIND_NEWS_TOP_MARGIN, width, height);
                startX = startX + width + 3;
            }
        } else {
    self.bottomImages = [NSArray arrayWithObjects:[[UIImageView alloc]initWithFrame:CGRectMake(startX, startY + FIND_NEWS_TOP_MARGIN, width, height)],[[UIImageView alloc]initWithFrame:CGRectMake(startX + width + 3, startY + FIND_NEWS_TOP_MARGIN, width, height)], [[UIImageView alloc]initWithFrame:CGRectMake(startX + 2 * width + 6, startY + FIND_NEWS_TOP_MARGIN, width, height)], nil];
    for (UIView* view in self.bottomImages) {
        [self addSubview:view];
    }
        }
    
    [self.bigImage setContentMode:UIViewContentModeScaleToFill];
    
    [self.rightImage setContentMode:UIViewContentModeScaleToFill];
    
    for (UIImageView* image in self.bottomImages) {
        [image setContentMode:UIViewContentModeScaleToFill];
    }
    
    // video play icon
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.hidden = YES;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.image = [TPDialerResourceManager getImage:@"feeds_video_play_icon@3x.png"];
    self.videoPlayImageView = iconView;
    
    // video play time
    CGFloat timeLabelHeight = 16;
    UILabel *timeLable = [UILabel tpd_commonLabel];
    timeLable.hidden = YES;
    timeLable.textAlignment = NSTextAlignmentCenter;
    timeLable.font = [UIFont systemFontOfSize:10];
    timeLable.textColor = [UIColor whiteColor];
    timeLable.backgroundColor = [UIColor colorWithHexString:@"0X000000" alpha:0.5];
    timeLable.clipsToBounds = YES;
    timeLable.layer.cornerRadius = timeLabelHeight / 2;
    self.videoTimeLabel = timeLable;

    [self addSubview:self.videoPlayImageView];
    [self addSubview:self.videoTimeLabel];
    
    [self.videoPlayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.bigImage);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    [self.videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bigImage.right).offset(-12);
        make.bottom.mas_equalTo(self.bigImage.bottom).offset(-12);
        make.size.mas_equalTo(CGSizeMake(34, timeLabelHeight));
    }];
}

- (void) resetDataWithFindNewsItem:(FindNewsItem *)data andIndexPath:(NSIndexPath *)indexPath
{
    
    self.item = data;
    self.path = indexPath;
    [self resetFrame];
    [self hideAllViews];
    
    if (!self.isV6) {
            for (NSString* url in data.images) {
                NSString* filePath = [ImageUtils getImageFilePath:[CTUrl encodeUrl:url] withTag:FIND_NEWS_PATH_TAG];
                if (![self fileExist:filePath]) {
                    [self performSelectorInBackground:@selector(downloadImageFromNetwork) withObject:nil];
                    break;
                }
            }
    }

    
    long timeLong = 0;
    if (self.item.timestamp && self.item.timestamp.length > 0) {
        timeLong = [self.item.timestamp longLongValue];
    }
    NSString* time = [self revertTimeFormat: timeLong];
    NSString* desc = self.item.subTitle;
    switch (self.item.category) {
        case CategoryNews:
        case CategoryADDavinci: {
            break;
        }
        case CategoryADBaidu: {
            desc = AD_SOURCE_BAIDU;
            break;
        }
        case CategoryADGDT: {
            [self.item.gdtAdNativeObject attachAd:self.item.gdtAdNativeData toView:self];
            desc = AD_SOURCE_GDT;
            break;
        }
        default:
            break;
    }
    NSString* subTitle = [NSString stringWithFormat:@"%@ %@", desc, time];
    
    int layout = self.item.type.intValue;
    self.videoTimeLabel.hidden = (layout != FIND_NEWS_TYPE_VIDEO);
    self.videoPlayImageView.hidden = (layout != FIND_NEWS_TYPE_VIDEO);
    
    switch (layout) {
        case FIND_NEWS_TYPE_BIG_IMAGE:
            
            self.titleBigImage.hidden = NO;
            self.bigImage.hidden = NO;
            self.subTitleBottom.hidden = NO;
            self.subTitleBottom.isAd = self.item.isAd;
            self.titleBigImage.title = self.item.title;
            self.titleBigImage.isClicked = self.item.isClicked;
            
            if (self.item.images.count > 0) {
                if (_isV6) {
                    [self.bigImage sd_setImageWithURL:[NSURL URLWithString:[self.item.images objectAtIndex:0]]];
                } else {
                    self.bigImage.image = [ImageUtils getImageFromLocalWithUrl:[self.item.images objectAtIndex:0] andTag:FIND_NEWS_PATH_TAG];
                }
            }
            self.subTitleBottom.title = subTitle;
            self.subTitleBottom.hots = self.item.hotKeys;
            self.subTitleBottom.highLightFlags = self.item.highlightFlags;
            [self.subTitleBottom setNeedsDisplay];
            [self.titleBigImage setNeedsDisplay];
            break;
        case FIND_NEWS_TYPE_ONE_IMAGE:
            self.titleRightImage.hidden = NO;
            self.subTitleLeft.hidden = NO;
            self.rightImage.hidden = NO;
            
            self.subTitleLeft.isAd = self.item.isAd;
            self.subTitleLeft.isLeft = YES;
            self.titleRightImage.title = self.item.title;
            self.titleRightImage.isClicked = self.item.isClicked;
            self.subTitleLeft.title = subTitle;
            self.subTitleLeft.hots = self.item.hotKeys;
            self.subTitleLeft.highLightFlags = self.item.highlightFlags;
            if (self.item.images.count > 0) {
                
                if (self.isV6) {
                    [self.rightImage sd_setImageWithURL:[NSURL URLWithString:[self.item.images objectAtIndex:0] ]];
                } else {
                    self.rightImage.image = [ImageUtils getImageFromLocalWithUrl:[self.item.images objectAtIndex:0] andTag:FIND_NEWS_PATH_TAG];
                }
            }
            [self.subTitleLeft setNeedsDisplay];
            [self.titleRightImage setNeedsDisplay];
            break;
        case FIND_NEWS_TYPE_NO_IMAGE:
            self.titleNoImage.hidden = NO;
            self.subTitleLeftNOImage.hidden = NO;
            self.titleNoImage.isClicked = self.item.isClicked;
            
            self.subTitleLeftNOImage.isAd = self.item.isAd;
            self.titleNoImage.title = self.item.title;
            self.subTitleLeftNOImage.title = subTitle;
            self.subTitleLeftNOImage.hots = self.item.hotKeys;
            self.subTitleLeftNOImage.highLightFlags = self.item.highlightFlags;
            [self.subTitleLeftNOImage setNeedsDisplay];
            [self.titleNoImage setNeedsDisplay];
            
            break;
        case FIND_NEWS_TYPE_THREE_IMAGE:
        {
            self.titleBigImage.hidden = NO;
            self.subTitleBottom.hidden = NO;
            self.titleBigImage.isClicked = self.item.isClicked;
            for (UIImageView* image in self.bottomImages) {
                image.hidden = NO;
            }
            
            self.subTitleBottom.isAd = self.item.isAd;
            self.titleBigImage.title = self.item.title;
            self.subTitleBottom.title = subTitle;
            self.subTitleBottom.hots = self.item.hotKeys;
            self.subTitleBottom.highLightFlags = self.item.highlightFlags;
            for (int i = 0; i < 3 && i < self.item.images.count; i++) {
                NSString* url = [self.item.images objectAtIndex:i];
                UIImageView* imageView = [self.bottomImages objectAtIndex:i];
                if (self.isV6) {
                     [imageView sd_setImageWithURL:[NSURL URLWithString:url]];
                } else {
                    imageView.image = [ImageUtils getImageFromLocalWithUrl:url andTag:FIND_NEWS_PATH_TAG];
                }
                [imageView setNeedsDisplay];
            }
            [self.subTitleBottom setNeedsDisplay];
            [self.titleBigImage setNeedsDisplay];
            break;
        }
        case FIND_NEWS_TYPE_VIDEO: {
            self.titleBigImage.hidden = NO;
            self.bigImage.hidden = NO;
            self.subTitleBottom.hidden = NO;
            self.subTitleBottom.isAd = self.item.isAd;
            self.titleBigImage.title = self.item.title;
            self.titleBigImage.isClicked = self.item.isClicked;
            
            if (self.item.images.count > 0) {
                if (_isV6) {
                    [self.bigImage sd_setImageWithURL:[NSURL URLWithString:[self.item.images objectAtIndex:0]] placeholderImage:[TPDialerResourceManager getImage:@"feeds_video_preview_placeholder_big@3x.png"]];
                } else {
                    self.bigImage.image = [ImageUtils getImageFromLocalWithUrl:[self.item.images objectAtIndex:0] andTag:FIND_NEWS_PATH_TAG];
                }
            }
            self.subTitleBottom.title = subTitle;
            self.subTitleBottom.hots = self.item.hotKeys;
            self.subTitleBottom.highLightFlags = self.item.highlightFlags;
            self.videoTimeLabel.text = [self formattedTimeStringWithSeconds:self.item.duration];
            [self.subTitleBottom setNeedsDisplay];
            [self.titleBigImage setNeedsDisplay];
            
            break;
        }
        default:
            break;
    }
    [self setNeedsDisplay];
    [[EdurlManager instance] addNewsRecord:indexPath andNewsInfo:data];
}

- (NSString *) formattedTimeStringWithSeconds:(long)duration {
    int minutes = duration / 60;
    int seconds = duration % 60;
    NSString *time = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    return time;
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

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    //highlight
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:FIND_NEWS_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:FIND_NEWS_BORDER_COLOR andDefaultColor:nil] andFromX:5 andFromY:self.frame.size.height  andToX:self.frame.size.width - 10 andToY:self.frame.size.height andWidth:0.3f];
}

- (void) hideAllViews
{
    self.titleBigImage.hidden = YES;
    self.titleRightImage.hidden = YES;
    self.titleNoImage.hidden = YES;
    self.subTitleLeft.hidden = YES;
    self.subTitleLeftNOImage.hidden = YES;
    self.subTitleBottom.hidden = YES;
    self.bigImage.hidden = YES;
    self.rightImage.hidden = YES;
    for (UIImageView* image in self.bottomImages) {
        image.hidden = YES;
    }
}

- (void)downloadImageFromNetwork
{
    if (self) {
        __weak FindNewsItem* weakItem = self.item;
        BOOL isSave = NO;
        
        for (NSString* url in self.item.images) {
            isSave = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url andTag:FIND_NEWS_PATH_TAG];
        }
        if (isSave) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakItem == self.item) {
                    [self resetDataWithFindNewsItem:self.item andIndexPath:self.path];
                }
            });
        }
    }
}

-(BOOL) fileExist:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


-(void) doClick
{
    //TODO
    //    self.item.appLaunch = [NSDictionary dictionaryWithObjectsAndKeys:@{@"urlIOS":@"dianping://shopinfo?id=14897722&utm=w_mshop_auto&utm_source=adef4a0d-74a4-b0ff-7fe1-4d4cc833ea27.1456209852"},@"intent",@{@"url":@"http://evt.dianping.com/synthesislink/5301.html?shopId=14897722&utm_=w_mshop_bottom&utm_source="},@"link",nil];
    
    self.item.isClicked = YES;
    self.item.ctUrl.queryFeedsRedPacket = !self.item.isAd;
    self.item.ctUrl.needFontSizeSettings = YES;
    [self setNeedsDisplay];
    if (self.item.appLaunch) {
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
        if (self.item.category == CategoryADGDT) {
            [self.item.gdtAdNativeObject clickAd:self.item.gdtAdNativeData];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"click"), Pair(@"type", @"GDT"),
             Pair(@"tu",self.item.tu), Pair(@"ftu",self.item.ftu),nil];
        } else {
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

@end
