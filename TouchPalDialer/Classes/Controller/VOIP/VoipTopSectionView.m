//
//  VoipTopSectionView.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-5.
//
//

#import "VoipTopSectionView.h"
#import "VoipTopSectionMiddleView.h"
#import "VoipTopSectionBottomView.h"

#define WIDTH_ADAPT TPScreenWidth()/375

@implementation VoipTopSectionView{
    VoipTopSectionMiddleView *_middleView;
    VoipTopSectionBottomView *_bottomView;
}

- (id) initWithFrame:(CGRect)frame andBgColor:(UIColor*)bgColor{
    self = [super initWithFrame:frame];
    
    if (self){
        
        self.backgroundColor = bgColor;
        NSInteger middleViewHeight = VOIP_BREATHING_OUTTER_CIRCLE_RADIUS * WIDTH_ADAPT;
        NSInteger bottomViewHeight = 28 ;
        
        _middleView = [[VoipTopSectionMiddleView alloc] initWithFrame:CGRectMake((frame.size.width - middleViewHeight)/2, 10+(frame.size.height - middleViewHeight)/2, middleViewHeight , middleViewHeight)];
        [self addSubview:_middleView];
        
        
        _bottomView = [[VoipTopSectionBottomView alloc] initWithFrame:CGRectMake((frame.size.width- 270*WIDTH_ADAPT)/2, frame.size.height - bottomViewHeight  - 10*WIDTH_ADAPT, 270*WIDTH_ADAPT, bottomViewHeight) andBgColor:bgColor];
        [self addSubview:_bottomView];
    }
    
    return self;
}


- (VoipTopSectionMiddleView*) getMiddleView{
    return _middleView;
}

@end
