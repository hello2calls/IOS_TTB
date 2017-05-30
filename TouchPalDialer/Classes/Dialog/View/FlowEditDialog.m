//
//  FlowEditDialog.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/15.
//
//

#import "FlowEditDialog.h"
#import "TPDialerResourceManager.h"
#import "TPButton.h"
#import "LoginController.h"
#import "MarketLoginController.h"
#import "UserDefaultsManager.h"
#import "CootekNotifications.h"

@implementation FlowEditDialog

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        self.frame = CGRectMake(0, 0, TPScreenWidth() - 40, TPScreenHeight());
        self.layer.cornerRadius = 4;
        
        CGFloat contentWidth = self.frame.size.width - 40;
        CGFloat globalY = 30;
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x, globalY, self.frame.size.width, FONT_SIZE_3)];
        title.text = @"使用说明";
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont fontWithName:@"Helvetica-bold" size:FONT_SIZE_3];
        title.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        title.backgroundColor = [UIColor clearColor];
        [self addSubview:title];
        
        globalY += title.frame.size.height + 30;
        
        UILabel *firstMain = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, contentWidth, FONT_SIZE_4)];
        firstMain.text = @"免费流量如何使用";
        firstMain.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        firstMain.font = [UIFont systemFontOfSize:FONT_SIZE_4];
        firstMain.backgroundColor = [UIColor clearColor];
        [self addSubview:firstMain];
        
        globalY += firstMain.frame.size.height + 15;
        
        NSString *firstString1 = @"流量需提取到手机上才能使用。提取后当月有效，建议按需提取。";
        UILabel *firstAltLine1 = [self getLabelWithString:firstString1];
        CGSize firstSize1 = [firstString1 sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_5]  constrainedToSize:CGSizeMake(contentWidth, TPScreenHeight())];
        firstAltLine1.frame = CGRectMake(20, globalY, contentWidth, firstSize1.height + 6);
        [self addSubview:firstAltLine1];
        
        globalY += firstAltLine1.frame.size.height + 15;
        
        NSString *firstString2 = @"未提取的流量存放在触宝账户中，永久有效，不会清零。";
        UILabel *firstAltLine2 = [self getLabelWithString:firstString2];
        CGSize firstSize2 = [firstString2 sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_5 ]  constrainedToSize:CGSizeMake(contentWidth, TPScreenHeight())];
        firstAltLine2.frame = CGRectMake(20, globalY, contentWidth, firstSize2.height + 6);
        [self addSubview:firstAltLine2];
        
        globalY += firstAltLine2.frame.size.height + 30;
        
        UILabel *secondMain = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, contentWidth, FONT_SIZE_4)];
        secondMain.text = @"免费流量如何获得";
        secondMain.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        secondMain.font = [UIFont systemFontOfSize:FONT_SIZE_4];
        secondMain.backgroundColor = [UIColor clearColor];
        [self addSubview:secondMain];
        
        globalY += secondMain.frame.size.height + 15;
        
        NSString *secondString = @"用触宝打电话、充话费，都有机会获得免费流量。活动大厅会不定期发布奖励任务。";
        NSRange range = [secondString rangeOfString:@"活动大厅"];
        CGSize secondSize = [secondString sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_5]  constrainedToSize:CGSizeMake(contentWidth, TPScreenHeight())];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(14, globalY, contentWidth, secondSize.height)];
        NSMutableAttributedString *attributeNormal = [[NSMutableAttributedString alloc]initWithString:secondString];
        NSMutableAttributedString *attributeHighlight = [[NSMutableAttributedString alloc]initWithString:secondString];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:6];
        [attributeNormal addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, secondString.length)];
        [attributeHighlight addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, secondString.length)];
        
        [attributeNormal addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"] range:NSMakeRange(0, secondString.length)];
        [attributeNormal addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"tp_color_orange_500"] range:range];
        [attributeHighlight addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"] range:NSMakeRange(0, secondString.length)];
        [attributeHighlight addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"tp_color_orange_700"] range:range];
        [button setAttributedTitle:attributeNormal forState:UIControlStateNormal];
        [button setAttributedTitle:attributeHighlight forState:UIControlStateHighlighted];
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5];
        [button addTarget:self action:@selector(gotoMarket) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        globalY += button.frame.size.height + 30;
        
        TPButton *close = [[TPButton alloc]initWithFrame:CGRectMake(20, globalY, contentWidth, 46) withType:GRAY_LINE withFirstLineText:@"知道啦！" withSecondLineText:nil];
        [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:close];
        
        globalY += close.frame.size.height + 20;
        
        self.frame = CGRectMake(0, 0, TPScreenWidth() - 40, globalY);
        
    }
    return self;
}

- (UILabel *)getLabelWithString:(NSString*)string {
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithString:string];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:6];
    [attribute addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    [attribute addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"] range:NSMakeRange(0, string.length)];
    
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:FONT_SIZE_5];
    label.numberOfLines = 0;
    label.attributedText = attribute;
    return label;
}

- (void)gotoMarket {
    [LoginController checkLoginWithDelegate:[MarketLoginController withOrigin:@"personal_center_market"]];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_MARKET];
    [self close];
}

- (void)close {
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
    
}

@end
