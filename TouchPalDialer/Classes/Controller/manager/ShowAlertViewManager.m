//
//  ShowAlertViewManager.m
//  TouchPalDialer
//
//  Created by game3108 on 15/2/4.
//
//

#import "ShowAlertViewManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
#import "UserStreamViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "SeattleFeatureExecutor.h"
#import "EditVoipViewController.h"
#import "TPDialerResourceManager.h"
#import "FlowEditViewController.h"

@interface ShowAlertViewManager(){
    NSMutableArray __strong *list;
    NSMutableDictionary __strong *dic;
}

@end


static ShowAlertViewManager *instance = nil;

@implementation ShowAlertViewManager

+ (void)initialize{
    instance = [[ShowAlertViewManager alloc]init];
}

- (instancetype)init{
    self = [super init];
    if ( self ){
        list = [NSMutableArray array];
        dic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[UserDefaultsManager objectForKey:VOIP_SHOW_ALERT_DIC defaultValue:nil]];
        if ( [dic count] > 0 ){
            for ( NSNumber *num in dic ){
                NSString *title = [dic objectForKey:num];
                ShowAlertViewInfo *info = [[ShowAlertViewInfo alloc]init];
                info.alertTitle = title;
                info.alertType = [num integerValue];
                [list addObject:info];
            }
        } else {
            [UserDefaultsManager setObject:dic forKey:VOIP_SHOW_ALERT_DIC];
        }
    }
    
    return self;
}

+(instancetype)instance{
    return instance;
}

- (void)addInfo:(ShowAlertViewInfo*)info{
    if ( info != nil ){
        [self removeInfoByType:info.alertType];
        [list addObject:info];
        [dic setObject:info.alertTitle forKey:[NSNumber numberWithInt:info.alertType]];
        [UserDefaultsManager setObject:dic forKey:VOIP_SHOW_ALERT_DIC];
    }
}

- (void)showAlertView:(NSInteger)alertType{
    if ( [list count] == 0 )
        return;
    BOOL hasAlert = NO;
    NSString *alertTitle = nil;
    for ( ShowAlertViewInfo *info in list ){
        if ( info.alertType == alertType ){
            hasAlert = YES;
            alertTitle = info.alertTitle;
            break;
        }
    }
    if ( hasAlert ){
        [DefaultUIAlertViewHandler showAlertViewWithTitle:alertTitle message:nil cancelTitle:nil okTitle:NSLocalizedString(@"show_alert_i_know", "") okButtonActionBlock:nil];
        [self removeInfoByType:alertType];
    }
}

- (void)checkAlertView{
    if ( [list count] == 0 )
        return;
    BOOL hasAlert = NO;
    NSString *alertTitle = nil;
    NSInteger alertType = 0;
    for ( ShowAlertViewInfo *info in list ){
        hasAlert = YES;
        alertTitle = info.alertTitle;
        alertType = info.alertType;
        if ( alertType == FLOW_INFO_TYPE )
            break;
    }
    __weak UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    if ( hasAlert ){
        if ( alertType == VOIP_INFO_TYPE ){
            if ( [navi.topViewController isKindOfClass: [EditVoipViewController class]] ){
                [DefaultUIAlertViewHandler showAlertViewWithTitle:alertTitle message:nil cancelTitle:nil okTitle:NSLocalizedString(@"show_alert_i_know", "") okButtonActionBlock:nil];
            }else{
                [DefaultUIAlertViewHandler showAlertViewWithTitle:alertTitle message:nil cancelTitle:NSLocalizedString(@"show_alert_i_know", "") okTitle:NSLocalizedString(@"show_alert_see_detail", "") okButtonActionBlock:^(){
                    EditVoipViewController *con = [[EditVoipViewController alloc]init];
                    [navi pushViewController:con animated:YES];
                }];
            }
        }else if ( alertType == FLOW_INFO_TYPE ){
            if ( [navi.topViewController isKindOfClass: [FlowEditViewController class]] ){
                [DefaultUIAlertViewHandler showAlertViewWithTitle:alertTitle message:nil cancelTitle:nil okTitle:NSLocalizedString(@"show_alert_i_know", "") okButtonActionBlock:nil];
            }else{
                [DefaultUIAlertViewHandler showAlertViewWithTitle:alertTitle message:nil cancelTitle:NSLocalizedString(@"show_alert_i_know", "") okTitle:NSLocalizedString(@"show_alert_see_detail", "") okButtonActionBlock:^(){
                    FlowEditViewController *con = [[FlowEditViewController alloc]init];
                    [navi pushViewController:con animated:YES];
                }];
            }
        }
        [self removeInfoByType:alertType];
    }
}

- (void)removeInfoByType:(NSInteger)alertType{
    if ( [list count] == 0 )
        return;
    ShowAlertViewInfo *target = nil;
    for ( ShowAlertViewInfo *info in list ){
        if ( info.alertType == alertType ){
            target = info;
            break;
        }
    }
    if (target) {
        [list removeObject:target];
    }
    
    [dic removeObjectForKey:[NSNumber numberWithInt:alertType]];
    [UserDefaultsManager setObject:dic forKey:VOIP_SHOW_ALERT_DIC];
}


@end
