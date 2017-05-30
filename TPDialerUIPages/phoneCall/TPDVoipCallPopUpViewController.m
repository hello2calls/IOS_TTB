


//
//  TPDVoipCallPopUpViewController.m
//  TouchPalDialer
//
//  Created by H L on 2016/11/28.
//
//

#import "TPDVoipCallPopUpViewController.h"
#import "TPDLib.h"
#import <Masonry.h>
#import "UserDefaultsManager.h"
#import "PhoneNumber.h"
#import "CallLog.h"
#import "VOIPCall.h"
#import "TPCallActionController.h"

@interface TPDVoipCallPopUpViewController ()
@property (nonatomic, strong) VoipCallPopUpView *popUpView;
@end

@implementation TPDVoipCallPopUpViewController
-(void)callVoipDirectly{
    [self.popUpView sendVoipButtonClickMessage];
//    [self dismissViewControllerAnimated:NO completion:^{
//        
//    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (self.type == 40000) {
        self.popUpView = [[VoipCallPopUpView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) andTestCallName:self.callName];
    }else {
        self.popUpView = [[VoipCallPopUpView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) andCallLog:self.callLog andType:self.type];
    }
    self.popUpView.delegate = self;
    
    [self.view addSubview:self.popUpView];
    [self.popUpView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    WEAK(self)
    [[NSNotificationCenter defaultCenter] addObserverForName:@"V6_POPUP_AD_CLICK" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakself onClickCancelButton];
    }];


}

#pragma mark VoipCallPopUpViewDelegate
// 按下免费电话按钮
- (void)onClickFreeCallButton:(NSArray *)numbers {
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        
        self.callLog.number = numbers[0];
        if (![[PhoneNumber sharedInstance] isCNSim]) {
            self.callLog.number = [PhoneNumber getCNnormalNumber:self.callLog.number];
        }
        [CallLog addPendingCallLog:self.callLog];
        [self dismissViewControllerAnimated:NO completion:^{
            if (numbers.count>1) {
                [VOIPCall makeConferenceCall:numbers];
            }else{
                [VOIPCall makeCall:self.callLog.number];
            }
            
        }];

    } else {
        [self onClickNormalCallButton];
        
    }
    [[GlobalVariables getInstance].enterCallPageSignal sendNext:nil];
    
}

// 按下普通电话按钮
- (void)onClickNormalCallButton {
    [[TPCallActionController controller] makeCallAfterVoipChoice:self.callLog isGestureCall:NO];
    [[GlobalVariables getInstance].enterCallPageSignal sendNext:nil];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}
- (void)onClickCancelButton {
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}
- (void)onClickInviteButton {
    
    
    
}
@end
