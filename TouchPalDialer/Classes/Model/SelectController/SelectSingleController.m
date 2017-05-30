//
//  SelectSingleController.m
//  TouchPalDialer
//
//  Created by game3108 on 16/4/13.
//
//

#import "SelectSingleController.h"
#import "SelectSingleView.h"

@interface SelectSingleController()<SelectSingleViewDelegate>{
}

@end

@implementation SelectSingleController

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void) showSelectViewBySelectArray:(NSArray *)selectArray{
    SelectSingleView *singleView = [[SelectSingleView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) andSelectArray:selectArray];
    singleView.delegate = self;
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow addSubview:singleView];
}

#pragma mark SelectSingleViewDelegate

- (void)select:(NSDictionary *)dict{
    [_delegate select:dict];
}
@end
