//
//  TouchableView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-10-17.
//
//

#import "TouchableView.h"

@implementation TouchableView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate onViewTouch];
}

@end
