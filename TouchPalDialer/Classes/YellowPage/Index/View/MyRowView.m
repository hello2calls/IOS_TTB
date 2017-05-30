//
//  MyRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/7.
//
//

#import "MyRowView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "UserDefaultsManager.h"
#import "MyWalletViewController.h"
#import "DefaultJumpLoginController.h"

@implementation MyRowView


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.phoneIcon = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(15, 0, 20, self.frame.size.height)];
        self.phoneIcon.textColor = [ImageUtils colorFromHexString:MY_PHONE_TITLE_TEXT_COLOR andDefaultColor:nil];
        self.phoneIcon.textAlignment = NSTextAlignmentLeft;
        self.phoneIcon.verticalAlignment = VerticalAlignmentMiddle;
        self.phoneIcon.font = [UIFont fontWithName:IPHONE_ICON_2 size:MY_PHONE_ICON_TEXT_SIZE];
        self.phoneIcon.text = @"k";
        [self addSubview:self.phoneIcon];
        
        self.phoneLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(40, 0, 100, self.frame.size.height)];
        self.phoneLabel.textColor = [ImageUtils colorFromHexString:MY_PHONE_TITLE_TEXT_COLOR andDefaultColor:nil];
        self.phoneLabel.font = [UIFont systemFontOfSize:MY_PHONE_TITLE_SIZE];
        self.phoneLabel.textAlignment = NSTextAlignmentLeft;
        self.phoneLabel.verticalAlignment = VerticalAlignmentMiddle;
        [self addSubview:self.phoneLabel];
        
        self.rightTextLabel = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(140, 0, self.frame.size.width - 170, self.frame.size.height)];
        self.rightTextLabel.textColor = [ImageUtils colorFromHexString:MY_PHONE_RIGHT_TEXT_COLOR andDefaultColor:nil];
        self.rightTextLabel.font = [UIFont systemFontOfSize:MY_PHONE_RIGHT_TEXT_SIZE];
        self.rightTextLabel.textAlignment = NSTextAlignmentRight;
        self.rightTextLabel.verticalAlignment = VerticalAlignmentMiddle;
        self.rightTextLabel.text = @"卡券、兑换";
        [self addSubview:self.rightTextLabel];
        
        self.rightTextIcon = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 28, 0, 20, self.frame.size.height)];
        self.rightTextIcon.textColor = [ImageUtils colorFromHexString:MY_PHONE_RIGHT_TEXT_COLOR andDefaultColor:nil];
        self.rightTextIcon.font = [UIFont systemFontOfSize:FIND_TITLE_SIZE];
        self.rightTextIcon.textAlignment = NSTextAlignmentRight;
        self.rightTextIcon.verticalAlignment = VerticalAlignmentMiddle;
        self.rightTextIcon.font = [UIFont fontWithName:IPHONE_ICON_2 size:FIND_TITLE_SIZE];
        self.rightTextIcon.text = @"n";
        [self addSubview:self.rightTextIcon];
        
    }
    return self;
}

- (void) drawView
{
    NSString* accountName = @"未登录";
    if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN ]) {
        accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
        accountName = [accountName substringFromIndex:3];
    }
    self.phoneLabel.text = accountName;
    [self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:MY_PHONE_BG_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:MY_PHONE_BG_COLOR andDefaultColor:nil].CGColor);
    }
    CGContextFillRect(context, rect);
}

- (void) doClick
{
    DefaultJumpLoginController *loginController = [DefaultJumpLoginController withOrigin:@"personal_center_wallet"];
    loginController.destination = NSStringFromClass([MyWalletViewController class]);
    [LoginController checkLoginWithDelegate:loginController];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_WALLET];
}
@end
