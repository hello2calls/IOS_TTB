//
//  UILayoutUtility.m
//  TouchPalDialer
//
//  Created by Chen Lu on 9/17/12.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#import "UILayoutUtility.h"
#import "TouchPalDialerAppDelegate.h"

CGFloat TPStatusBarHeight(void)
{
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    return rect.size.height;
}

CGFloat TPHeaderBarHeight(void)
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if ((UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) && [[UIApplication sharedApplication] isStatusBarHidden]) {
        return 45;
    } else {
        if ([[UIDevice currentDevice].systemVersion intValue] >= 7) {
            return 65;
        }
    }
    return 45;
}

CGFloat TPHeaderBarHeightDiff(void)
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if ((UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) && [[UIApplication sharedApplication] isStatusBarHidden]) {
        return 0;
    } else {
        if ([[UIDevice currentDevice].systemVersion intValue] >= 7 && ![[UIApplication sharedApplication] isStatusBarHidden]) {
            return 20;
        }
    }
    
    return 0;
}

CGFloat TPScreenHeight(void)
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
        return rect.size.width > rect.size.height ? rect.size.height : rect.size.width;
    } else {
        return rect.size.width > rect.size.height ? rect.size.width : rect.size.height;
    }
}

CGFloat TPAppFrameHeight(void)
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
        return rect.size.width > rect.size.height ? rect.size.height : rect.size.width;
    } else {
        return rect.size.width > rect.size.height ? rect.size.width : rect.size.height;
    }
}

CGFloat TPScreenWidth(void)
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
        return rect.size.width > rect.size.height ? rect.size.width : rect.size.height;
    } else {
        return rect.size.width > rect.size.height ? rect.size.height : rect.size.width;
    }
}

BOOL isIPhone5Resolution(void)
{
    return TPScreenHeight() > 500; // 568
}

BOOL isIPhone6Resolution(void) {
    /*
     Device, Screen Height
    
     iPhone5s, 568
     iPhone6,  667
    */
    return TPScreenHeight() > 570;
}

CGFloat TPHeightOrYFitIPhone5(CGFloat height)
{
    return isIPhone5Resolution() ? height + 88 : height;
}

CGFloat TPHeightBetweenIP4AndIP5(void)
{
    return isIPhone5Resolution() ? 0 : 88;
}

CGFloat TPHeightFit(CGFloat height)
{
    if (TPScreenHeight()<500) {
        return height;
    }else if (TPScreenHeight()>=500&&TPScreenHeight()<600){
        return height + 88;
    }else if (TPScreenHeight()>=600&&TPScreenHeight()<700){
        return height +187;
    }else if (TPScreenHeight()>=700){
        return height + 256;
    }else{
        return height;
    }
}
CGFloat TPKeypadHeight(void)
{
    if (TPScreenHeight()>=600&&TPScreenHeight()<700){
        return 264;
    }else if (TPScreenHeight()>=700){
        return 270;
    }else{
        return 228;
    }
}

CGFloat TPScaledHeight(CGFloat originalHeight) {
    return originalHeight / IPHONE_5_HEIGHT_POINTS * TPScreenHeight();
}

CGFloat TPScaledWidth(CGFloat originalWidth) {
    return originalWidth / IPHONE_5_WIDTH_POINTS * TPScreenWidth();
}

CGSize TPScaledSizeMake(CGFloat originalWidth, CGFloat originalHeight) {
    return CGSizeMake(TPScaledWidth(originalWidth), TPScaledHeight(originalHeight));
}

CGSize TPScaledSize(CGSize originalSize) {
    return TPScaledSizeMake(originalSize.width, originalSize.height);
}

