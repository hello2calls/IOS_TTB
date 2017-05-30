//
//  TodayWidgetNoInfoView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/10.
//
//

#import "TodayWidgetNoInfoView.h"
#import "NSString+PhoneNumber.h"

@interface TodayWidgetNoInfoView(){
    NSString *_number;
    NSString *_attr;
}

@end

@implementation TodayWidgetNoInfoView

- (instancetype)initWithNumber:(NSString*)number andAttr:(NSString*)attr andIfFreeCall:(BOOL)ifFreeCall delegate:(id<TodayWidgetMainViewDelegate>)delegate{
    _number = number;
    _attr = attr;
    self.delegate = delegate;
    CGRect rect = [[UIScreen mainScreen] bounds];
    if ([self.delegate ifShowUpdateViewInToday]) {
        self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, 160)];
        self.updateView.hidden = NO;
    }
    else{
        self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, 80)];
        self.updateView.hidden = YES;
    }
    if ( self ){
        
        self.rightButton.hidden = NO;
        if ( ifFreeCall ){
            [self.rightButton setTitle:@"免费拨打" forState:UIControlStateNormal];
        }else{
            [self.rightButton setTitle:@"拨打" forState:UIControlStateNormal];
        }
        self.rightButton.center = CGPointMake(self.rightButton.center.x, 40);
    }
    return self;
}

- (void)onPressBgButton{
    [self.delegate onPressBgButton];
}


- (NSString *)getMainLabelText{
    if ( _number.length < 10)
        return _number;
    else {
        NSMutableString *temptStr = [[NSMutableString alloc]initWithString:_number];
        NSString *text = [temptStr formatPhoneNumber];
        return text;
    }
}

- (NSString *)getSubLabelText{
    return _attr;
}

@end
