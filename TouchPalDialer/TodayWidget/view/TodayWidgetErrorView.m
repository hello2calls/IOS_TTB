//
//  TodayWidgetErrorView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/10.
//
//

#import "TodayWidgetErrorView.h"

@interface TodayWidgetErrorView(){
    NSString *errorStr;
}

@end

@implementation TodayWidgetErrorView

- (instancetype)initWithString:(NSString *)string delegate:(id<TodayWidgetMainViewDelegate>)delegate{
    errorStr = string;
    self.delegate = delegate;
    CGRect rect = [[UIScreen mainScreen] bounds];
    if ([delegate ifShowUpdateViewInToday]) {
        self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, 160)];
        self.updateView.hidden =NO;
    }else{
    self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, 80)];
        self.updateView.hidden =YES;
    }
    return self;
}

- (NSString *)getMainLabelText{
    return errorStr;
}

- (NSString *)getSubLabelText{
    return @"操作指南:复制号码->点击此处，立即查询";
}
- (void)onPressBgButton{
    [self.delegate onPressBgButton];
}
@end
