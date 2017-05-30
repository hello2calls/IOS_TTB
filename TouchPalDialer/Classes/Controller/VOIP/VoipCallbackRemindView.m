//
//  VoipCallbackRemindView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/13.
//
//

#import "VoipCallbackRemindView.h"
#import "TPDialerResourceManager.h"

#define WIDTH_ADAPT TPScreenWidth()/320

@interface VoipCallbackRemindView(){
    UIView *_boardView;
}

@end


@implementation VoipCallbackRemindView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
    
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        _boardView = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width-270*WIDTH_ADAPT)/2, (frame.size.height-250*WIDTH_ADAPT)/2, 270*WIDTH_ADAPT,250*WIDTH_ADAPT)];
        _boardView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_boardView];
        
        float globayY = 56;
        
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(_boardView.frame.size.width - 30 *WIDTH_ADAPT, 5*WIDTH_ADAPT, 25*WIDTH_ADAPT, 25*WIDTH_ADAPT)];
        [cancelButton addTarget:self action:@selector(removeBoard) forControlEvents:UIControlEventTouchUpInside];
        [_boardView addSubview:cancelButton];
        
        UIImageView *cancelImage = [[UIImageView alloc]initWithFrame:CGRectMake(5*WIDTH_ADAPT, 5*WIDTH_ADAPT, 15*WIDTH_ADAPT, 15*WIDTH_ADAPT)];
        cancelImage.image = [TPDialerResourceManager getImage:@"contact_search_close@2x.png"];
        [cancelButton addSubview:cancelImage];

        UILabel *firstCallbackMode = [[UILabel alloc]initWithFrame:CGRectMake(0, globayY, _boardView.frame.size.width, FONT_SIZE_3_5*WIDTH_ADAPT)];
        firstCallbackMode.font = [UIFont fontWithName:@"Helvetica-Bold" size:FONT_SIZE_3_5*WIDTH_ADAPT];
        firstCallbackMode.textAlignment = NSTextAlignmentCenter;
        firstCallbackMode.textColor = [UIColor blackColor];
        firstCallbackMode.text = NSLocalizedString(@"voip_remind_view_title", "");
        [_boardView addSubview:firstCallbackMode];
        
        globayY += firstCallbackMode.frame.size.height + 20;
        
        NSString *label1Str = NSLocalizedString(@"voip_remind_view_label1", "");
        NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:label1Str];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:2];//调整行间距
        
        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [label1Str length])];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(28, globayY, _boardView.frame.size.width - 56, FONT_SIZE_3_5*WIDTH_ADAPT*2 + 10*WIDTH_ADAPT)];
        label1.attributedText = attributedString1;
        label1.textAlignment = NSTextAlignmentLeft;
        label1.font = [UIFont systemFontOfSize:FONT_SIZE_3_5*WIDTH_ADAPT];
        label1.numberOfLines = 3;
        label1.textColor = [TPDialerResourceManager getColorForStyle:@"voip_mainLabel_text_color"];
        [_boardView addSubview:label1];
        
        globayY += label1.frame.size.height + 5;
        
        NSString *label2Str = NSLocalizedString(@"voip_remind_view_label3", "");
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:label2Str];
        [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [label2Str length])];
        
        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(28, globayY, _boardView.frame.size.width - 56, FONT_SIZE_3_5*WIDTH_ADAPT*3 + 15*WIDTH_ADAPT)];
        label3.attributedText = attributedString2;
        label3.textAlignment = NSTextAlignmentLeft;
        label3.font = [UIFont systemFontOfSize:FONT_SIZE_3_5*WIDTH_ADAPT];
        label3.numberOfLines = 4;
        label3.textColor = [TPDialerResourceManager getColorForStyle:@"voip_mainLabel_text_color"];
        [_boardView addSubview:label3];
        
    }
    
    return self;
}

- (void)removeBoard{
    [self removeFromSuperview];
}

@end
