//
//  CheckboxAlertViewHandler.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/30.
//
//

#import "CheckboxAlertViewHandler.h"
#import "CheckboxAlertView.h"

static CheckboxAlertViewHandler *handler = nil;

@interface CheckboxAlertViewHandler()

@end

@implementation CheckboxAlertViewHandler

+ (void)initialize{
    handler = [[CheckboxAlertViewHandler alloc]init];
}

+ (void) showAlertTitle:(NSString *)alertTitle andKey:(NSString *)key{
    CheckboxAlertView *view = [[CheckboxAlertView alloc]initWithTitle:alertTitle andKey:key];
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow addSubview:view];
    [uiWindow bringSubviewToFront:view];
}


@end
