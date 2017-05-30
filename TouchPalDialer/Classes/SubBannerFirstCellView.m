//
//  SubBannerFirstCellView.m
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 15/12/16.
//
//

#import "SubBannerFirstCellView.h"
#import "VerticallyAlignedLabel.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "HighLightView.h"
#import <Foundation/Foundation.h>
#import "EdurlManager.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "AdInfoModelManager.h"
#import "UpdateService.h"

@interface SubBannerFirstCellView()
{
    VerticallyAlignedLabel* title;
    VerticallyAlignedLabel* subTitle;
    VerticallyAlignedLabel* desc;
    HighLightView* highLightView;
    UIImage* icon;
    UIImage* iconPressed;
    NSString* url;
    BOOL isLeft;
}
@end

@implementation SubBannerFirstCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    VerticallyAlignedLabel* titleLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(SUBBANNER_LEFT_MARGIN, SUBBANNER_LARGE_TOP_MARGIN, frame.size.width - SUBBANNER_LEFT_MARGIN - SUBBANNER_LARGE_RIGHT_MARGIN, frame.size.height * 1 / 5)];
    titleLabel.textColor = [ImageUtils colorFromHexString:SUBBANNER_TITLE_TEXT_COLOR andDefaultColor:nil];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.verticalAlignment = VerticalAlignmentTop;
    titleLabel.userInteractionEnabled = YES;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.font = [UIFont systemFontOfSize:FIRST_SUBBANNER_TITLE_SIZE];
    title = titleLabel;
    [self addSubview:titleLabel];
    
    VerticallyAlignedLabel* subTitleLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(SUBBANNER_LEFT_MARGIN, frame.size.height /  4, frame.size.width - SUBBANNER_LEFT_MARGIN - SUBBANNER_LARGE_RIGHT_MARGIN, frame.size.height / 4)];
    subTitleLabel.textColor = [ImageUtils colorFromHexString:SUBBANNER_TITLE_SUB_TEXT_COLOR andDefaultColor:nil];
    subTitleLabel.textAlignment = NSTextAlignmentLeft;
    subTitleLabel.verticalAlignment = VerticalAlignmentTop;
    subTitleLabel.userInteractionEnabled = YES;
    subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    subTitleLabel.font = [UIFont systemFontOfSize:FIRST_SUBBANNER_SUB_TITLE_SIZE];
    subTitle = subTitleLabel;
    [self addSubview:subTitleLabel];
    
    highLightView = [[HighLightView alloc]initWithFrame:self.bounds];
    [self addSubview:highLightView];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
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
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:SUBBANNER_BORDER_COLOR andDefaultColor:nil] andFromX:5 andFromY:rect.size.height andToX:rect.size.width andToY:rect.size.height andWidth:SUBBANNER_BORDER_WIDTH];
    CGRect iconRect = CGRectMake(self.frame.size.width - LARGE_SUBBANNER_RIGHT_MARGIN - LARGE_SUBBANNER_ICON_HEIGHT * 2, self.frame.size.height / 2, LARGE_SUBBANNER_ICON_HEIGHT * 2, LARGE_SUBBANNER_ICON_HEIGHT);
    
    
    if (self.pressed) {
        [iconPressed drawInRect:iconRect];
    } else {
        [icon drawInRect:iconRect];
    }
}

- (void) doClick {
    UIViewController* controller = [self.item.ctUrl startWebView];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_SUBBANER_ITEM kvs:Pair(@"action", @"selected"), Pair(@"url",self.item.ctUrl.url), Pair(@"edurl",self.item.edMonitorUrl), nil];
   
    if (self.item.tu) {
        AdInfoModel* model = [[AdInfoModel alloc]initWithS:self.item.s andTu:self.item.tu andAdid:self.item.adid];
        [AdInfoModelManager initWithAd:model webController:controller];
    }
    
    [[EdurlManager instance] sendCMonitorUrl:self.item];
    
}

- (void) drawView:(SubBannerItem*) subBannerItem
{
    title.frame = CGRectMake(SUBBANNER_LEFT_MARGIN, SUBBANNER_LARGE_TOP_MARGIN, self.frame.size.width - SUBBANNER_LEFT_MARGIN - SUBBANNER_LARGE_RIGHT_MARGIN, self.frame.size.height * 1 / 5);
    subTitle.frame = CGRectMake(SUBBANNER_LEFT_MARGIN, self.frame.size.height /  4, self.frame.size.width - SUBBANNER_LEFT_MARGIN - SUBBANNER_LARGE_RIGHT_MARGIN, self.frame.size.height / 4);
    title.text = subBannerItem.title;
    title.textColor = [ImageUtils colorFromHexString:subBannerItem.titleColor andDefaultColor:[ImageUtils colorFromHexString:SUBBANNER_TITLE_TEXT_COLOR andDefaultColor:nil]];
    subTitle.text = subBannerItem.subTitle;
    subTitle.textColor = [ImageUtils colorFromHexString:subBannerItem.subTitleColor andDefaultColor:[ImageUtils colorFromHexString:SUBBANNER_TITLE_SUB_TEXT_COLOR andDefaultColor:nil]];
    
    url = subBannerItem.bigImage;
    if (icon == nil && url.length > 0) {
        icon = [ImageUtils getImageFromLocalWithUrl:url];
    }
    if (icon == nil && url.length > 0) {
        [self performSelectorInBackground:@selector(downloadImageFromNetwork) withObject:nil];
    }
    
    if (icon) {
        iconPressed = [self imageByApplyingAlpha:0.2f image:icon];
    }
    
    if ([subBannerItem shouldShowHighLight]) {
        [self drawHighLightView:subBannerItem.highlightItem];
    } else {
        [self drawHighLightView:nil];
    }
    [self setNeedsDisplay];
    if (subBannerItem.edMonitorUrl) {
        [[EdurlManager instance] requestEdurl:subBannerItem.edMonitorUrl];
    }
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image

{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (void)downloadImageFromNetwork
{
    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
    if(save){
        dispatch_sync(dispatch_get_main_queue(), ^{
            icon = [ImageUtils getImageFromLocalWithUrl:url];
            if (icon) {
                iconPressed = [self imageByApplyingAlpha:0.2f image:icon];
            }
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
    if(self.hidden){
        return;
    }
    self.item = data;
    isLeft = (column + 1) % 2;
    icon = nil;
    iconPressed = nil;
    [self drawView:self.item];
}

@end