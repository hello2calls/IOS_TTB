//
//  PersonalCenterControllerNew.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/13.
//
//
#import "SingleGuideViewWithBaozai.h"
#import "LoginController.h"
#import "CootekViewController.h"
@interface PersonalCenterController : CootekViewController<LoginProtocol>

@property(nonatomic,retain,nullable)UIScrollView *contentScrollView;

+(instancetype  __nonnull)getPersonalCenterVC;
@end
