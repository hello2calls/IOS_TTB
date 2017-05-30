///
//  TodayViewController.m
//  TodayWidget
//
//  Created by game3108 on 15/5/27.
//
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TodayWidgetFactory.h"
#import "TodayWidgetMainView.h"
#import "TodayWidgetUtil.h"

@interface TodayViewController () <NCWidgetProviding,TodayWidgetFactoryDelegate>{
    NSURLConnection *conn;
    TodayWidgetFactory *_widgetFactory;
    TodayWidgetMainView *_mainView;
    NSString *copyString;
   
    
}
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _widgetFactory = [[TodayWidgetFactory alloc]init];
    _widgetFactory.context = self.extensionContext;
    _widgetFactory.delegate = self;
    _mainView = [_widgetFactory getTodayWidgetView];
    [self.view addSubview:_mainView];
    [_widgetFactory recordTimes];
    
    [self.timer fire];
   
//    I can`t understand why need to delay
    
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^{
//        [_widgetFactory onPressBgButton];
//    });
   
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.timer setFireDate:[NSDate distantPast]];
}
-(NSTimer *)timer{
    if (_timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateInfo) userInfo:nil repeats:YES];
         [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
}

-(void)updateInfo{
    NSString *newCopying = [TodayWidgetUtil getNormalizePhoneNumber:[TodayWidgetUtil getNumberFromPasteboard:[UIPasteboard generalPasteboard].string]];
    if (![copyString  isEqualToString: newCopying]){
        copyString = newCopying;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_widgetFactory onPressBgButton];
        });
    }
}

- (void)refreshView{
    [_mainView removeFromSuperview];
    _mainView = nil;
    _mainView = [_widgetFactory getTodayWidgetView];
    [self.view addSubview:_mainView];
}

- (void)adjustViewHeight:(float)height{
    self.preferredContentSize = CGSizeMake(0, height);
}



- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
