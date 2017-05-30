//
//  AntiharassViewManager.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/16.
//
//

#import "AntiharassViewManager.h"
#import "AntiharassStepView.h"
#import "AntiharassFirstStartView.h"
#import "AntiharassLoadingView.h"
#import "AntiharassNetworkErrorView.h"
#import "AntiharassSuccessView.h"
#import "AntiharassRemoveConfirmView.h"
#import "AntiharassGuideView.h"
#import "AntiharassNoNetworkView.h"
#import "AntiharassGPRSView.h"
#import "AntiharassFailedView.h"
#import "TodayWidgetAnimationViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "UserDefaultsManager.h"
@interface AntiharassViewManager()<AntiharassStepViewDelegate>{
    AntiharassStepView *_view;
    AntiharassViewStep _step;
}
@property(nonatomic , retain)TodayWidgetAnimationViewController *con;
@end
@implementation AntiharassViewManager

- (void) showView:(AntiharassViewStep)step{
    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_IS_UPDATE_WITH_VIEW];

    if ( _view != nil ){
        [_view removeFromSuperview];
        _view = nil;
    }
    _step = step;
    AntiharassStepView *view;
    switch (step) {
        case ANTIHARASS_VIEW_FIRST_START:
            view = [[AntiharassFirstStartView alloc] init];
            break;
        case ANTIHARASS_VIEW_LOADING:
            view = [[AntiharassLoadingView alloc] init];
            [self performSelector:@selector(ifAutoShowTodayView) withObject:nil afterDelay:1];
            break;
        case ANTIHARASS_VIEW_NO_NETWORK:
            view = [[AntiharassNoNetworkView alloc]init];
            break;
        case ANTIHARASS_VIEW_GPRS_CONFIRM:
            view = [[AntiharassGPRSView alloc]init];
            break;
        case ANTIHARASS_VIEW_NETWORK_ERROR:
            view = [[AntiharassNetworkErrorView alloc]init];
            break;
        case ANTIHARASS_VIEW_SUCCESS:
            view =  [[AntiharassSuccessView alloc]init];
            break;
        case ANTIHARASS_VIEW_REMOVE_CONFIRM:
            view = [[AntiharassRemoveConfirmView alloc]init];
            break;
        case ANTIHARASS_VIEW_REMOVE_SUCCESS:
            view = [[AntiharassSuccessView alloc] initWithStep:ANTIHARASS_VIEW_REMOVE_SUCCESS];
            break;
        case ANTIHARASS_VIEW_GUIDE:
            view = [[AntiharassGuideView alloc]init];
            break;
        case ANTIHARASS_VIEW_REMOVE_LOADING:
            view = [[AntiharassLoadingView alloc] initWithStep:ANTIHARASS_VIEW_REMOVE_LOADING];
            break;
        case ANTIHARASS_VIEW_FAILED:
            view = [[AntiharassFailedView alloc]init];
            break;
        case ANTIHARASS_VIEW_VERSION_IS_NEWEST:
            view = [[AntiharassSuccessView alloc] initWithStep:ANTIHARASS_VIEW_VERSION_IS_NEWEST];
            break;
        default:
            break;
    }
    view.delegate = self;
    _view = view;
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow addSubview:view];
    [uiWindow bringSubviewToFront:view];
}

- (void) clearView{
    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_UPDATE_WITH_VIEW];
    if ( _view != nil ){
        [_view removeFromSuperview];
        _view = nil;
    }
}

- (void)clickSureButton{
    [_delegate finishViewStep:_step];
}

- (void)clickCancelButton{
    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_UPDATE_WITH_VIEW];
    if ( _view != nil ){
        [_view removeFromSuperview];
        _view = nil;
    }
}

-(void)ifAutoShowTodayView{
    if (![UserDefaultsManager boolValueForKey:ANTIHARASS_NOT_AUTO_SHOW_TODAY_VIEW_ONCE]) {
        
        [self clickTapButton];
        
    }
}

-(void)clickTapButton{
    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_IS_SHOW_TODAY_VIEW];
    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_NOT_AUTO_SHOW_TODAY_VIEW_ONCE];
    
    
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_CLOSE_TODAY_VIEW defaultValue:NO]){
        [DialerUsageRecord recordpath:PATH_TODAYWIDGETANIMATION kvs:Pair(CLOSE_AND_RE_READ, @(1)), nil];
    }
    _con = [[TodayWidgetAnimationViewController alloc]init];
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow addSubview:_con.view];
    [uiWindow  bringSubviewToFront:_con.view];
}

- (void)refreshLoadingViewStage:(AntiharassModelStep)result{
    if ( _step == ANTIHARASS_VIEW_LOADING ){
        [((AntiharassLoadingView *)_view) refreshStep:result];
    }
}

- (void) refreshLoadingViewPercent:(NSInteger)percent{
    if ( _step == ANTIHARASS_VIEW_LOADING ) {
        [((AntiharassLoadingView *)_view) refreshPercent:percent];
    }
        
}

@end
