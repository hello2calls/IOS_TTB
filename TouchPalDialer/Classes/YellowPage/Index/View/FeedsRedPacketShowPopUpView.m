//
//  FeedsRedPackPopUpView.m
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import "FeedsRedPacketShowPopUpView.h"
#import "CootekNotifications.h"
#import "YPImageView.h"
#import "FeedsRedPacketManager.h"
#import "FindNewsListViewController.h"
#import "TPAdControlRequestParams.h"
#import "TouchPalDialerAppDelegate.h"
#import "IndexConstant.h"
#import "VerticallyAlignedLabel.h"
#import "ImageUtils.h"

#define MARGIN_LEFT 30
#define MARGIN_BOTTOM 78

@interface FeedsRedPacketShowPopUpView()
{
    VerticallyAlignedLabel* contentLabel1;
    VerticallyAlignedLabel* contentLabel2;
}
@end
@implementation FeedsRedPacketShowPopUpView

-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    return self;
}

- (instancetype) initWithContent:(NSString *)content1 content2:(NSString *)content2
{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if (self) {
        int startX = MARGIN_LEFT;
        int imageWidth = TPScreenWidth() - 2 * MARGIN_LEFT;
        int imageHeight = imageWidth * 1520 / 1200;
        int startY = self.frame.size.height - imageHeight - MARGIN_BOTTOM;

        
        int closeWidth = 30;
        int closeHeight = 30;
        self.closeView = [[YPImageView alloc] initWithFrame:CGRectMake(startX + imageWidth - closeWidth , startY - closeHeight - 20, closeWidth, closeHeight)];
        NSString *closePath = [[NSBundle mainBundle] pathForResource:FEEDS_RED_PACKET_CLOSE_ICON_PATH ofType:@"png"];
        self.closeView.imageView.image = [UIImage imageWithContentsOfFile:closePath];
        __weak FeedsRedPacketShowPopUpView* weakSelf = self;
        self.closeView.block =^(){
            [weakSelf closeSelf];
        };
        
        [self addSubview:self.closeView];
        
        NSString *bgPath = [[NSBundle mainBundle] pathForResource:FEEDS_RED_PACKET_SHOW_BG_PATH ofType:@"png"];
        self.imageView = [[YPImageView alloc] initWithFrame:CGRectMake(startX, startY, imageWidth, imageHeight)];
        self.imageView.imageView.image = [UIImage imageWithContentsOfFile:bgPath];
        self.imageView.frame = CGRectMake(startX, startY, imageWidth, imageHeight);
        [self addSubview:self.imageView];
        
        //draw title
        
        int startContentY1 = startY + self.imageView.frame.size.height * 3 / 5;
        contentLabel1 = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(startX, startContentY1, self.imageView.frame.size.width, 40)];
        contentLabel1.verticalAlignment = VerticalAlignmentMiddle;
        contentLabel1.textAlignment = NSTextAlignmentCenter;
        contentLabel1.text = content1;
        contentLabel1.textColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_TEXT_COLOR andDefaultColor:nil];
        contentLabel1.font = [UIFont systemFontOfSize:FEEDS_RED_PACKET_TEXT_TEXTSIZE];
        [self addSubview:contentLabel1];
        
         int startContentY2 = startY + self.imageView.frame.size.height * 3 / 5 + contentLabel1.frame.size.height;
        contentLabel2 = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(startX, startContentY2, self.imageView.frame.size.width, 40)];
        contentLabel2.verticalAlignment = VerticalAlignmentMiddle;
        contentLabel2.textAlignment = NSTextAlignmentCenter;
        contentLabel2.text = content2;
        contentLabel2.textColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_TEXT_COLOR andDefaultColor:nil];
         contentLabel2.font = [UIFont systemFontOfSize:FEEDS_RED_PACKET_TEXT_TEXTSIZE];
        [self addSubview:contentLabel2];
        
        self.block = ^{
            [weakSelf closeSelf];
        };
    }
    
    return self;
}

- (void) drawContent:(NSString *) content1 content2:(NSString *)content2
{
    contentLabel1.text = content1;
    contentLabel2.text = content2;
}

-(void)closeSelf{
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}
@end
