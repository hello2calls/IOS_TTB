//
//  ScheduleManager.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 11/21/12.
//
//

#import "ScheduleTaskManager.h"
#import "UserDefaultKeys.h"
#import "TPDialerResourceManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
#import "TPDialerResourceManager.h"
#import "NSKeyedUnarchiver+TPSafe.h"
#import "SeattleFeatureExecutor.h"
#import "UpdateService.h"
#import "FunctionUtility.h"
#import "GZipUtils.h"
#import "Reachability.h"
#import "QueryCallerid.h"
#import "DialerUsageRecord.h"

#define CODE_KEY_TASKKEY @"taskKey"
#define CODE_KEY_NEXTDATE @"nextDate"
#define CODE_KEY_TIMES    @"performedTimes"

@implementation ScheduleTask
@synthesize taskKey = taskKey_;
@synthesize nextDate = nextDate_;
@synthesize performedTimes = performedTimes_;

- (id)initWithTaskKey:(NSString *)taskKey{
    self = [super init];
    if(self){
        self.taskKey =taskKey;
        self.nextDate = [NSDate date];
        performedTimes_ = 0;
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.taskKey forKey:CODE_KEY_TASKKEY];
    [aCoder encodeObject:self.nextDate forKey:CODE_KEY_NEXTDATE];
    [aCoder encodeObject:@(self.performedTimes) forKey:CODE_KEY_TIMES];
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.taskKey = [aDecoder decodeObjectForKey:CODE_KEY_TASKKEY];
        self.nextDate = [aDecoder decodeObjectForKey:CODE_KEY_NEXTDATE];
        NSNumber *timesObject = [aDecoder decodeObjectForKey:CODE_KEY_TIMES];
        if(timesObject==nil){
            performedTimes_=0;
        }else{
            performedTimes_ = [timesObject intValue];
        }
    }
    
    return self;
}
- (double)taskInterval{
    return 24*60*60;
}

- (BOOL)performTask{
    NSDate *date = [NSDate date];
    if([date compare:nextDate_]>=0){
        BOOL success = [self performTaskProtected];
        if(success) {
            self.nextDate = [NSDate dateWithTimeInterval:self.taskInterval sinceDate:date];
            performedTimes_++;
            return YES;
        }
    }
    return NO;
}

-(BOOL)performTaskProtected {
    //Do nothing
    // override this method to do real task
    return YES;
    
}

@end


@implementation ScheduleTaskManager{
    NSMutableArray *scheduleTasks_;
}
static ScheduleTaskManager *taskManager;
- (id)initWithTaskArray:(NSArray *)taskArray{
    self = [super init];
    if(self){
        if(taskArray!=nil){
            NSMutableArray *originalTasks = [[NSMutableArray alloc] initWithCapacity:taskArray.count];
            for(id item in taskArray){
                if([item isKindOfClass:[NSData class]]){
                    id task = [NSKeyedUnarchiver safelyUnarchiveObjectWithData:item];
                    if (task) {
                        [originalTasks addObject:task];
                    }
                }else{
                    [originalTasks addObject:item];
                }
            }
            scheduleTasks_ = [[NSMutableArray alloc] initWithArray:originalTasks];
        }else{
            scheduleTasks_ = [[NSMutableArray alloc] initWithCapacity:5];
        }
    }
    return self;
}

+ (id)scheduleManager{
    if(taskManager!=nil){
        return taskManager;
    }else{
        @synchronized([ScheduleTaskManager class]){
            NSArray *orginalScheduleTasks = [UserDefaultsManager arrayForKey:SCHEDULE_TASKS];
            taskManager = [[ScheduleTaskManager alloc] initWithTaskArray:orginalScheduleTasks];
            return taskManager;
        }
    }
}

//adding sucees return yes
- (BOOL)addScheduleTask:(ScheduleTask *)task{
    @synchronized(self){
        BOOL alreadyIn = NO;
        for(ScheduleTask *item in scheduleTasks_){
            if([item.taskKey isEqualToString: task.taskKey]){
                alreadyIn = YES;
                break;
            }
        }
        if(!alreadyIn){
            [scheduleTasks_ addObject:task];
            [self persistant];
            return YES;
        }
        return NO;
    }
}

- (BOOL)removeScheduleTaskByTaskKey:(NSString *)taskKey{
    @synchronized(self){
        ScheduleTask *taskTobeRemoved = nil;
        for(ScheduleTask *task in scheduleTasks_){
            if([task.taskKey isEqualToString:taskKey]){
                taskTobeRemoved = task;
                break;
            }
        }
        if(taskTobeRemoved!=nil){
            [scheduleTasks_ removeObject:taskTobeRemoved];
            [self persistant];
            return YES;
        }
        return NO;
    }
}

- (void)beginScheduleTasks{
    @synchronized(self){
        BOOL hasChange = NO;
        for(ScheduleTask *task in scheduleTasks_){
            hasChange = [task performTask] || hasChange;
        }
        if(hasChange){
            [self persistant];
        }
    }
}

- (NSArray *)currentScheduleTasks{
    @synchronized(self){
       return [scheduleTasks_ copy];
    }
}

- (void)persistant{
   [UserDefaultsManager setObject:[NSArray arrayWithArray:scheduleTasks_] forKey:SCHEDULE_TASKS];
}
@end


@implementation UsageCheckScheduleTask

+ (id)task{
    return [[UsageCheckScheduleTask alloc] initWithTaskKey:SCHEDULE_TASK_USAGE];
}

- (double)taskInterval{
    return 24*60*60;
}

- (BOOL)performTaskProtected{
    
    [DialerUsageRecord recordpath:PATH_SKIN kvs:Pair(SKIN_USAGE, [TPDialerResourceManager sharedManager].skinTheme), nil];
    [DialerUsageRecord recordpath:PATH_PERSONAL_CENTER kvs:Pair(VOIP_OPEN, @([UserDefaultsManager boolValueForKey:IS_VOIP_ON])), nil];
    return YES;
}
@end

@implementation NewSkinDiscoverScheduleTask

+ (id)task{
    return [[NewSkinDiscoverScheduleTask alloc] initWithTaskKey:SCHEDULE_TASK_NEW_SKIN_DISCOVER];
}

- (double)taskInterval{
    return 3*24*60*60;
}

- (BOOL)performTaskProtected{

    return YES;
}

@end

@implementation UpdateZipScheduleTask

+ (id)task{
    return [[UpdateZipScheduleTask alloc] initWithTaskKey:SCHEDULE_TASK_UPDATE_ZIP];
}

- (double)taskInterval{
    return 0;
}

- (BOOL)performTaskProtected{
    
    [[UpdateService instance] run];
    return YES;
}

@end

@implementation ServerNumberCheckScheduleTask
#define SERVER_NUMBER_URL @"http://dialer.cdn.cootekservice.com/voip/inapp/travelnumber/and/travelnumber"
+ (id)task {
    return [[ServerNumberCheckScheduleTask alloc] initWithTaskKey:SCHEDULE_TASK_SERVER_NUMBER_CHECK];
}

- (double)taskInterval {
    return 24*60*60;
}

- (BOOL)performTaskProtected {
    if ([Reachability network] < network_3g) {
        return NO;
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        cootek_log(@"Trying to check server numbers config");
        NSData *serverConfigData = [FunctionUtility getRemoteData:SERVER_NUMBER_URL];
        if (serverConfigData != nil) {
            NSData *deflateData = [serverConfigData gzipInflate];
            if (deflateData) {
                NSString *stringData = [[NSString alloc] initWithData:deflateData encoding:NSUTF8StringEncoding];
                [UserDefaultsManager setObject:stringData forKey:SERVER_NUMBERS_FOR_FREE_CALL];
            }
        }
    });
    return YES;
}
@end


@implementation UploadCalllogScheduleTask
+ (id)task {
    return [[UploadCalllogScheduleTask alloc] initWithTaskKey:SCHEDULE_TASK_UPLOAD_CALLLOG];
}

- (double)taskInterval {
    return 60*60;
}

- (BOOL)performTaskProtected {
    if ([Reachability network] < network_2g) {
        return NO;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int count = [UserDefaultsManager intValueForKey:DATA_CURRENT_CALLLOG_COUNT defaultValue:QUERY_ALL_CALLLOG];
        if (count > 0) {
            [self uploadCurrentCalllog:count];
        } else if (count == QUERY_ALL_CALLLOG) {
            [self uploadAllCalllog];
        }
    });
    return YES;
}

- (void)uploadCurrentCalllog:(NSInteger)count{
    if ([SeattleFeatureExecutor uploadCallHistoryWithCount:count]) {
        [UserDefaultsManager setIntValue:0 forKey:DATA_CURRENT_CALLLOG_COUNT];
    }
}

- (void)uploadAllCalllog{
    if ([SeattleFeatureExecutor uploadCallHistoryWithCount:QUERY_ALL_CALLLOG]) {
        [UserDefaultsManager setIntValue:0 forKey:DATA_CURRENT_CALLLOG_COUNT];
    }
}

@end


@implementation UploadContactScheduleTask
+ (id)task {
    return [[UploadContactScheduleTask alloc] initWithTaskKey:SCHEDULE_TASK_UPLOAD_CONTACT];
}

- (double)taskInterval {
    return 24*60*60*7;
}

- (BOOL)performTaskProtected {
    if ([Reachability network] < network_2g) {
        return NO;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SeattleFeatureExecutor uploadContact];
    });
    return YES;
}
@end

@implementation CalleridUpdate

+ (id)task {
    return [[CalleridUpdate alloc]initWithTaskKey:SCHEDULE_TASK_CALLERID_UPDATE];
}

- (double)taskInterval {
    return 3600 * 24;
}

- (BOOL)performTaskProtected {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QueryCallerid shareInstance]checkUpdate];
    });
    return YES;
}

@end
