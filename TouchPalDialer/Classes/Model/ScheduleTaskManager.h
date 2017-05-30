//
//  ScheduleManager.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 11/21/12.
//
//

#import <Foundation/Foundation.h>
@interface ScheduleTask: NSObject <NSCoding>
@property(nonatomic,retain)NSString *taskKey;
@property(readonly)double taskInterval;
@property(nonatomic,retain)NSDate *nextDate;
@property(nonatomic,readonly)NSInteger performedTimes;
- (BOOL)performTask;
- (id)initWithTaskKey:(NSString *)taskKey;
@end

// task managed by this manager will be carried out when app will enter to background
// any task that may cost time, please start a new thread in your override method "performTaskProtected"
@interface ScheduleTaskManager : NSObject
+ (id)scheduleManager;
- (BOOL)addScheduleTask:(ScheduleTask *)task;
- (BOOL)removeScheduleTaskByTaskKey:(NSString *)taskKey;
- (void)beginScheduleTasks;
- (NSArray *)currentScheduleTasks;
@end


@interface UsageCheckScheduleTask : ScheduleTask
+ (id)task;
@end


@interface NewSkinDiscoverScheduleTask : ScheduleTask
+ (id)task;
@end

@interface UpdateZipScheduleTask : ScheduleTask
+ (id)task;
@end

@interface ServerNumberCheckScheduleTask : ScheduleTask
+ (id)task;
@end

@interface UploadCalllogScheduleTask : ScheduleTask
+ (id)task;
@end

@interface UploadContactScheduleTask : ScheduleTask
+ (id)task;
@end

@interface CalleridUpdate : ScheduleTask
+ (id)task;
@end