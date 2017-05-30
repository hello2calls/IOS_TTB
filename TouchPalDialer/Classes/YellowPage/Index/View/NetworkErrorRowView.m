//
//  NetworkErrorRowView.m
//  TouchPalDialer
//
//  Created by apple on 16/7/18.
//
//

#import "NetworkErrorRowView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "UserDefaultsManager.h"
#import "MyWalletViewController.h"
#import "DefaultJumpLoginController.h"

@implementation NetworkErrorRowView
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.networkErrorIcon = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(15, 0, 20, self.frame.size.height)];
        self.networkErrorIcon.textColor = [ImageUtils colorFromHexString:NETWORK_ERROR_ICON_COLOR andDefaultColor:nil];
        self.networkErrorIcon.textAlignment = NSTextAlignmentLeft;
        self.networkErrorIcon.verticalAlignment = VerticalAlignmentMiddle;
        self.networkErrorIcon.font = [UIFont fontWithName:IPHONE_ICON_2 size:NETWORK_ERROR_ICON_SIZE];
        self.networkErrorIcon.text = @"B";
        [self addSubview:self.networkErrorIcon];
        
        self.networkErrorLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(40, 0, self.frame.size.width - 40, self.frame.size.height)];
        self.networkErrorLabel.textColor = [ImageUtils colorFromHexString:NETWORK_ERROR_TEXT_COLOR andDefaultColor:nil];
        self.networkErrorLabel.font = [UIFont systemFontOfSize:NETWORK_ERROR_TEXT_SIZE];
        self.networkErrorLabel.textAlignment = NSTextAlignmentLeft;
        self.networkErrorLabel.verticalAlignment = VerticalAlignmentMiddle;
        [self addSubview:self.networkErrorLabel];
    }
    return self;
}

- (void) drawView
{
    self.networkErrorLabel.text = @"当前网络不可用，请检查你的网络设置";
    [self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:NETWORK_ERROR_BG_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:NETWORK_ERROR_BG_COLOR andDefaultColor:nil].CGColor);
    }
    CGContextFillRect(context, rect);
}
@end
