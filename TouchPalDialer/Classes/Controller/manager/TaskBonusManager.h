//
//  TaskBonusManager.h
//  TouchPalDialer
//
//  Created by game3108 on 15/2/10.
//
//

#import <Foundation/Foundation.h>
#import "TaskBonusResultInfo.h"

#define FLOW_CALL_ID 7
#define DAILY_ACTIVE 24
#define WEEKLY_ACTIVE 27
#define NEWER_GUIDE_ID 26
#define INTERNATIONAL_ROMAING 28
#define ERROR_HANGUP_PAY 49

@interface TaskBonusManager : NSObject
-(void)doTaskFunction:(NSInteger)taskBonusId;
-(void)getTaskBonus:(NSInteger)eventId withSuccessBlock: (void (^)(int bonus, TaskBonusResultInfo *))successBlock withFailedBlock: (void (^)(int resultCode,TaskBonusResultInfo *info))failedBlock localJudgeTodayFinish:(BOOL)judge;
@end
