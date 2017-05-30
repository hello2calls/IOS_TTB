//
//  AntiharassSuccessView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/16.
//
//

#import "AntiharassSuccessView.h"

@interface AntiharassSuccessView(){
    UILabel *_firstLabel;
    UILabel *_iconLabel;
    UILabel *_secondLabel;
}

@end

@implementation AntiharassSuccessView

- (instancetype)init{
    self = [super init];
    if ( self ){
        UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-280)/2, (TPScreenHeight()-300)/2, 280, 290)];
        middleView.backgroundColor = [UIColor whiteColor];
        middleView.layer.masksToBounds = YES;
        middleView.layer.cornerRadius = 4.0f;
        [self addSubview:middleView];
        
        CGFloat globalY = 30;
        
        _firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 18)];
        _firstLabel.text = @"更新骚扰号码库";
        _firstLabel.backgroundColor = [UIColor clearColor];
        _firstLabel.textAlignment = NSTextAlignmentCenter;
        _firstLabel.font = [UIFont boldSystemFontOfSize:17];
        _firstLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [middleView addSubview:_firstLabel];
        
        globalY += _firstLabel.frame.size.height + 30;
        
        _iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 90)];
        _iconLabel.text = @"w";
        _iconLabel.backgroundColor = [UIColor clearColor];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:72];
        _iconLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
        [middleView addSubview:_iconLabel];
        
        globalY += _iconLabel.frame.size.height + 10;
        
        _secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 16)];
        _secondLabel.text = @"更新完毕";
        _secondLabel.backgroundColor = [UIColor clearColor];
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        _secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [middleView addSubview:_secondLabel];
        
        globalY += _secondLabel.frame.size.height + 30;
        
        UIButton *sureButton = [[TPButton alloc]initWithFrame:CGRectMake(20, globalY, 240, 46) withType:GRAY_LINE withFirstLineText:@"确定" withSecondLineText:nil];
        [sureButton addTarget:self action:@selector(onSureButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:sureButton];
    }
    return self;
}

- (instancetype)initWithStep:(AntiharassViewStep)step{
    self = [self init];
    if ( self ){
        if ( step == ANTIHARASS_VIEW_REMOVE_SUCCESS ){
            _firstLabel.text = @"删除骚扰号码库";
            _secondLabel.text = @"删除完毕";
        }else if ( step == ANTIHARASS_VIEW_VERSION_IS_NEWEST ){
            _firstLabel.text = @"更新骚扰号码库";
            _secondLabel.text = @"已是最新版本";
            _iconLabel.text = @"G";
            _iconLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_400"];
        }
        
    }
    return self;
}

- (void)onSureButtonPressed{
    [self.delegate clickSureButton];
}



@end
