//
//  TouchPalDialerTest.m
//  TouchPalDialerTest
//
//  Created by Elfe Xu on 12-11-8.
//
//

#import "TouchPalDialerTest.h"
#import "BasicUtil.h"
#import "UserDefaultsManager.h"
#import "ScheduleTaskManager.h"
#import "DataBaseModel.h"
#import "CallLogDBA.h"
#import "CallLogDataModel.h"
#import "FunctionUtility.h"
#import "SeattleFeatureExecutor.h"
#import "DataBaseModel.h"
#import "PublicNumberProvider.h"
#import "PublicNumberMessage.h"
#import "PublicNumberModel.h"
#import "QueryCallerid.h"

@implementation TouchPalDialerTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

//- (void)testExample
//{
//    STFail(@"Unit tests are not implemented yet in TouchPalDialerTest");
//}
//
//-(void) testBasicUtil_ObjectEqualTo
//{
//    //Arrange
//    NSObject* obj1 = @"abc";
//    NSObject* obj2 = @"abc";
//    
//    //Assert
//    STAssertTrue([BasicUtil object:obj1 equalTo:obj2], @"objects should be equal.");
//}
//
//-(void)testDatabaseScripts {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentDirectory = [paths objectAtIndex:0];
//	NSString *filepath = [documentDirectory stringByAppendingPathComponent:@"testDatabaseScripts.sqlite"];
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    if([fileManager fileExistsAtPath:filepath]) {
//        [fileManager removeItemAtPath:filepath error:nil];
//    }
//    
//    sqlite3* db;
//    int openResult = sqlite3_open([filepath UTF8String], &db);
//	if (SQLITE_OK != openResult) {
//        sqlite3_close(db);
//        STFail(@"failed to create database for path %@", filepath);
//	}
//    
//    BOOL result =[DataBaseModel executeScriptOnDatabase:db ForOriginalVersion:-1];
//    STAssertTrue(result, @"execute db script failed");
//    
//    sqlite3_close(db);
//    [fileManager removeItemAtPath:filepath error:nil];
//}
//
//- (void)testAddManyCallLogs{
//    for(int i=0;i<2013;i++){
//        NSString *number = [NSString stringWithFormat:@"%d",i+20000];
//        CallLogDataModel *callLog = [[CallLogDataModel alloc] initWithPersonId:-1 phoneNumber:number callType:CallLogIncomingType duration:i loadExtraInfo:NO];
//        //[CallLogDBA insertCallLog:callLog];
//    }
//}
//
//- (void)testEncodeAndDecode {
//    NSString *test = @"b2015b20-959e-4ca2-adb7-2ef0d639c782";
//    NSString *encode = [FunctionUtility simpleEncodeForString:test];
//    NSString *decode = [FunctionUtility simpleDecodeForString:encode];
//}
//
//- (void)testAdCommercial {
//    NSString *number = @"+8613918745210";
//    [SeattleFeatureExecutor getHangupAdInfoWithOtherNumber:number];
//}
//
//- (void)testPublicNumberTables {
//    NSString *sql = @"select * from public_number_info";
//    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
//        sqlite3_stmt *stmt;
//        
//        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
//        if (result == SQLITE_OK) {
//            NSLog(@"success");
//        } else {
//            NSLog(@"fail");
//        }
//        sqlite3_finalize(stmt);
//    }];
//    
//    sql = @"select * from public_number_message";
//    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
//        sqlite3_stmt *stmt;
//        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
//        if (result == SQLITE_OK) {
//            NSLog(@"success");
//        } else {
//            NSLog(@"fail");
//        }
//        sqlite3_finalize(stmt);
//    }];
//}
//
//- (void)testPublicNumberProviders {
//    PublicNumberModel *model1 = [[PublicNumberModel alloc] initWithPhone:@"+8615079017120" sendId:@"send1" name:@"send1" data:@"data1" menus:@"" errorUrl:@"" icon:@"icon12" logo:@"logo12" compName:@"comp1" desc:@"desc1" andAvailible:1];
//    model1.logoPath = @"logoPath1";
//    model1.iconPath = @"iconPath1";
//    
//    PublicNumberModel *model2 = [[PublicNumberModel alloc] initWithPhone:@"+8615079017120" sendId:@"send2" name:@"send2" data:@"data2" menus:@"" errorUrl:@"" icon:@"icon2" logo:@"logo2" compName:@"comp2" desc:@"desc2" andAvailible:1];
//    BOOL success = [PublicNumberProvider addPublicNumberInfos:@[model1, model2]];
//    STAssertTrue(success, @"data insert failed");
//    
//    success = [PublicNumberProvider updatePublicInfoWithSendId:@"send2" newCount:10 content:@"newContent" andCreateTime:100];
//    STAssertTrue(success, @"");
//    
//    success = [PublicNumberProvider clearNewCountForServiceId:@"send2"];
//    STAssertTrue(success, @"");
//    
//    //    select
//    NSMutableArray *array = [NSMutableArray array];
//    success = [PublicNumberProvider getPublicNumberInfos:array];
//    STAssertTrue(success, @"data select fail");
//    NSLog(@"test:%d", array.count);
//    STAssertTrue(array.count == 2, @"data select fail");
//    
//    NSMutableArray *arrayLinks = [[NSMutableArray alloc] init];
//    success = [PublicNumberProvider getNeedDownloadLinks:arrayLinks];
//    STAssertTrue(success, @"data select fail");
//    STAssertTrue(arrayLinks.count > 0, @"data select fail");
//    
//    NSDictionary *linkDic = [[NSMutableDictionary alloc]init];
//    for (NSString *link in arrayLinks) {
//        [linkDic setValue:[NSString stringWithFormat:@"%@ : value", link] forKey:link];
//    }
//    
//    success = [PublicNumberProvider saveDownloadLinks:linkDic];
//    STAssertTrue(success, @"data select fail");
//    
//    
//    arrayLinks = [[NSMutableArray alloc] init];
//    success = [PublicNumberProvider getNeedDownloadLinks:arrayLinks];
//    STAssertTrue(arrayLinks.count == 0, @"data select fail");
//
//    array = [[NSMutableArray alloc] init];
//    PublicNumberMessage *msg = [[PublicNumberMessage alloc] initWithMsgId:@"msg1" userPhone:@"f8a74d11-6736-4632-aad2-dc46b364713d" type:@"type" notifyType:@"notifyType" description:@"description1" notification:@"{notification:notification1}" remark:@"{remark:remark1}" keynotes:@"{keynote:keynote1}" sendId:@"send1" createTime:[NSNumber numberWithInt:12] status:1 source:@"" url:@"url"];
//    [array addObject:msg];
//    msg = [[PublicNumberMessage alloc] initWithMsgId:@"msg2" userPhone:@"f8a74d11-6736-4632-aad2-dc46b364713d" type:@"type" notifyType:@"notifyType" description:@"description2" notification:@"{notification:notification2}" remark:@"{remark:remark2}" keynotes:@"{keynote:keynote2}" sendId:@"send1" createTime:[NSNumber numberWithInt:13] status:1 source:@"" url:@"url2"];
//    [array addObject:msg];
//    
//    msg = [[PublicNumberMessage alloc] initWithMsgId:@"msg3" userPhone:@"f8a74d11-6736-4632-aad2-dc46b364713d" type:@"type" notifyType:@"notifyType" description:@"description3" notification:@"{notification:notification3}" remark:@"{remark:remark3}" keynotes:@"{keynote:keynote3}" sendId:@"send2" createTime:[NSNumber numberWithInt:13] status:1 source:@"" url:@"url3"];
//    [array addObject:msg];
//    
//    msg = [[PublicNumberMessage alloc] initWithMsgId:@"msg4" userPhone:@"f8a74d11-6736-4632-aad2-dc46b364713d" type:@"type" notifyType:@"notifyType" description:@"description4" notification:@"{notification:notification4}" remark:@"{remark:remark4}" keynotes:@"{keynote:keynote4}" sendId:@"send2" createTime:[NSNumber numberWithInt:14] status:1 source:@"" url:@"url4"];
//    [array addObject:msg];
//    
//    success = [PublicNumberProvider addPublicNumberMsgs:array];
//    STAssertTrue(success, @"");
//    
//    NSMutableArray *msgs = [NSMutableArray array];
//    success = [PublicNumberProvider getPublicNumberMsgs:msgs withSendId:@"send1" count:3 fromMsgId:nil];
//    STAssertTrue(msgs.count == 2, @"");
//    
//    msgs = [NSMutableArray array];
//    success = [PublicNumberProvider getPublicNumberMsgs:msgs withSendId:@"send1" count:3 fromMsgId:@"msg2"];
//    STAssertTrue(msgs.count == 1, @"");
//
//    
//}
//
//
//- (void) testJsonString {
//    NSString* jsonString = @"{ color = \"#173177\";value = \"\\U60a8\\U7684\\U5546\\U54c1\\U5df2\\U4e0b\\U5355\\U5b8c\\U6210\\Uff0c\\U6211\\U4eec\\U5c06\\U9a6c\\U4e0a\\U5b89\\U6392\\U914d\\U9001\\U3002\";}";
//    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//    NSString* color = [json objectForKey:@"color"];
//}

@end
