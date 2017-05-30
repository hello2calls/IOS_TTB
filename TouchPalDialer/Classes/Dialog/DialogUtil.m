//
//  DialogUtil.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/15.
//
//

#import "DialogUtil.h"
BOOL ifNotSeeBgView;
static NSMutableArray *sBgViewArray;

@implementation DialogUtil

+ (void)showDialogWithContentView:(UIView *)view inRootView:(UIView *)rootView notSeeBgView:(BOOL)notSeeBgView{
    ifNotSeeBgView = notSeeBgView;
    CGRect frame = view.frame;
    [self showDialogWithContentView:view withFrame:CGRectMake((TPScreenWidth() - frame.size.width) / 2, (TPScreenHeight() - frame.size.height) / 2, frame.size.width, frame.size.height) inRootView:rootView];
}

+ (void)showDialogWithContentView:(UIView *)view inRootView:(UIView *)rootView{
    ifNotSeeBgView = NO;
    CGRect frame = view.frame;
    [self showDialogWithContentView:view withFrame:CGRectMake((TPScreenWidth() - frame.size.width) / 2, (TPScreenHeight() - frame.size.height) / 2, frame.size.width, frame.size.height) inRootView:rootView];
}

+ (void)showDialogWithContentView:(UIView *)view withFrame:(CGRect)frame inRootView:(UIView *)rootView{
    if (!sBgViewArray) {
        sBgViewArray = [[NSMutableArray alloc]initWithCapacity:1];
    }else{
        return;
    }
    view.alpha = 0;
    UIView *realBgView ;

    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    UIView *whiteView  ;
    if (ifNotSeeBgView) {
        whiteView =[[UIView alloc]initWithFrame:bgView.frame];
        whiteView.backgroundColor = [UIColor whiteColor];
        [whiteView addSubview:bgView];
        realBgView = whiteView;
    }else{
        realBgView = bgView;
    }
    
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0;
    
    
    if (rootView) {
        [rootView addSubview:realBgView];
        [rootView addSubview:view];
        [rootView bringSubviewToFront:view];
    } else {
        UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [uiWindow addSubview:realBgView];
        [uiWindow addSubview:view];
        [uiWindow bringSubviewToFront:view];
    }
    view.frame = frame;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1;
        bgView.alpha = 0.7;
    }];
        [sBgViewArray addObject:realBgView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeView) name:DIALOG_DISMISS object:nil];
}

+ (void)closeView {
    UIView *bgView;
    if (sBgViewArray.count > 0) {
        bgView = [sBgViewArray objectAtIndex:0];
    }
    if (bgView) {
        [UIView animateWithDuration:0.3 animations:^{
            bgView.alpha = 0;
        }completion:^(BOOL finish){
            [bgView removeFromSuperview];
            if(sBgViewArray.count>0){
            [sBgViewArray removeObjectAtIndex:0];
            }
            if (sBgViewArray.count == 0) {
                [[NSNotificationCenter defaultCenter]removeObserver:self];
            }
            sBgViewArray = nil;
        }];
    }
}

@end
