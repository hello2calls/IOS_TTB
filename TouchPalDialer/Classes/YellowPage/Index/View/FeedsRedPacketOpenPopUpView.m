//
//  FeedsRedPackOpenPopUpView.m
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import "FeedsRedPacketOpenPopUpView.h"
#import "YPImageView.h"
#import "IndexConstant.h"
#import "VerticallyAlignedLabel.h"
#import "ImageUtils.h"
#import "CootekNotifications.h"
#import "DialerUsageRecord.h"


#define MARGIN_LEFT 30
#define MARGIN_BOTTOM 78


@interface FeedsRedPacketOpenPopUpView()
{
    VerticallyAlignedLabel* contentLabel;
    FindNewsBonusResult* bonusResult;
}
@end

@implementation FeedsRedPacketOpenPopUpView

-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    return self;
}

- (instancetype) initWithContent:(NSString *)content andResult:(FindNewsBonusResult *)result
{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if (self) {
        bonusResult = result;
        int startX = MARGIN_LEFT;
        int imageWidth = TPScreenWidth() - 2 * MARGIN_LEFT;
        int imageHeight = imageWidth * 1520 / 1200;
        int startY = self.frame.size.height - imageHeight - MARGIN_BOTTOM;
        
        int closeWidth = 30;
        int closeHeight = 30;
        self.closeView = [[YPImageView alloc] initWithFrame:CGRectMake(startX + imageWidth - closeWidth , startY - closeHeight - 20, closeWidth, closeHeight)];
        NSString *closePath = [[NSBundle mainBundle] pathForResource:FEEDS_RED_PACKET_CLOSE_ICON_PATH ofType:@"png"];
        self.closeView.imageView.image = [UIImage imageWithContentsOfFile:closePath];
        __weak FeedsRedPacketOpenPopUpView* weakSelf = self;
        self.closeView.block =^(){
            [weakSelf closeSelf];
        };
        
        [self addSubview:self.closeView];
        
        NSString *bgPath = [[NSBundle mainBundle] pathForResource:FEEDS_RED_PACKET_OPEN_BG_PATH ofType:@"png"];
        self.imageView = [[YPImageView alloc] initWithFrame:CGRectMake(startX, startY, imageWidth, imageHeight)];
        self.imageView.imageView.image = [UIImage imageWithContentsOfFile:bgPath];
        self.imageView.frame = CGRectMake(startX, startY, imageWidth, imageHeight);
        [self addSubview:self.imageView];
        
        int startContentY1 = startY + self.imageView.frame.size.height * 3 / 5;
        contentLabel = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(startX, startContentY1, self.imageView.frame.size.width, 30)];
        contentLabel.verticalAlignment = VerticalAlignmentMiddle;
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.text = content;
        contentLabel.textColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_TEXT_COLOR andDefaultColor:nil];
        contentLabel.font = [UIFont systemFontOfSize:FEEDS_RED_PACKET_OPEN_TEXT_TEXTSIZE];
        [self addSubview:contentLabel];
        
        
        int startBtnX = self.imageView.frame.origin.x + (self.imageView.frame.size.width - FEEDS_RED_PACKET_OK_BTN_WIDTH) / 2;
        int startBtnY = self.imageView.frame.origin.y +  self.imageView.frame.size.height - FEEDS_RED_PACKET_OK_BTN_BOTTOM_MARGIN - FEEDS_RED_PACKET_OK_BTN_HEIGHT;
        
        YPUIView* btnView = [[YPUIView alloc] initWithFrame:CGRectMake(startBtnX, startBtnY, FEEDS_RED_PACKET_OK_BTN_WIDTH, FEEDS_RED_PACKET_OK_BTN_HEIGHT)];
        VerticallyAlignedLabel* okBtn = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(0, 0, FEEDS_RED_PACKET_OK_BTN_WIDTH, FEEDS_RED_PACKET_OK_BTN_HEIGHT)];
        okBtn.verticalAlignment = VerticalAlignmentMiddle;
        okBtn.textAlignment = NSTextAlignmentCenter;
        okBtn.layer.cornerRadius = 15;
        okBtn.clipsToBounds = YES;
        okBtn.backgroundColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_OK_BTN_BG_COLOR andDefaultColor:nil];
        okBtn.text = @"我知道了";
        okBtn.textColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_OK_BTN_TEXT_COLOR andDefaultColor:nil];
        okBtn.font = [UIFont systemFontOfSize:24];
        [btnView addSubview:okBtn];
        
        __weak FeedsRedPacketOpenPopUpView* wSelf = self;
        btnView.block = ^{
            [wSelf closeSelf];
        };
        
        [self addSubview:btnView];
        
        self.block = ^{
             [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name", FEEDS_CLICK_OPEN_RED_PACKET), nil];
            [weakSelf closeSelf];
        };
        
        [self drawTitle: self.imageView];
    }
    
    return self;
}

- (void) drawTitle:(UIView *)parentView
{
    NSString* title = @"恭喜您获得";
    CGSize sizeTitle = [title sizeWithFont:[UIFont systemFontOfSize:FEEDS_RED_PACKET_TITLE_TEXT_SIZE] constrainedToSize:CGSizeMake(parentView.frame.size.width, parentView.frame.size.height) lineBreakMode:NSLineBreakByCharWrapping];
    
    //draw title text
    int titleStartX = (parentView.frame.size.width - sizeTitle.width) / 2;
    int titleStartY = 30;
    
    VerticallyAlignedLabel* titleLabel = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(titleStartX, titleStartY, sizeTitle.width + 1, sizeTitle.height + 1)];
    titleLabel.verticalAlignment = VerticalAlignmentMiddle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_TITLE_TEXT_COLOR andDefaultColor:nil];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.text = title;
    [parentView addSubview:titleLabel];
    
    
    //left line
    int lineLeftStartX = (parentView.frame.size.width -  sizeTitle.width - 20) / 2 - FEEDS_RED_PACKET_TITLE_LINE_WIDTH;
    int lineLeftStartY = titleStartY + sizeTitle.height / 2;
    
    UIView* leftLine = [[UIView alloc] initWithFrame:CGRectMake(lineLeftStartX, lineLeftStartY, FEEDS_RED_PACKET_TITLE_LINE_WIDTH, 1)];
    leftLine.layer.borderColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_TITLE_LINE_COLOR andDefaultColor:nil].CGColor;
    leftLine.layer.borderWidth = 1.0f;
    
    [parentView addSubview:leftLine];
    
    //right line
    int lineRightStartX = (parentView.frame.size.width +  sizeTitle.width + 20) / 2;
    int lineRightStartY = titleStartY + sizeTitle.height / 2;
    UIView* rightLine = [[UIView alloc]initWithFrame:CGRectMake(lineRightStartX, lineRightStartY, FEEDS_RED_PACKET_TITLE_LINE_WIDTH, 1)];
    rightLine.layer.borderColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_TITLE_LINE_COLOR andDefaultColor:nil].CGColor;
    rightLine.layer.borderWidth = 1.0f;
    [parentView addSubview:rightLine];
    

    
    NSString* amountI = [bonusResult getBonusAmount];
    NSString* bonusStr = [bonusResult getBonusString];
    NSString* amountStr = amountI;
 
    CGSize sizeAmount = [amountStr sizeWithFont:[UIFont systemFontOfSize:FEEDS_RED_PACKET_AMOUNT_TEXT_SIZE] constrainedToSize:CGSizeMake(parentView.frame.size.width, parentView.frame.size.height) lineBreakMode:NSLineBreakByCharWrapping];
    CGSize sizeBonusStr = [bonusStr sizeWithFont:[UIFont systemFontOfSize:FEEDS_RED_PACKET_AMOUNT_CONTENT_TEXT_SIZE] constrainedToSize:CGSizeMake(parentView.frame.size.width, parentView.frame.size.height) lineBreakMode:NSLineBreakByCharWrapping];
    
    int amountWidth = sizeAmount.width + sizeBonusStr.width + 2;
    
    int startAmountX = (parentView.frame.size.width - amountWidth) / 2;
    int startAmountY = titleStartY + sizeTitle.height  + 10;
    
    VerticallyAlignedLabel* amount = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(startAmountX, startAmountY,  sizeAmount.width + 1, 50)];
    amount.verticalAlignment = VerticalAlignmentBottom;
    amount.textAlignment = NSTextAlignmentLeft;
    amount.textColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_AMOUNT_TEXT_COLOR andDefaultColor:nil];
    amount.font = [UIFont systemFontOfSize:FEEDS_RED_PACKET_AMOUNT_TEXT_SIZE];
    amount.text = amountStr;
    [parentView addSubview:amount];
    
    VerticallyAlignedLabel* amountContent = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(startAmountX + amount.frame.size.width, startAmountY,  sizeBonusStr.width + 1, 47)];
    amountContent.verticalAlignment = VerticalAlignmentBottom;
    amountContent.textAlignment = NSTextAlignmentLeft;
    amountContent.textColor = [ImageUtils colorFromHexString:FEEDS_RED_PACKET_AMOUNT_TEXT_COLOR andDefaultColor:nil];
    amountContent.font = [UIFont systemFontOfSize:FEEDS_RED_PACKET_AMOUNT_CONTENT_TEXT_SIZE];
    amountContent.text = bonusStr;
    [parentView addSubview:amountContent];
    
    
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
