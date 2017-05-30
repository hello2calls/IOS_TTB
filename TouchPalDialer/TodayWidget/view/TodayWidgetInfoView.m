//
//  TodayWidgetInfoView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/10.
//
//

#import "TodayWidgetInfoView.h"
#import "TodayWidgetUtil.h"
#import "NSString+PhoneNumber.h"

@interface TodayWidgetInfoView(){
    TodayWidgetInfo *_info;
    
    UILabel *infoLabel;
    NSString *_attr;
}

@end

@implementation TodayWidgetInfoView

- (instancetype)initWithInfo:(TodayWidgetInfo *)info andAttr:(NSString*)attr andIfFreeCall:(BOOL)ifFreeCall delegate:(id<TodayWidgetMainViewDelegate>)delegate{
    _info = info;
    _attr = attr;
    self.delegate = delegate;
    CGRect rect = [[UIScreen mainScreen] bounds];
    if ([delegate ifShowUpdateViewInToday]) {
        self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, 180)];
        self.updateView.hidden = NO;
    }
    else{
        self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, 100)];
        self.updateView.hidden = YES;
    }
    if ( self ){
        infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 20, self.viewButton.frame.size.width - 160, 20)];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16];
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.textAlignment = NSTextAlignmentLeft;
        infoLabel.numberOfLines = 3;
        [self generateInfoStr];
        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.viewButton addSubview:infoLabel];
        
        self.rightButton.hidden = NO;
        if ( ifFreeCall ){
            [self.rightButton setTitle:@"免费拨打" forState:UIControlStateNormal];
        }else{
            [self.rightButton setTitle:@"拨打" forState:UIControlStateNormal];
        }
        [self.viewButton bringSubviewToFront:self.rightButton];
    }
    return self;
}

- (void)generateInfoStr{
    NSString *resultStr;
    NSMutableAttributedString *str;
    if ( _info.classifyType != nil ){
        if ( _info.markCount == 0 ){
            resultStr = [NSString stringWithFormat:@"%@",_info.classifyType];
            NSRange range1 = [resultStr rangeOfString:[NSString stringWithFormat:@"%@",_info.classifyType]];
            str = [[NSMutableAttributedString alloc] initWithString:resultStr];
            [str addAttribute:NSForegroundColorAttributeName value:[TodayWidgetUtil getColor:@"0xff9b35"] range:range1];
        }else{
            resultStr = [NSString stringWithFormat:@"%d人标记为%@",_info.markCount,_info.classifyType];
            NSRange range1 = [resultStr rangeOfString:[NSString stringWithFormat:@"%d人",_info.markCount]];
            NSRange range2 = [resultStr rangeOfString:[NSString stringWithFormat:@"%@",_info.classifyType]];
            str = [[NSMutableAttributedString alloc] initWithString:resultStr];
            [str addAttribute:NSForegroundColorAttributeName value:[TodayWidgetUtil getColor:@"0xff9b35"] range:range1];
            [str addAttribute:NSForegroundColorAttributeName value:[TodayWidgetUtil getColor:@"0xff9b35"] range:range2];
        }
    }else{
        resultStr = [NSString stringWithFormat:@"%@",_info.shopName];
        NSRange range1 = [resultStr rangeOfString:[NSString stringWithFormat:@"%@",_info.shopName]];
        str = [[NSMutableAttributedString alloc] initWithString:resultStr];
        [str addAttribute:NSForegroundColorAttributeName value:[TodayWidgetUtil getColor:@"0xff9b35"] range:range1];
    }
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:16]};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect rect = [resultStr boundingRectWithSize:CGSizeMake(self.viewButton.frame.size.width - 160, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    
    infoLabel.frame = CGRectMake(50, 18, self.viewButton.frame.size.width - 160, rect.size.height);
    
    self.mainLabel.frame = CGRectMake(50, CGRectGetMaxY(infoLabel.frame)+4, self.mainLabel.frame.size.width, self.mainLabel.frame.size.height);

        self.subLabel.frame = CGRectMake(50, CGRectGetMaxY(self.mainLabel.frame)+2, self.viewButton.frame.size.width - 50, 20);
            CGRect updateViewFrame =  self.updateView.frame;
        updateViewFrame.origin.y = CGRectGetMaxY(self.subLabel.frame)+10;
        self.updateView.frame =updateViewFrame;
    self.rightButton.center = CGPointMake(self.rightButton.center.x, CGRectGetMidY(self.mainLabel.frame));
    
    infoLabel.attributedText = str;
}

- (void)onPressBgButton{
    [self.delegate onPressBgButton];
}

- (NSString *)getMainLabelText{
    if ( _info.generateNumber.length < 10)
        return _info.generateNumber;
    else {
        NSMutableString *temptStr = [[NSMutableString alloc]initWithString:_info.generateNumber];
        NSString *text = [temptStr formatPhoneNumber];
        return text;
    }
}

- (NSString *)getSubLabelText{
    if ( _info.shopName!= nil )
        return @"热线电话";
    return _attr;
}

@end
