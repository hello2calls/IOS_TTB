//
//  VoipTopSectionBottomView.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-5.
//
//

#import "VoipTopSectionBottomView.h"
#import "TPDialerResourceManager.h"
#import "CommonWebViewController.h"
#import "TouchPalDialerAppDelegate.h"

#define WIDTH_ADAPT TPScreenWidth()/360

@interface VoipTopSectionBottomView(){
    BOOL onTouchMove;
}

@end


@implementation VoipTopSectionBottomView


- (id) initWithFrame:(CGRect)frame andBgColor:(UIColor*)bgColor{
    self = [super initWithFrame:frame];
    
    if (self){
        onTouchMove = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 14;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 28)];
        backView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_bottomView_bg_color"];
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 14;
        [self addSubview:backView];
        
        
        UIView *questionView = [[UIView alloc] initWithFrame:CGRectMake(3, 3, 22, 22)];
        questionView.backgroundColor = bgColor;
        questionView.layer.masksToBounds = YES;
        questionView.layer.cornerRadius = questionView.frame.size.width /2 ;
        [backView addSubview:questionView];
        
        UILabel *signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        signLabel.backgroundColor = [UIColor clearColor];
        signLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_bottomView_bg_color"];
        signLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
        signLabel.text = @"?";
        signLabel.textAlignment = NSTextAlignmentCenter;
        [questionView addSubview:signLabel];
        
        UILabel *learnTPLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backView.frame.size.width, frame.size.height)];
        learnTPLabel.text = NSLocalizedString(@"voip_one_minute_learn_voip", "");
        learnTPLabel.backgroundColor = [UIColor clearColor];
        learnTPLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_bottomView_text_color"];
        learnTPLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
        learnTPLabel.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:learnTPLabel];
    }
    
    return self;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ( !onTouchMove ){
        CommonWebViewController *controller = [[CommonWebViewController alloc] init];
        controller.url_string = @"http://www.chubao.cn/s/cptg/ios.html";
        controller.header_title = NSLocalizedString(@"voip_one_minute_learn_voip", "");
        UINavigationController *naviController = ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
        [naviController pushViewController:controller animated:YES];
    }else{
        onTouchMove = NO;
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    onTouchMove = YES;
}

@end
