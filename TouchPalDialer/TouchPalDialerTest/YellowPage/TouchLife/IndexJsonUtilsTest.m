//
//  TouchPalDialerTest.m
//  TouchPalDialerTest
//
//  Created by Elfe Xu on 12-11-8.
//
//

#import "IndexJsonUtilsTest.h"
#import "BasicUtil.h"
#import "UserDefaultsManager.h"
#import "ScheduleTaskManager.h"
#import "CallLogDBA.h"
#import "CallLogDataModel.h"
#import "FunctionUtility.h"
#import "SeattleFeatureExecutor.h"
#import "IndexJsonUtils.h"
#import "IndexConstant.h"

@implementation IndexJsonUtilsTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    NSString *last_modified_local = [UserDefaultsManager stringForKey:@"Last-Modified"];
    if (last_modified_local != nil) {
        [UserDefaultsManager setObject:nil forKey:@"Last-Modified"];
    }
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)test_saveJsonToFile
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [IndexJsonUtils saveJsonToFile:[NSString stringWithFormat:@"%@", INDEX_JSON_FILE]];
        NSString *last_modified_local = [UserDefaultsManager stringForKey:@"Last-Modified"];
        XCTAssertNotNil(last_modified_local, @"last_modified_local should not be nil.");
    });
}

@end
