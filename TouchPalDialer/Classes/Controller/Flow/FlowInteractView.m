//
//  FlowInteractView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/3/3.
//
//

#import "FlowInteractView.h"

@implementation FlowInteractView
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder]touchesBegan:touches withEvent:event];
}
@end
