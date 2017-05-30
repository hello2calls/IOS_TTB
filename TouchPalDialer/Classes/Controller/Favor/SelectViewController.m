    //
//  YellowPageViewController.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-17.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "SelectViewController.h"
#import "Person.h"
#import "Favorites.h"
#import "ContactCacheDataManager.h"
#import "CootekNotifications.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
@interface SelectViewController ()

@property (nonatomic, retain)UIAlertView *waitView;

@end

@implementation SelectViewController
@synthesize dataList;
@synthesize select_view;
@synthesize delegate;
@synthesize viewType;
@synthesize commandName;
@synthesize autoDismiss;
- (id)init{
    self = [super init];
    autoDismiss = YES;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"defaultBackground_color"];
    if(dataList==nil){
        self.dataList = [Person queryAllContacts];
    }
    if (viewType != SelectViewGroupCommandAll && viewType != SelectViewGroupCommandGroup) {
        viewType = SelectViewNormal;
    }
	SelectView *temp_view=[[SelectView alloc] initWithPersonArrayAndViewTypeAndCommandName:dataList ViewType:viewType CommandName:commandName andIfSingle:_isChooseSingle];
	temp_view.select_view_delegate = self;
    temp_view.groupId = self.groupID;
	self.select_view=temp_view;
    
	[self.view addSubview:temp_view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDismissSelf) name:N_PREPARE_TO_SEND_SMS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectViewCancel) name:N_PERSON_DATA_CHANGED object:nil];
}

-(void)willDismissSelf {
    UINavigationController *navController =
    ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
    [navController popViewControllerAnimated:YES];
}

-(void)selectViewCancel{
	//[self dismissModalViewControllerAnimated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navController = [TouchPalDialerAppDelegate naviController];
        [navController popViewControllerAnimated:YES];
        if (delegate!=nil && [delegate respondsToSelector:@selector(selectViewCancel)]) {
            [delegate selectViewCancel];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_ALL_VIEW_CONTROLLER object:nil];
    });

}

-(void)selectViewFinish:(NSArray *)select_list{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWaitView) name:N_SHOW_INDICATOR object:nil];
    if (autoDismiss) {
        UINavigationController *navController = [TouchPalDialerAppDelegate naviController];
        [navController popViewControllerAnimated:YES];
    }
    if ([delegate respondsToSelector:@selector(selectViewFinish:)]) {
         [delegate selectViewFinish:select_list];
    }
   
}

-(void)selectItem:(SelectModel *)select_item{
    [delegate selectItem:select_item];
    UINavigationController *navController = [TouchPalDialerAppDelegate naviController];
    [navController popViewControllerAnimated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    cootek_log(@"Received memory warning in SelectViewController.");
}

- (void) showWaitView {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"正在删除联系人" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.hidesWhenStopped = YES;
        [indicatorView startAnimating];
        if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 7.0f) {
            indicatorView.center = CGPointMake(alert.bounds.size.width/2.0f, alert.bounds.size.height / 2);
            [alert setValue:indicatorView forKey:@"accessoryView"];
        }else{
            indicatorView.frame = CGRectMake(TPScreenWidth() / 2 - 26, 60, 12,12);
            [alert addSubview:indicatorView];
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });

        self.waitView = alert;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:N_SHOW_INDICATOR object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWaitView) name:N_DISMISS_INDICATOR object:nil];

}

- (void) dismissWaitView {
    if (_waitView) {
        [_waitView dismissWithClickedButtonIndex:[_waitView cancelButtonIndex] animated:YES];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_DISMISS_INDICATOR object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
