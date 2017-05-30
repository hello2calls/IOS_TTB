//
//  VoipCallAlertView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/13.
//
//

#import "VoipCallAlertView.h"
#import "TPDialerResourceManager.h"

@interface VoipCallAlertView(){
    UIView *_boardView;
}

@end

@implementation VoipCallAlertView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        _boardView = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width-260)/2,(frame.size.height-240)/2,260,180)];
        _boardView.backgroundColor = [UIColor whiteColor];
        _boardView.layer.masksToBounds = YES;
        _boardView.layer.cornerRadius = 5.0f;
        [self addSubview:_boardView];
        
        NSString *labelStr = NSLocalizedString(@"voip_use_callback_alert_word1", @"");
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelStr];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:2];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelStr length])];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, _boardView.frame.size.width - 40, 90)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor blackColor];
        label.attributedText = attributedString;
        label.numberOfLines = 5;
        [_boardView addSubview:label];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 130, frame.size.width, 1)];
        line.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_line_color"];
        [_boardView addSubview:line];

        UIButton *sureButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 130, _boardView.frame.size.width, 50)];
        [sureButton setTitle:NSLocalizedString(@"voip_know_callback", "") forState:UIControlStateNormal];
        [sureButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_callalert_button_normal_color"] forState:UIControlStateNormal];
        sureButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
        [_boardView addSubview:sureButton];
        [sureButton addTarget:self action:@selector(onClickSureButton) forControlEvents:UIControlEventTouchUpInside];

        
    }
    return self;
}

- (void)onClickSureButton{
    [self removeFromSuperview];
}
@end
