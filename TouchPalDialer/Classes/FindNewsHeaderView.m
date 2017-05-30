//
//  FindNewsHeaderView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/24.
//
//

#import "FindNewsHeaderView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "CTUrl.h"
#import "TPAdControlRequestParams.h"

@implementation FindNewsHeaderView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(15, 0, self.frame.size.width - 150, self.frame.size.height)];
        self.title.textColor = [ImageUtils colorFromHexString:FIND_TITLE_COLOR andDefaultColor:nil];
        self.title.font = [UIFont systemFontOfSize:FIND_TITLE_SIZE];
        self.title.textAlignment = NSTextAlignmentLeft;
        self.title.verticalAlignment = VerticalAlignmentMiddle;
        self.title.userInteractionEnabled = YES;
        [self addSubview:self.title];
        self.shortcut = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 140, 0, 110, self.frame.size.height)];
        self.shortcut.textColor = [ImageUtils colorFromHexString:NEWS_SHORTCUT_TEXT_COLOR andDefaultColor:nil];
        self.shortcut.font = [UIFont systemFontOfSize:FIND_TITLE_SIZE];
        self.shortcut.textAlignment = NSTextAlignmentRight;
        self.shortcut.verticalAlignment = VerticalAlignmentMiddle;
        self.shortcut.userInteractionEnabled = YES;
        self.shortcut.text = @"发送到桌面";
        [self addSubview:self.shortcut];
        
        self.shortcutIcon = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 28, 0, 20, self.frame.size.height)];
        self.shortcutIcon.textColor = [ImageUtils colorFromHexString:NEWS_SHORTCUT_TEXT_COLOR andDefaultColor:nil];
        self.shortcutIcon.font = [UIFont fontWithName:IPHONE_ICON_2 size:FIND_TITLE_SIZE];
        self.shortcutIcon.textAlignment = NSTextAlignmentLeft;
        self.shortcutIcon.verticalAlignment = VerticalAlignmentMiddle;
        self.shortcutIcon.userInteractionEnabled = YES;
        self.shortcutIcon.text = @"7";
        [self addSubview:self.shortcutIcon];
        
        [self setTag:FIND_NEWS_HEADER_TAG];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:FIND_NEWS_BG_COLOR andDefaultColor:nil].CGColor);
    CGContextFillRect(context, rect);
    
    if (self.pressed) {
        self.shortcutIcon.textColor = [ImageUtils colorFromHexString:NEWS_SHORTCUT_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil];
        self.shortcut.textColor = [ImageUtils colorFromHexString:NEWS_SHORTCUT_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil];
    } else {
        self.shortcutIcon.textColor = [ImageUtils colorFromHexString:NEWS_SHORTCUT_TEXT_COLOR andDefaultColor:nil];
        self.shortcut.textColor = [ImageUtils colorFromHexString:NEWS_SHORTCUT_TEXT_COLOR andDefaultColor:nil];
    }
//    
//    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:FIND_NEWS_HEADER_BORDER_COLOR andDefaultColor:nil] andFromX:5 andFromY:self.frame.size.height andToX:self.frame.size.width - 5 andToY:self.frame.size.height andWidth: FIND_NEWS_HEADER_BORDER_SIZE];
}

- (void) drawTitle:(NSString *)title
{
    self.title.text = title;
    [self setNeedsDisplay];
}

- (void) doClick
{
    
    
    CTUrl* ctUrl = [[CTUrl alloc] init];
    ctUrl.nativeUrl = [NSDictionary dictionaryWithObjectsAndKeys:@{@"controller":@"FindNewsListViewController",@"tu": [NSString stringWithFormat:@"%d", DSP_FEEDS_TP_NEWS]},@"ios",nil];
    ctUrl.serviceId = @"id_findnews";
    ctUrl.shortCutTitle = @"天天头条";
    ctUrl.shortCutIcon = @"http://search.cootekservice.com/res/image/icon_cootek_news.jpg";
    
    [UserDefaultsManager setObject:[ctUrl jsonFromCTUrl] forKey:[@"shortcut" stringByAppendingString:ctUrl.serviceId]];
    NSString *urlStr;
    if (USE_DEBUG_SERVER) {
        urlStr = [NSString stringWithFormat:@"%@%@service_id=%@&title=%@&icon=%@", YP_DEBUG_SERVER, SHORTCUT_PAGE_PATH, ctUrl.serviceId, ctUrl.shortCutTitle, ctUrl.shortCutIcon];
    } else {
        urlStr = [NSString stringWithFormat:@"%@%@service_id=%@&title=%@&icon=%@", SEARCH_SITE, SHORTCUT_PAGE_PATH, ctUrl.serviceId, ctUrl.shortCutTitle, ctUrl.shortCutIcon];
    }
    NSString *encodeUrl = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodeUrl];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    };
    
}
@end
