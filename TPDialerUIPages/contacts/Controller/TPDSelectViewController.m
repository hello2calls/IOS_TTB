//
//  TPDSelectViewController.m
//  TouchPalDialer
//
//  Created by H L on 2016/11/30.
//
//

#import "TPDSelectViewController.h"
#import "TPDialerResourceManager.h"
#import "Person.h"
#import "CootekNotifications.h"
#import "ContactCacheDataManager.h"
#import "DefaultUIAlertViewHandler.h"
typedef void (^FinishBlock)(NSArray *);
typedef void (^CancelBlock)(void);

@interface TPDSelectViewController ()


@property (nonatomic, strong)UIAlertView *waitView;
@property (nonatomic, copy) FinishBlock finishBlock;
@property (nonatomic, copy) CancelBlock cancelBlock;


@end

@implementation TPDSelectViewController

- (instancetype)initWithFinishBlock:(void(^)(NSArray *dataList))finish CancelBlock:(void(^)(void))cancel {

    if ( self = [super init]) {
        self.type = 1;
        self.finishBlock = finish;
        self.cancelBlock = cancel;
        
    }
    
    return self;
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == 1) {
        self.commandName = NSLocalizedString(@"Choose a contact", @"");
    }else {
        self.commandName = NSLocalizedString(@"Delete contact",@"");
    }
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"defaultBackground_color"];
    if(self.dataList==nil){
        self.dataList = [Person queryAllContacts];
    }
    self.viewType = SelectViewGroupCommandAll;
    SelectView *temp_view=[[SelectView alloc] initWithPersonArrayAndViewTypeAndCommandName:self.dataList ViewType:self.viewType CommandName:self.commandName andIfSingle:_isChooseSingle];
    temp_view.select_view_delegate = self;
    self.select_view=temp_view;
    [self.view addSubview:temp_view];
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
    
    
}

-(void)willDismissSelf {
    [self popViewController];
}

- (void) dismissWaitView {
    if (_waitView) {
        [_waitView dismissWithClickedButtonIndex:[_waitView cancelButtonIndex] animated:YES];
    }
}


- (void)popViewController {
    
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {

    if (_waitView) {
        [_waitView removeFromSuperview];
        [_waitView dismissWithClickedButtonIndex:[_waitView cancelButtonIndex] animated:YES];
        
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - callback delegata
-(void)selectViewCancel{
    
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
    [self popViewController];
    
    
}

-(void)selectViewFinish:(NSArray *)select_list{
    
    
    if (self.finishBlock) {
        if (self.type != 0) {
            self.finishBlock([self getPersonNumbers:select_list]);
        }
    }

    
    if (self.type == 0) {
        //delete
        [self deleteContact:select_list];
        return;
    }
    
    
    [self popViewController];
    
}


-(void)selectItem:(SelectModel *)select_item{
    [self.delegate selectItem:select_item];
    [self popViewController];
}



#pragma mark - help method
- (NSArray *)getPersonNumbers:(NSArray *)personArray {
    NSMutableArray *dataNumber = [NSMutableArray new];
    if (personArray.count > 0 ) {
        for(int i = 0 ; i < personArray.count; i ++){
            ContactCacheDataModel * contact;
            contact = [ContactCacheDataManager instance].contactsCacheDict[@([personArray[i] integerValue])];
            NSString *number = [PhoneNumber getCNnormalNumber:((PhoneDataModel *)contact.phones[0]).number ];
            NSLog(@"%@ %d %@",contact.fullName, @([personArray[i] integerValue]),number);
            if (number.length > 0) {
                
                [dataNumber addObject:number];
            }
        }
    }
    return dataNumber;
}


- (void)deleteContact:(NSArray *)select_list {

    NSString *tittle = (select_list.count == 1) ? NSLocalizedString(@"Confirm to delete?",@"") : [NSString stringWithFormat:NSLocalizedString(@"Confirm to detele %d contacts?",@""), select_list.count];
    if (select_list.count > 0) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:tittle
                                                  message:nil
                                      okButtonActionBlock:^{[self confirmToDelete:select_list];   }
                                        cancelActionBlock:^{}];
    }
}

- (void) deletePersons:(NSArray *)select_list hasWaitView:(BOOL)needPopupWaitView{

    cootek_log(@"start delete contact");
    [Person deletePersonByRecordIDsArray:select_list];
    cootek_log(@"end delete contact");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                            object:nil
                                                          userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_DATA_CHANGED object:nil];
        
        if (needPopupWaitView) {
            [self dismissWaitView];
        }
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void) confirmToDelete:(NSArray *)select_list {

    BOOL needPopupWaitView = NO;
    if (select_list.count > 4) {
        needPopupWaitView = YES;
        [self showWaitView];                                          }
    if ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (NSInteger)(0.01*NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            [self deletePersons:select_list hasWaitView:needPopupWaitView];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self deletePersons:select_list hasWaitView:needPopupWaitView];
        });
    }

}
@end
