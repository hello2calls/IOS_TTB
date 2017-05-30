//
//  CootekTableView.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/3/14.
//
//

#import "CootekTableView.h"

@implementation CootekTableView

@synthesize cootekDelegate;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [cootekDelegate onTouchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [cootekDelegate onTouchesEnd:touches withEvent:event];
}

@end
