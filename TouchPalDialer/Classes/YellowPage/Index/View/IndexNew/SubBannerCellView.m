//
//  SubBannerCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/11.
//
//

#import "SubBannerCellView.h"
#import "IndexConstant.h"
#import "VerticallyAlignedLabel.h"
#import "HighLightView.h"
#import "ImageUtils.h"
#import "UIDataManager.h"
#import "NetworkUtility.h"
#import "EdurlManager.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "CTUrl.h"
#import "AdInfoModelManager.h"
#import "UpdateService.h"
#import "AccountInfoManager.h"

@interface SubBannerCellView()
{
    VerticallyAlignedLabel* title;
    VerticallyAlignedLabel* subTitle;
    VerticallyAlignedLabel* desc;
    HighLightView* highLightView;
    UIImage* icon;
    NSString* url;
    BOOL isLeft;
    
}
@end
@implementation SubBannerCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    float labelWidth = frame.size.width - SMALL_SUBBANNER_ICON_WIDTH;
    
    VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(SUBBANNER_LEFT_MARGIN + SMALL_SUBBANNER_ICON_WIDTH + SUBBANNER_ICON_RIGHT_MARGIN, SUBBANNER_TOP_MARGIN, labelWidth - SUBBANNER_LEFT_MARGIN - SUBBANNER_ICON_RIGHT_MARGIN - SUBBANNER_RIGHT_MARGIN, frame.size.height / 5)];
    label.textColor = [ImageUtils colorFromHexString:SUBBANNER_TITLE_TEXT_COLOR andDefaultColor:nil];
    label.textAlignment = NSTextAlignmentLeft;
    label.verticalAlignment = VerticalAlignmentBottom;
    label.userInteractionEnabled = YES;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.font = [UIFont systemFontOfSize:SUBBANNER_TITLE_SIZE];
    [self addSubview:label];
    title = label;
    
    VerticallyAlignedLabel* subTitleLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(SUBBANNER_LEFT_MARGIN + SMALL_SUBBANNER_ICON_WIDTH + SUBBANNER_ICON_RIGHT_MARGIN, frame.size.height * 3 / 5, labelWidth - SUBBANNER_LEFT_MARGIN - SUBBANNER_RIGHT_MARGIN - SUBBANNER_ICON_RIGHT_MARGIN, frame.size.height * 2 / 5)];
    subTitleLabel.textColor = [ImageUtils colorFromHexString:SUBBANNER_DESC_TEXT_COLOR andDefaultColor:nil];
    subTitleLabel.textAlignment = NSTextAlignmentLeft;
    subTitleLabel.verticalAlignment = VerticalAlignmentTop;
    subTitleLabel.userInteractionEnabled = YES;
    subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    subTitleLabel.font = [UIFont systemFontOfSize:SUBBANNER_SUB_TITLE_SIZE];
    subTitle = subTitleLabel;
    [self addSubview:subTitleLabel];
    
    highLightView = [[HighLightView alloc]initWithFrame:self.bounds];
    [self addSubview:highLightView];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //highlight
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:SUBBANNER_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:SUBBANNER_BG_COLOR andDefaultColor:nil].CGColor);
    }
    CGContextFillRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:SUBBANNER_TITLE_TEXT_COLOR andDefaultColor:nil].CGColor);
    
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:SUBBANNER_BORDER_COLOR andDefaultColor:nil] andFromX:rect.size.width andFromY:COMMON_MARGIN_LINE_SIZE andToX:rect.size.width andToY:rect.size.height - COMMON_MARGIN_LINE_SIZE andWidth:SUBBANNER_BORDER_WIDTH];
    if (isLeft) {
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:SUBBANNER_BORDER_COLOR andDefaultColor:nil]  andFromX:5 andFromY:rect.size.height andToX:rect.size.width andToY:rect.size.height andWidth:SUBBANNER_BORDER_WIDTH];
    } else {
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:SUBBANNER_BORDER_COLOR andDefaultColor:nil]  andFromX:0 andFromY:rect.size.height andToX:rect.size.width-5 andToY:rect.size.height andWidth:SUBBANNER_BORDER_WIDTH];
    }

    
    CGRect iconRect = CGRectMake(SUBBANNER_LEFT_MARGIN, SUBBANNER_TOP_MARGIN, SMALL_SUBBANNER_ICON_WIDTH, SMALL_SUBBANNER_ICON_WIDTH);
        
    [icon drawInRect:iconRect];
}

- (void) doClick {
    
    
    UIViewController* controller = [self.item.ctUrl startWebView];
   
    if(self.item.reloadAssetAfterBack) {
        [[AccountInfoManager instance] setRequestAccountInfo:YES];
    }
    
    if (self.item.tu) {
        AdInfoModel* model = [[AdInfoModel alloc]initWithS:self.item.s andTu:self.item.tu andAdid:self.item.adid];
        [AdInfoModelManager initWithAd:model webController:controller];
    }
    
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_SUBBANER_ITEM kvs:Pair(@"action", @"selected"), Pair(@"url",self.item.ctUrl.url), Pair(@"edurl",self.item.edMonitorUrl), nil];
    
    [[EdurlManager instance] sendCMonitorUrl:self.item];
    
}

- (void) drawView:(SubBannerItem*) bannerItem
{
    float labelWidth = self.frame.size.width - SMALL_SUBBANNER_ICON_WIDTH;
    title.frame = CGRectMake(SUBBANNER_LEFT_MARGIN + SMALL_SUBBANNER_ICON_WIDTH + SUBBANNER_ICON_RIGHT_MARGIN, SUBBANNER_TOP_MARGIN, labelWidth - SUBBANNER_LEFT_MARGIN - SUBBANNER_RIGHT_MARGIN - SUBBANNER_ICON_RIGHT_MARGIN, self.frame.size.height / 5);
    title.text = bannerItem.title;
    title.textColor = [ImageUtils colorFromHexString:bannerItem.titleColor andDefaultColor:[ImageUtils colorFromHexString:SUBBANNER_TITLE_TEXT_COLOR andDefaultColor:nil]];
    subTitle.frame = CGRectMake(SUBBANNER_LEFT_MARGIN + SMALL_SUBBANNER_ICON_WIDTH + SUBBANNER_ICON_RIGHT_MARGIN, self.frame.size.height * 3 / 5, labelWidth - SUBBANNER_LEFT_MARGIN - SUBBANNER_RIGHT_MARGIN - SUBBANNER_ICON_RIGHT_MARGIN, self.frame.size.height * 2 / 5);
    subTitle.text = bannerItem.subTitle;
    subTitle.textColor = [ImageUtils colorFromHexString:bannerItem.subTitleColor andDefaultColor:[ImageUtils colorFromHexString:SUBBANNER_TITLE_SUB_TEXT_COLOR andDefaultColor:nil]];
    
    url = bannerItem.image;
    if (icon == nil && url.length > 0) {
        icon = [ImageUtils getImageFromLocalWithUrl:url];
    }
    if (icon == nil && url.length > 0) {
        [self performSelectorInBackground:@selector(downloadImageFromNetwork) withObject:nil];
    }
    
    if ([bannerItem shouldShowHighLight]) {
        [self drawHighLightView:bannerItem.highlightItem];
    } else {
        [self drawHighLightView:nil];
    }
    [self setNeedsDisplay];
    if (bannerItem.edMonitorUrl) {
        [[EdurlManager instance] requestEdurl:bannerItem.edMonitorUrl];
    }
}

- (void)downloadImageFromNetwork
{
    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
    if(save){
        dispatch_sync(dispatch_get_main_queue(), ^{
            icon = [ImageUtils getImageFromLocalWithUrl:url];
            [self setNeedsDisplay];
        });
    }
}

- (void) drawHighLightView:(HighLightItem*)highLightItem
{
    if (highLightItem && highLightItem.type.length > 0) {
        if ([STYLE_HIGHLIGHT_TYPE_NORMAL isEqualToString:highLightItem.type]
            || [STYLE_HIGHLIGHT_TYPE_RECTANGLE isEqualToString:highLightItem.type]) {
            [highLightView drawView:highLightItem andPoints:nil withLine:YES];
        } else {
            [highLightView drawView:nil andPoints:nil withLine:NO];
        }
    } else {
        [highLightView drawView:nil andPoints:nil withLine:NO];
    }
}

- (void) resetWithData:(SubBannerItem* )data withColumn:(int)column withTotalCount:(NSInteger)allColum
{
    self.item = data;
    if (allColum % 2) {
        if (allColum >=3 ) {
            if (column>=3) {
                isLeft = (column % 2);
            } else {
                isLeft = NO;
            }
        }else {
             isLeft = NO;
        }
        
    } else {
         isLeft = ((column + 1) % 2);
    }
    icon = nil;
    [self drawView:self.item];
}

@end
