//
//  AskLikeCellView.m
//  TouchPalDialer
//
//  Created by game3108 on 16/3/10.
//
//

#import "AskLikeCellView.h"
#import "TPDialerResourceManager.h"

@interface AskLikeCellView(){
    UILabel *_circleView;
    NSString *_number;
}

@end

@implementation AskLikeCellView

- (instancetype) initWithFrame:(CGRect)frame andDictionary:(NSDictionary *)dict{
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        _isSelect = YES;
        _number = dict[@"number"];
        self.backgroundColor = [UIColor whiteColor];
        
        _circleView = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, 13, 30, 30)];
        _circleView.backgroundColor = [UIColor whiteColor];
        _circleView.layer.masksToBounds = YES;
        _circleView.layer.cornerRadius = 15.0f;
        _circleView.text = @"x";
        _circleView.font = [UIFont fontWithName:@"iPhoneIcon2" size:24];
        _circleView.textAlignment = NSTextAlignmentCenter;
        _circleView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
        [self addSubview:_circleView];
        
        UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 40, 40)];
        iconView.backgroundColor = [UIColor whiteColor];
        iconView.layer.cornerRadius = 20.0f;
        iconView.layer.masksToBounds = YES;
        iconView.image = dict[@"image"];
        [self addSubview:iconView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(64, 8, frame.size.width-104, 16)];
        titleLabel.text = dict[@"displayName"];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [self addSubview:titleLabel];
        
        UILabel *subLabel = [[UILabel alloc]initWithFrame:CGRectMake(64, 34, frame.size.width-104, 14)];
        subLabel.text = dict[@"number"];
        subLabel.font = [UIFont systemFontOfSize:13];
        subLabel.textAlignment = NSTextAlignmentLeft;
        subLabel.backgroundColor = [UIColor whiteColor];
        subLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        [self addSubview:subLabel];
        
        
        [self addTarget:self action:@selector(onButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)onButtonClick{
    if (_isSelect){
        _circleView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_300"];
    }else{
        _circleView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
    }
    _isSelect = !_isSelect;
    [_delegate onButtonClick:_number isSelect:_isSelect];
}

@end
