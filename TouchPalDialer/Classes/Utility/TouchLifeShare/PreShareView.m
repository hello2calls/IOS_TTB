//
//  PreShareView.m
//  TouchPalDialer
//
//  Created by game3108 on 16/1/13.
//
//

#import "PreShareView.h"

@implementation PreShareView

- (id)initWithFrame:(CGRect)frame andShareData:(ShareData *)shareData{
    return nil;
}



- (void)onCloseClicked {
    if (_cancelBlock) {
        _cancelBlock();
    }
    [self removeFromSuperview];
}

- (void)onShareClicked {
    if (_shareBlock) {
        _shareBlock();
    }
    [self removeFromSuperview];
}

@end
