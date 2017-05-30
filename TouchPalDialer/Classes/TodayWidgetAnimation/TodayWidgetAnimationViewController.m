//
//  TodayWidgetAnimationViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/31.
//
//

#import "TodayWidgetAnimationViewController.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "TodayWidgetPageControl.h"
#import "TodayWidgetAnimationFirstView.h"
#import "TodayWidgetAnimationSecondView.h"
#import "TodayWidgetAnimationThirdView.h"
#import "TodayWidgetAnimationForthView_iOS10.h"
#import "TodayWidgetAnimationForthView.h"
#import "TodayWidgetAnimationView.h"
#import "DialerUsageRecord.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"

@interface TodayWidgetAnimationViewController()<UIScrollViewDelegate>{
    NSInteger _pageNumber;
    NSInteger _lastPage;
    NSInteger _currentPage;

    UIScrollView *_scrollView;

    TodayWidgetPageControl *_pageControl;

    TodayWidgetAnimationFirstView *_firstView;
    TodayWidgetAnimationSecondView *_secondView;
    TodayWidgetAnimationThirdView *_thirdView;
    TodayWidgetAnimationView *_forthView;

    NSArray *_viewArray;
}

@end

@implementation TodayWidgetAnimationViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    [DialerUsageRecord recordpath:PATH_TODAY_WIDGET kvs:Pair(ANTIHARASS_SHOW_TODAY_WDIGET_ANIMATION,@(1)), nil];

    //scrollview调整位置
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];

    _pageNumber = 4;
    _currentPage = 0;
    _lastPage = 0;

    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    _scrollView.contentSize = CGSizeMake(TPScreenWidth() * _pageNumber, TPScreenHeight());
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    [self.view addSubview:_scrollView];

    _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth()-50, -50, 100, 100)];
    _closeButton.layer.masksToBounds = YES;
    _closeButton.layer.cornerRadius = 50.0f;
    [_closeButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"] withFrame:_closeButton.bounds] forState:UIControlStateNormal];
    [_closeButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_200"] withFrame:_closeButton.bounds] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(onBackButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];

    UILabel *closeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 60, 20, 20)];
    closeLabel.text = @"F";
    closeLabel.textAlignment = NSTextAlignmentCenter;
    closeLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:18];
    closeLabel.textColor = [UIColor whiteColor];
    closeLabel.backgroundColor = [UIColor clearColor];
    [_closeButton addSubview:closeLabel];

    _firstView = [[TodayWidgetAnimationFirstView alloc]initWithFrame:_scrollView.bounds];
    [_scrollView addSubview:_firstView];

    _secondView = [[TodayWidgetAnimationSecondView alloc]initWithFrame:CGRectMake(TPScreenWidth(), 0, TPScreenWidth(), TPScreenHeight())];
    [_scrollView addSubview:_secondView];

    _thirdView = [[TodayWidgetAnimationThirdView alloc]initWithFrame:CGRectMake(TPScreenWidth()*2, 0, TPScreenWidth(), TPScreenHeight())];
    [_scrollView addSubview:_thirdView];
    
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10 ) {
         _forthView = [[TodayWidgetAnimationForthView_iOS10 alloc]initWithFrame:CGRectMake(TPScreenWidth()*3, 0, TPScreenWidth(), TPScreenHeight())];
    } else {
         _forthView = [[TodayWidgetAnimationForthView alloc]initWithFrame:CGRectMake(TPScreenWidth()*3, 0, TPScreenWidth(), TPScreenHeight())];
    }
   
    [_scrollView addSubview:_forthView];


    _pageControl = [[TodayWidgetPageControl alloc]initWithFrame:CGRectMake((TPScreenWidth()-90)/2, TPScreenHeight()-40, 90, 16)];
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.numberOfPages = _pageNumber;
    _pageControl.currentPage = _currentPage;
    [self.view addSubview:_pageControl];

    _viewArray = [NSArray arrayWithObjects:_firstView,_secondView,_thirdView,_forthView, nil];

    [_firstView doAnimation];

}

- (void)onBackButtonPressed{
    if (self.navigationController==nil) {
        [self.view removeFromSuperview];
        [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_SHOW_TODAY_VIEW];
        [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_CLOSE_TODAY_VIEW];
    }else{
    [self.navigationController popViewControllerAnimated:YES];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

- (void)dealloc{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page != _currentPage) {
        _currentPage = page;
        _pageControl.currentPage = page;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ( _currentPage == _lastPage )
        return;
    TodayWidgetAnimationView *lastView = [_viewArray objectAtIndex:_lastPage];
    [lastView refreshView];

    TodayWidgetAnimationView *nowView = [_viewArray objectAtIndex:_currentPage];
    [nowView doAnimation];

    _lastPage = _currentPage;

    if ( ![UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_LOG_PUSH defaultValue:NO]
        && [UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_1 defaultValue:NO]
        && [UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_2 defaultValue:NO]
        && [UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_3 defaultValue:NO]
        && [UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_4 defaultValue:NO]
        ){
        [DialerUsageRecord recordYellowPage:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_TODAY_WIDGET_ANIMATION_SHOWN_FINISH, @(1)), nil];
        [UserDefaultsManager setBoolValue:YES forKey:TODAY_WIDGET_ANIMATION_SHOWN_LOG_PUSH];
    }
}

@end
