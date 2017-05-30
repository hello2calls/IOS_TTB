//
//  TaskBonusManager.m
//  TouchPalDialer
//
//  Created by game3108 on 15/2/10.
//
//

#import "TaskBonusManager.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultsManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "TouchPalDialerAppDelegate.h"
#import "RootScrollViewController.h"

#import "CheckboxAlertViewHandler.h"
#import "UIView+Toast.h"

@implementation TaskBonusManager

- (void)doTaskFunction:(NSInteger)taskBonusId{
    [self getTaskBonus:taskBonusId withSuccessBlock:^(int bonus, TaskBonusResultInfo *info) {
        NSString *strBonus = @"恭喜您获得奖励";
        NSString *bonusTitle = @"";
        NSInteger alertType = 0;
        if ( taskBonusId == NEWER_GUIDE_ID ){
            [UserDefaultsManager setBoolValue:YES forKey:NEWER_WIZARD_READ]; 
            strBonus = @"您已经学会打免费电话了吧\n送您50分钟通话时长！";
        }else if ( taskBonusId == DAILY_ACTIVE || taskBonusId == WEEKLY_ACTIVE){
            if (taskBonusId == DAILY_ACTIVE) {
                strBonus = [NSString stringWithFormat:@"获得%d分钟首次启动奖励",(bonus / 60)];
                bonusTitle = [NSString stringWithFormat:@"+%d分钟",(bonus / 60)];
                alertType = 1;
                if (bonus > 3000) {
                    strBonus = [NSString stringWithFormat:@"本月首次启动\n获得%d分钟通话时长",(bonus / 60)];
                    alertType = 0;
                }
            }
            if (taskBonusId == WEEKLY_ACTIVE) {
                strBonus = [NSString stringWithFormat:@"连续使用7天，送您%dM流量\n再坚持7天可获得更多免费流量！",bonus];
                if (bonus > 5) {
                    strBonus = [NSString stringWithFormat:@"感谢您连续使用触宝电话，送您%dM流量",bonus];
                } else if (bonus > 4) {
                    strBonus = [NSString stringWithFormat:@"坚持使用14天成就已达成\n送您%dM流量！",bonus];
                }
            }
            [UserDefaultsManager setObject:@"" forKey:APP_TASK_BONUS];
            UINavigationController *naviController = ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
            [naviController popToRootViewControllerAnimated:YES];
        }
        
        if ( alertType == 1 )
            if ( [UserDefaultsManager boolValueForKey:TASK_BONUS_DAILY_ALERT] )
                alertType = 2;
        
        if ( alertType == 0 )
            [DefaultUIAlertViewHandler showAlertViewWithTitle:strBonus message:nil okButtonActionBlock:nil];
        else if ( alertType == 1 )
            [CheckboxAlertViewHandler showAlertTitle:bonusTitle andKey:TASK_BONUS_DAILY_ALERT];
        else if ( alertType == 2 ){
            UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
            [uiWindow makeToast:strBonus duration:2.0f position:CSToastPositionUpKeyboard];
        }
    } withFailedBlock:^(int resultCode,TaskBonusResultInfo *info){
        if ( resultCode == 0 ){
            [DefaultUIAlertViewHandler showAlertViewWithTitle:@"任务失败，请检查网络" message:nil onlyOkButtonActionBlock:nil];
        }else{
            if ( !info.qulification ){
                [DefaultUIAlertViewHandler showAlertViewWithTitle:@"您还不能参加此任务哦！" message:nil onlyOkButtonActionBlock:nil];
            }else{
                if ( info.finish ){
                    [DefaultUIAlertViewHandler showAlertViewWithTitle:@"您已经领取过奖励，不能再领取咯！" message:nil onlyOkButtonActionBlock:nil];
                }else{
                    if ( info.todayFinish ){
                        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"今天的任务已经完成，请明天再来哦！" message:nil onlyOkButtonActionBlock:nil];
                    }
                }
            }
            if ( taskBonusId == NEWER_GUIDE_ID ){
                [UserDefaultsManager setBoolValue:YES forKey:NEWER_WIZARD_READ];
            }else if ( taskBonusId == DAILY_ACTIVE || taskBonusId == WEEKLY_ACTIVE ){
                UINavigationController *naviController = ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
                [naviController popToRootViewControllerAnimated:YES];
            }
        }
        
    } localJudgeTodayFinish:NO];
}

-(void)getTaskBonus:(NSInteger)eventId withSuccessBlock: (void (^)(int bonus, TaskBonusResultInfo *))successBlock withFailedBlock:(void (^)(int resultCode,TaskBonusResultInfo *info))failedBlock localJudgeTodayFinish:(BOOL)judge{
//    if ( [UserDefaultsManager boolValueForKey:[NSString stringWithFormat:@"%@%d",TASK_BONUS_ID_,eventId] defaultValue:NO] ){
//        return;
//    }
    if ( !([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN])){
        if (failedBlock) {
            failedBlock(-1, nil);
        }
        return;
    }
    
    if ( ![UserDefaultsManager boolValueForKey:IS_VOIP_ON] && (eventId == DAILY_ACTIVE || eventId == WEEKLY_ACTIVE) ){
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"您关闭了免费电话，无法签到。" message:nil onlyOkButtonActionBlock:nil];
        return;
    }
    
    if (judge){
        if ( ![self judgeTimeAfterOneDay:eventId] ){
            if (failedBlock) {
                failedBlock(-1, nil);
            }
            return;
        }
    }
    
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [SeattleFeatureExecutor getTaskBonus:eventId withSuccessBlock: successBlock withFailedBlock:failedBlock];
    });
}

- (BOOL)judgeTimeAfterOneDay:(NSInteger)eventId{
    
    NSInteger eventLastTime = [UserDefaultsManager intValueForKey:[NSString stringWithFormat:@"%@%d",TASK_BONUS_TIME_,eventId]];
    NSDate *eventLastDate = [NSDate dateWithTimeIntervalSince1970:eventLastTime];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *eventLastCom = [calendar components:unitFlags fromDate:eventLastDate];
    NSDateComponents *today = [calendar components:unitFlags fromDate:[NSDate date]];

    if ( today.year > eventLastCom.year ){
        return YES;
    }else if ( today.year < eventLastCom.year ){
        return NO;
    }else{
        if ( today.month > eventLastCom.month ){
            return YES;
        }else if ( today.month < eventLastCom.month ){
            return NO;
        }else{
            if ( today.day > eventLastCom.day ){
                return YES;
            }else{
                return NO;
            }
        }

    }
    
    return NO;
}

@end
