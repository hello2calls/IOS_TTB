//
//  TodayWidgetMainView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/9.
//
//

#import "TodayWidgetMainView.h"
#import "TPButton.h"
#import "TodayWidgetUtil.h"
#import "UserDefaultKeys.h"
@interface TodayWidgetMainView(){
    NSNumber *num;
}

@end

@implementation TodayWidgetMainView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        _viewButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_viewButton];
        [_viewButton addTarget:self action:@selector(onPressBgButton) forControlEvents:UIControlEventTouchUpInside];
        
        _lableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 80)];
        [_viewButton addSubview:_lableView];
        
        _mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 20, _lableView.frame.size.width - 50, 20)];
        _mainLabel.backgroundColor = [UIColor clearColor];
        _mainLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        _mainLabel.textColor = [UIColor whiteColor];
        _mainLabel.textAlignment = NSTextAlignmentLeft;
        _mainLabel.text = [self getMainLabelText];
        [_lableView addSubview:_mainLabel];
        
        _subLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, CGRectGetMaxY(_mainLabel.frame)+2, _lableView.frame.size.width - 50, 20)];
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        _subLabel.textColor = [TodayWidgetUtil getColor:@"0x80ffffff"];
        _subLabel.textAlignment = NSTextAlignmentLeft;
        _subLabel.text = [self getSubLabelText];
        [_lableView addSubview:_subLabel];
        
        _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(_lableView.frame.size.width-85, 30, 64, 27)];
        _rightButton.layer.masksToBounds = YES;
        _rightButton.layer.cornerRadius = 4.0f;
        _rightButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        _rightButton.hidden = YES;
        [_rightButton setTitle:@"拨打" forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[TodayWidgetUtil imageWithColor:[TodayWidgetUtil getColor:@"0x37c763"] withFrame:CGRectMake(0, 0, _rightButton.frame.size.width, _rightButton.frame.size.height)] forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[TodayWidgetUtil imageWithColor:[TodayWidgetUtil getColor:@"0x2c9f4f"] withFrame:CGRectMake(0, 0, _rightButton.frame.size.width, _rightButton.frame.size.height)] forState:UIControlStateHighlighted];
        [_lableView addSubview:_rightButton];
        [_rightButton addTarget:self action:@selector(onPressRightButton) forControlEvents:UIControlEventTouchUpInside];
        _updateView  =[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_rightButton.frame)+15,frame.size.width, 100)];
        _updateView.backgroundColor = [UIColor clearColor];
        [self addSubview:_updateView];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 10, frame.size.width-20*2, 0.5)];
        
        _lineView.backgroundColor = [TodayWidgetUtil getColor:@"0xB3ffffff"];
        [_updateView addSubview:_lineView];
        
        _messageLable = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(_lineView.frame)+17, frame.size.width-120, 21)];
        _messageLable.backgroundColor =[UIColor clearColor];
        _messageLable.text = @"骚扰号码库有更新，防骚扰";
        _messageLable.textColor = [UIColor whiteColor];
        _messageLable.numberOfLines=0;
        _messageLable.font =[UIFont systemFontOfSize:15];
        [_updateView addSubview:_messageLable];

        
         _messageLable2 = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(_messageLable.frame), frame.size.width-120, 21)];
        _messageLable2.backgroundColor =[UIColor clearColor];
        
        _messageLable2.text = [[NSString stringWithFormat:@"能力提升%d", [[[[NSUserDefaults alloc] initWithSuiteName:@"group.com.cootek.Contacts"] valueForKey:ANTIHARASS_REMOTE_VERSION] intValue]%26+10] stringByAppendingString:@"%，是否更新？"];
        _messageLable2.textColor = [UIColor whiteColor];
        _messageLable2.numberOfLines=0;
        _messageLable2.font =[UIFont systemFontOfSize:15];
        [_updateView addSubview:_messageLable2];
        
        _updateButton =[UIButton buttonWithType:(UIButtonTypeCustom)];
        _updateButton.layer.masksToBounds = YES;
        _updateButton.layer.cornerRadius = 4.0f;
        _updateButton.layer.borderColor = [TodayWidgetUtil getColor:@"0x33ffffff"].CGColor;
        _updateButton.layer.borderWidth = 1.0f;
        [_updateButton setTitle:@"立即更新" forState:UIControlStateNormal];
        _updateButton.frame = CGRectMake(frame.size.width-85, (100-10)/2, 64, 27);
        _updateButton.center = CGPointMake(_updateButton.center.x, (_updateView.frame.size.height-CGRectGetMaxY(_lineView.bounds))/2);
        [_updateButton setBackgroundImage:[TodayWidgetUtil imageWithColor:[TodayWidgetUtil getColor:@"0xCCffffff"] withFrame:CGRectMake(0, 0, _updateButton.frame.size.width, _updateButton.frame.size.height)] forState:UIControlStateHighlighted];
        _updateButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        [_updateButton setTitleColor:[TodayWidgetUtil getColor:@"0x33ffffff"] forState:UIControlStateNormal];
        [_updateButton addTarget:self action:@selector(onPressUpdateButton ) forControlEvents:UIControlEventTouchUpInside];
        [_updateView addSubview:_updateButton];
    
    }
    
    return self;
}


- (void)onPressBgButton{
    [_delegate onPressBgButton];
}

- (void)onPressRightButton{
    [_delegate onPressRightButton];
}

- (void)onPressUpdateButton{
    [_delegate onPressUpdateButton];
}

- (NSString *)getMainLabelText{
    return @"basic";
}

- (NSString *)getSubLabelText{
    return @"basic";
}

@end
