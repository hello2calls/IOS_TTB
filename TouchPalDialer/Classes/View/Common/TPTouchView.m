//
//  TPTouchView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/30.
//
//

#import "TPTouchView.h"

@implementation TPTouchView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_delegate tpTouchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [_delegate tpTouchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_delegate tpTouchesEnded:touches withEvent:event];
}

@end
