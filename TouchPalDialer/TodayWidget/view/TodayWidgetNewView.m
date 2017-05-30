//
//  TodayWidgetNewView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/9.
//
//

#import "TodayWidgetNewView.h"

@implementation TodayWidgetNewView

- (instancetype)initWithDelegte:(id<TodayWidgetMainViewDelegate>)delegate{
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.delegate = delegate;
    if ([delegate ifShowUpdateViewInToday]) {
        self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, 160)];
        self.updateView.hidden = NO;
    }
    else{
        self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, 80)];
        self.updateView.hidden = YES;
    }
    if ( self ){
        
    }
    
    return self;
}

- (NSString *)getMainLabelText{
    return @"复制号码,触宝帮您查询信息及归属地";
}

- (NSString *)getSubLabelText{
    return @"操作指南:复制号码->点击此处，立即查询";
}

@end
