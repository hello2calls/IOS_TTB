//
//  PreShareVersion0View.m
//  TouchPalDialer
//
//  Created by game3108 on 16/1/13.
//
//

#import "PreShareVersion0View.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "VoipConsts.h"

#define WILD_MATCH_STR @"%s"

@implementation PreShareVersion0View

- (id)initWithFrame:(CGRect)frame andShareData:(ShareData *)shareData{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        UIImage *shareBg = [TPDialerResourceManager getImage:@"share_packet_bg_special@2x.png"];
        CGFloat scale = TPScreenWidth() / 410.0;
        CGRect frame = CGRectMake(0, 0, shareBg.size.width * scale, shareBg.size.height * scale);
        UIImageView *preShareBg = [[UIImageView alloc] initWithImage:shareBg];
        preShareBg.frame = frame;
        preShareBg.center = CGPointMake(self.center.x, self.center.y);
        
        UIColor *instantTitleColor = [UIColor colorWithRed:0xc2 / 255.0 green:0x2b / 255.0 blue:0x1d / 255.0 alpha:1.0];
        
        UILabel *congratulation = [[UILabel alloc] initWithFrame:CGRectMake(preShareBg.frame.origin.x, preShareBg.frame.origin.y + 40*WIDTH_ADAPT, preShareBg.frame.size.width, 20)];
        congratulation.font = [UIFont systemFontOfSize:18];
        congratulation.textAlignment = NSTextAlignmentCenter;
        congratulation.numberOfLines = 1;
        congratulation.textColor = [UIColor whiteColor];
        congratulation.text = @"恭喜你获得";
        congratulation.textColor = instantTitleColor;
        
        
        UIImage *closeIcon = [TPDialerResourceManager getImage:@"share_packet_close@2x.png"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setBackgroundImage:closeIcon forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onCloseClicked) forControlEvents:UIControlEventTouchUpInside];
        closeButton.frame = CGRectMake(preShareBg.frame.origin.x + preShareBg.frame.size.width - closeIcon.size.width, preShareBg.frame.origin.y, closeIcon.size.width, closeIcon.size.height);
        
        UILabel *instantBonusQuantityView = [[UILabel alloc] initWithFrame:CGRectMake(congratulation.frame.origin.x, congratulation.frame.origin.y + congratulation.frame.size.height + 5, congratulation.frame.size.width, 35)];
        instantBonusQuantityView.font = [UIFont systemFontOfSize:32 * WIDTH_ADAPT];
        instantBonusQuantityView.textColor = [UIColor whiteColor];
        instantBonusQuantityView.textAlignment = NSTextAlignmentCenter;
        instantBonusQuantityView.numberOfLines = 1;
        instantBonusQuantityView.textColor = instantTitleColor;
        
        UIColor *instantTypeColor = [UIColor colorWithRed:0x7e / 255.0 green:0x7a / 255.0 blue:0x6e / 255.0 alpha:1.0];
        UILabel *instantBonusTypeView = [[UILabel alloc] initWithFrame:CGRectMake(instantBonusQuantityView.frame.origin.x, instantBonusQuantityView.frame.origin.y + instantBonusQuantityView.frame.size.height + 5, preShareBg.frame.size.width, 25)];
        instantBonusTypeView.font = [UIFont systemFontOfSize:17];
        instantBonusTypeView.textColor = [UIColor whiteColor];
        instantBonusTypeView.textAlignment = NSTextAlignmentCenter;
        instantBonusTypeView.numberOfLines = 1;
        instantBonusTypeView.textColor = instantTypeColor;
        
        CGFloat gap = 90 * WIDTH_ADAPT;
        if (TPScreenWidth() < 360) {
            gap = 70 * WIDTH_ADAPT;
        }
        UILabel *shareBonusMessageView = [[UILabel alloc] initWithFrame:CGRectMake(preShareBg.frame.origin.x, instantBonusTypeView.frame.origin.y + instantBonusTypeView.frame.size.height + gap, preShareBg.frame.size.width, 28)];
        shareBonusMessageView.textAlignment = NSTextAlignmentCenter;
        shareBonusMessageView.numberOfLines = 1;
        shareBonusMessageView.font = [UIFont systemFontOfSize:17];
        
        UILabel *shareBonusHintView = [[UILabel alloc] initWithFrame:CGRectMake(preShareBg.frame.origin.x, shareBonusMessageView.frame.origin.y + shareBonusMessageView.frame.size.height + 12, preShareBg.frame.size.width, 15)];
        shareBonusHintView.textAlignment = NSTextAlignmentCenter;
        shareBonusHintView.font = [UIFont systemFontOfSize:16];
        shareBonusHintView.textColor = [UIColor whiteColor];
        
        CGFloat botttomGap = 50;
        if (TPScreenWidth() < 360) {
            botttomGap = 30;
        }
        //UIButton
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat bw = 150;
        CGFloat bh = 35;
        CGFloat by = preShareBg.frame.size.height + preShareBg.frame.origin.y - botttomGap - bh;
        button.frame = CGRectMake(preShareBg.frame.origin.x + (preShareBg.frame.size.width - bw)/2, by, bw, bh);
        UIColor *bgColor = [UIColor colorWithRed:249.0/255.0 green:203.0/255.0 blue:92.0/255.0 alpha:1.0];
        UIColor *bgPressedColor = [UIColor colorWithRed: 1.0 green:213 / 255.0 blue:101 / 255.0 alpha:1.0];
        [button addTarget:self action:@selector(onShareClicked) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = bh/2;
        button.layer.masksToBounds = YES;
        [button setTitleColor:instantTitleColor forState:UIControlStateNormal];
        [button setTitle:@"发红包" forState:UIControlStateNormal];
        [button setBackgroundImage:[FunctionUtility imageWithColor:bgColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[FunctionUtility imageWithColor:bgPressedColor] forState:UIControlEventTouchDown];
        
        
        [self addSubview:preShareBg];
        [self addSubview:congratulation];
        [self addSubview:instantBonusQuantityView];
        [self addSubview:instantBonusTypeView];
        [self addSubview:shareBonusMessageView];
        [self addSubview:shareBonusHintView];
        [self addSubview:closeButton];
        [self addSubview:button];
        
        if (![shareData.instantBonusType length]) {
            congratulation.hidden = YES;
            instantBonusTypeView.hidden = YES;
            instantBonusQuantityView.hidden = YES;
        } else {
            UIImage *shareBg = [TPDialerResourceManager getImage:@"share_packet_bg_normal@2x.png"];
            [preShareBg setImage:shareBg];
            congratulation.hidden = NO;
            if ([shareData.instantBonusQuantity length] == 0) {
                instantBonusQuantityView.hidden = NO;
                instantBonusQuantityView.text = shareData.instantBonusType;
                CGRect origFrame = instantBonusQuantityView.frame;
                instantBonusQuantityView.frame = CGRectMake(origFrame.origin.x, origFrame.origin.y = 10, origFrame.size.width, origFrame.size.height);
                instantBonusTypeView.hidden = YES;
            } else {
                instantBonusQuantityView.hidden = NO;
                instantBonusQuantityView.text = shareData.instantBonusQuantity;
                instantBonusTypeView.hidden = NO;
                instantBonusTypeView.text = shareData.instantBonusType;
            }
        }
        
        if ([shareData.shareBonusMessage length]) {
            NSRange range = [shareData.shareBonusMessage rangeOfString:WILD_MATCH_STR];
            [button setTitle:@"发红包" forState:UIControlStateNormal];
            if (range.location == NSNotFound) {
                shareBonusMessageView.text = shareData.shareBonusMessage;
                shareBonusMessageView.font = [UIFont systemFontOfSize:16];
                shareBonusMessageView.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            } else {
                UIFont *highlightFont = [UIFont systemFontOfSize:30];
                UIColor *highlightColor = [UIColor colorWithRed:1.0 green:0xd5 / 255.0 blue:0x65 / 255.0 alpha:1.0];
                UIFont *normalFont = [UIFont systemFontOfSize:17];
                UIColor *normalColor = [UIColor whiteColor];
                NSDictionary *attributes = @{NSFontAttributeName: normalFont, NSForegroundColorAttributeName: normalColor};
                NSAttributedString *normalStr = [[NSAttributedString alloc] initWithString:shareData.shareBonusMessage attributes:attributes];
                NSMutableAttributedString *attributeMutableStr = [[NSMutableAttributedString alloc] initWithAttributedString:normalStr];
                NSDictionary *highlightAttribute = @{NSFontAttributeName: highlightFont, NSForegroundColorAttributeName:highlightColor};
                NSAttributedString *highlightStr = [[NSAttributedString alloc] initWithString:shareData.shareBonusQuantity attributes:highlightAttribute];
                [attributeMutableStr replaceCharactersInRange:range withAttributedString:highlightStr];
                shareBonusMessageView.attributedText = attributeMutableStr;
                
            }
        } else {
            [button setTitle:@"知道了" forState:UIControlStateNormal];
            shareBonusMessageView.hidden = YES;
        }
        
        if ([shareData.shareBonusHint length]) {
            shareBonusHintView.hidden = NO;
            shareBonusHintView.text = shareData.shareBonusHint;
        } else {
            shareBonusHintView.hidden = YES;
        }
    }
    return self;
}


@end
