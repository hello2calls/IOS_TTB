//
//  UsageProcessor.m
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-23.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import "UsageProcessor.h"
#import "UsageInfoProvider.h"
#include <stdlib.h>
#define MOBISEND (@"mobile")
#define WIFISEND (@"wifi")
#define EXTRASEND (@"extra")
#define MINTOSEC (60*1000)
#define MULTIPLE (1.1)
#define USAGE_TYPE (@"noah_usage_inner")
#define PATH_DELETE_USAGE (@"path_noah_usage_delete")

static dispatch_queue_t saveandsend_queue;
static Boolean ifOnlyWifi;
static NSMutableArray *arrayList;

NSString * const SUFFIX_APPEND = @"_____";
int const PART_LIMIT = 2000;

@interface UsageProcessor()
@property (nonatomic, strong) UsageInfoProvider *infoProvider;
@end

@implementation UsageProcessor

- (id)init {
    self = [super init];
    if (self) {
        if (saveandsend_queue == nil) {
            saveandsend_queue = dispatch_queue_create("save", NULL);
#ifdef DEBUG
            NSLog(@"saveandsend_queue created");
#endif
        }
        self.infoProvider = [[UsageInfoProvider alloc] init];
    }
    return self;
}

- (void)saveRecord:(UsageRecord *)record {
    dispatch_async(saveandsend_queue, ^(void){
        NSString *strategyName; //当前record对应的策略名。
        int sampling;           //当前record对应的采样率。
        
        //如果path有对应的strategy，则获取策略名和取样率，否则使用default策略并且100%取样。
        if ([[UsageStrategyController getCurrent] isPathExist:record.path]) {
            strategyName = [[UsageStrategyController getCurrent] getStrategy:record.path];
            sampling = [[UsageStrategyController getCurrent] getSampling:record.path];
        } else {
            strategyName = @"default";
            sampling = 100;
        }
        NSMutableArray *array = [NSMutableArray arrayWithArray:[[UsageSettings getInst] getRecords:strategyName]];
        if (array == nil) {
            array = [[NSMutableArray alloc] init];
        }
        int count = [[UsageStrategyController getCurrent] getCount:strategyName];
        if (count > 0 && count*MULTIPLE <= [array count]) {
            NSUInteger deleteNum = [array count] - count;
            [array removeObjectsInRange:NSMakeRange(0, deleteNum)];
            [[UsageSettings getInst] setRecords:array strategyName:strategyName];
            NSDictionary *deleteDict = [[NSDictionary alloc] initWithObjectsAndKeys:strategyName,@"strategy",[NSNumber numberWithInt:count],@"count",[NSNumber numberWithUnsignedInteger:deleteNum],@"delete_count", nil];
            [UsageRecorder record:USAGE_TYPE path:PATH_DELETE_USAGE values:deleteDict];
        }
        int p = arc4random() % 100;
        if (p < sampling) {
            NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:record];
            [array addObject:newData];
            [[UsageSettings getInst] setRecords:array strategyName:strategyName];
            #ifdef DEBUG
            //NSArray *recordArray = [[UsageSettings getInst] getRecords:strategyName];
            UsageRecord *lastRecord = [NSKeyedUnarchiver unarchiveObjectWithData:[array lastObject]];
            NSLog(@"$$$$$$--New Record--$$$$$$");
            NSLog(@"Type   : %@", lastRecord.type);
            NSLog(@"Path   : %@", lastRecord.path);
            NSLog(@"Value  : %@", lastRecord.values);
            #endif
        }
    });
}

- (void)sendData {
    dispatch_async(saveandsend_queue, ^(void) {
        //key:策略名，value:策略名，wifi上传间隔，mobi上传间隔。
        NSMutableDictionary *strategyDict = [[UsageStrategyController getCurrent] mUploadStrategy];
        NSMutableArray *strategyOfWifi = [[NSMutableArray alloc] init];
        NSMutableArray *strategyOfMobile = [[NSMutableArray alloc] init];
        //to save the name of strategy that are ready to send.
        
        for (int i = 0; i < 2; i ++) {
            BOOL encrypt = (i == 0);
            Boolean wifi = false;
            Boolean mobile = false;
            Strategy *stra;
            for (NSString *strategyName in strategyDict) {
                stra = [strategyDict valueForKey:strategyName];
                if (stra.encrypt != encrypt) {
                    continue;
                }
                NSMutableArray *array = [[UsageSettings getInst] getRecords:strategyName];
                double quietTime = [[UsageSettings getInst] getQuietTime:strategyName];
#ifdef DEBUG
                NSLog(@"------Judge the interval time------");
                NSLog(@"QuietTime : %lf", quietTime);
                NSLog(@"wifi      : %d", stra.wifi*MINTOSEC);
                NSLog(@"Mobi      : %d", stra.mobile*MINTOSEC);
#endif
                if (stra.mobile >= 0 && quietTime > stra.mobile*MINTOSEC
                    && [UsageNetworkUtil netStatus] == MOBILE_STATUS && [array count]!=0) {
                    //当前strategy对应的所有已保存的records。
                    NSMutableArray *newStrategy = [[UsageSettings getInst] getRecords:strategyName];
                    //在mobi网络环境下的已保存的records。
                    NSMutableArray *mobileArray = [[[UsageSettings getInst] getRecords:MOBISEND] mutableCopy];
                    //将当前strategy加入队列。
                    [strategyOfMobile addObject:strategyName];
                    //将符合条件的records追加在mobileArray后面。
                    if (mobileArray == nil) {
                        mobileArray = newStrategy;
                    } else {
                        [mobileArray addObjectsFromArray:newStrategy];
                    }
                    //将修改后的mobileArray重写入，并且删除已经添加进mobileArray的strategy的所有records。
                    [[UsageSettings getInst] setRecords:mobileArray strategyName:MOBISEND];
                    [[UsageSettings getInst] removeRecords:strategyName];
                    mobile = true;
                } else if (stra.wifi >= 0 && quietTime > stra.wifi*MINTOSEC
                           && [UsageNetworkUtil netStatus] == WIFI_STATUS && [array count] != 0) {
                    NSMutableArray *newStrategy = [[UsageSettings getInst] getRecords:strategyName];
                    NSMutableArray *wifiArray = [[[UsageSettings getInst] getRecords:WIFISEND] mutableCopy];
                    [strategyOfWifi addObject:strategyName];
                    if (wifiArray == nil) {
                        wifiArray = newStrategy;
                    } else {
                        [wifiArray addObjectsFromArray:newStrategy];
                    }
                    [[UsageSettings getInst] setRecords:wifiArray strategyName:WIFISEND];
                    [[UsageSettings getInst] removeRecords:strategyName];
                    wifi = true;
                }
            }
            
            //在wifi下，同时上传mobi的策略。
            if (wifi) {
                NSMutableArray *newarray = [[NSMutableArray alloc] init];
                [newarray addObjectsFromArray:strategyOfWifi];
                [newarray addObjectsFromArray:strategyOfMobile];
                [self generateAndSend:YES strategyNames:newarray useEncrypt:encrypt];
            } else if (mobile) {
                [self generateAndSend:NO strategyNames:strategyOfMobile useEncrypt:encrypt];
            }

        }
        
    });
}

- (void)sendInfoData {
    dispatch_async(saveandsend_queue, ^(void) {
        if ([UsageNetworkUtil netStatus] != WIFI_STATUS) {
            return;
        }
        NSMutableArray *usage = [[NSMutableArray alloc] init];
        __block NSMutableArray *list = [[NSMutableArray alloc] init];
        NSString *infoType = [self.infoProvider getType];
        double now = [[UsageSettings getInst] getCurrentTime];
        for (int i = 0; i < [self.infoProvider getLength]; i ++) {
            NSString *infoPath = [self.infoProvider getPath:i];
            double interval = [[UsageRecorder sAssist] getInfoInterval:i] * 60 * 60 * 24 * 1000;
            double last = [[UsageSettings getInst] getLastInfoSuccess:infoPath];
            if (interval < 0 || last + interval > now) {
                continue;
            }
            
            if (![[UsageRecorder sAssist] canUploadInfo:i]) {
                continue;
            }
            
            UsageInfoData *infoData = [self.infoProvider getData:i];
            if ([infoData hasData]) {
                UsageRecord *record = infoData.data;
                if (record == nil || record.type == nil || record.path == nil) {
                    continue;
                }
                NSArray *infoArray = [record.values objectForKey:NoahInfoSpecificKey];
                NSData *tmpData = [NSJSONSerialization dataWithJSONObject:infoArray options:0 error:nil];;
                NSString *valueOfString = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:record.path, @"path", valueOfString, @"value",nil];
                [usage addObject:dict];
                [list addObject:infoData];
            }
        }
        if ([usage count] > 0) {
            UsageNetProcessor *np = [[UsageNetProcessor alloc] initWithUsages:usage type:infoType andUseEncrypt:YES];
            [np sendWithBlock:^(NSMutableArray *saveArray, BOOL res, NSString *type) {
                if (res) {
                    for (UsageInfoData *infoData in list) {
                        [[UsageSettings getInst] setLastInfoSuccess:infoData.infoPath andTime:[[UsageSettings getInst] getCurrentTime]];
                        [[UsageSettings getInst] setLastInfoSuccessId:infoData.infoPath andId:infoData.lastId];
                    }
                }
            }];
        }
    });
}

- (void)generateAndSend:(BOOL)onlyWifi
          strategyNames:(NSMutableArray *)array
             useEncrypt:(BOOL)encrypt {
    ifOnlyWifi = onlyWifi;
    arrayList = array;
    NSMutableArray  *strategyArray = [[NSMutableArray alloc] init];  //Contains all strategys that are ready to send.
    [strategyArray addObjectsFromArray:[[UsageSettings getInst] getRecords:MOBISEND]];
    if (onlyWifi) {
        [strategyArray addObjectsFromArray:[[UsageSettings getInst] getRecords:WIFISEND]];
    }
    
    //保存所有数据段key对应的数据段。
    NSMutableDictionary *allDict = [[NSMutableDictionary alloc] init];
    //保存所有上传数据段的名字。why:数据过大使用分段上传，所以每个段都有一个key。
    NSMutableSet *allParts = [[NSMutableSet alloc] init];
    //保存对应的type当前数据段的数量。
    NSMutableDictionary *typeSuffix = [[NSMutableDictionary alloc] init];
    for (NSData *data in strategyArray) {
        UsageRecord *record = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (record == nil || record.type == nil || record.path == nil) {
            continue;
        }
        NSString *realType = record.type;
        NSString *type = realType;
        if (![allParts containsObject:type]) {
            [typeSuffix setObject:[NSNumber numberWithInt:0] forKey:type];
        } else if ([(NSNumber *)[typeSuffix objectForKey:type] intValue] != 0){
            type = [type stringByAppendingFormat:@"%@%@",SUFFIX_APPEND,[typeSuffix objectForKey:type]];
        }
        [allParts addObject:type];
        NSMutableArray *nowArray = [allDict objectForKey:type];
        if (nowArray == nil) {
            nowArray = [[NSMutableArray alloc] init];
        }
        NSData *dataOfDict = [NSJSONSerialization dataWithJSONObject:record.values options:0 error:nil];
        NSString *valueOfString = [[NSString alloc] initWithData:dataOfDict encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [[NSDictionary alloc]
                              initWithObjectsAndKeys:record.path, @"path", valueOfString, @"value",nil];
        [nowArray addObject:dict];
        [allDict setObject:nowArray forKey:type];
        if ([nowArray count] == PART_LIMIT) {
            int p = [(NSNumber *)[typeSuffix objectForKey:realType] intValue] + 1;
            [typeSuffix setObject:[NSNumber numberWithInt:p] forKey:realType];
        }
    }
    //将EXTRA中上传失败的内容加入上传，只在有新数据时加入，否则会出现在没有网络环境下尝试上传。
    NSArray *extraArray = [[UsageSettings getInst] getRecords:EXTRASEND];
    for (NSDictionary *dict in extraArray) {
        NSString *realType = [dict valueForKey:@"type"];
        NSString *type = realType;
        if (![allParts containsObject:type]) {
            [typeSuffix setObject:[NSNumber numberWithInt:0] forKey:type];
        } else if ([(NSNumber *)[typeSuffix objectForKey:type] intValue] != 0){
            type = [type stringByAppendingFormat:@"%@%@",SUFFIX_APPEND,[typeSuffix objectForKey:type]];
        }
        [allParts addObject:type];
        NSMutableArray *nowArray = [allDict objectForKey:type];
        if (nowArray == nil) {
            nowArray = [[NSMutableArray alloc] init];
        }
        NSDictionary *newDict = [[NSDictionary alloc]
                                 initWithObjectsAndKeys:[dict valueForKey:@"path"], @"path",
                                 [dict valueForKey:@"value"], @"value",nil];
        [nowArray addObject:newDict];
        [allDict setObject:nowArray forKey:type];
        if ([nowArray count] == PART_LIMIT) {
            int p = [(NSNumber *)[typeSuffix objectForKey:realType] intValue] + 1;
            [typeSuffix setObject:[NSNumber numberWithInt:p] forKey:realType];
        }
    }
    [[UsageSettings getInst] removeRecords:EXTRASEND];
    //删除SEND文件
    //why:上传之前将SEND文件读取并且分段，上传成功则不管，上传失败则把该段重写入WIFISEND，所以此时删除SEND文件。
    if (ifOnlyWifi) {
        [[UsageSettings getInst] removeRecords:MOBISEND];
        [[UsageSettings getInst] removeRecords:WIFISEND];
    } else {
        [[UsageSettings getInst] removeRecords:MOBISEND];
    }
    
    //分段上传
    for (NSString *part in allParts) {
        NSRange pOfSeparator = [part rangeOfString:SUFFIX_APPEND options:NSBackwardsSearch];
        NSString *realType;
        if (pOfSeparator.location == -1 || pOfSeparator.length == 0) {
            realType = part;
        } else {
            realType = [part substringToIndex:pOfSeparator.location];
        }
        UsageNetProcessor *np = [[UsageNetProcessor alloc] initWithUsages:[[allDict objectForKey:part] mutableCopy]type:realType andUseEncrypt:encrypt];
        [np sendWithBlock:^(NSMutableArray *saveArray, BOOL res, NSString *type) {
            NSMutableArray *array;
            if (res == NO) {
                array = [[[UsageSettings getInst] getRecords:EXTRASEND] mutableCopy];
                if (array == nil) {
                    array = [[NSMutableArray alloc] init];
                }
                
                //将上传失败的数据打入type
                NSMutableArray *newArray = [[NSMutableArray alloc] init];
                for (NSDictionary* dict in saveArray) {
                    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                    [newDict setValue:type forKey:@"type"];
                    [newArray addObject:newDict];
                }
                
                [array addObjectsFromArray:newArray];
                
                [[UsageSettings getInst] setRecords:array strategyName:EXTRASEND];
#ifdef DEBUG
                NSLog(@"Send failed. And save to EXTRASEND");
#endif
            } else {
#ifdef DEBUG
                NSLog(@"Send succeed.");
#endif
            }
            
            for (NSString *strategyName in arrayList) {
                [[UsageSettings getInst] updateLastSuccess:strategyName];
            }
#ifdef DEBUG
            NSLog(@"Update last succeed time.");
#endif

        }];
    }
}

- (void)updateStrategy:(NSString *)newFilePath {
    //1.备份原来的策略文件；
    //2.解析新的策略文件；
    //3.如果解析失败，则还原策略文件，重新解析。
    dispatch_sync(saveandsend_queue, ^(void) {
        //获取原来的策略文件的内容
        NSString *oldFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[[UsageRecorder sAssist] strategyFileName]];
        NSData *dataOfOldFile = [[NSFileHandle fileHandleForReadingAtPath:oldFilePath] readDataToEndOfFile];
        //生成备份文件路径
        NSString *backupFilePath = [[[UsageRecorder sAssist] storagePath]
                                    stringByAppendingPathComponent:
                                    [[[UsageRecorder sAssist] strategyFileName] stringByAppendingString:@".bak"]];
        //创建备份文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:backupFilePath contents:dataOfOldFile attributes:nil];
        //用新的策略文件覆盖原来的策略文件
        NSData *dataOfNewFile = [[NSFileHandle fileHandleForReadingAtPath:newFilePath] readDataToEndOfFile];
        [fileManager createFileAtPath:oldFilePath contents:dataOfNewFile attributes:nil];
        //更新策略文件
        BOOL result = [[UsageStrategyController getCurrent] generate];
        //如果新的策略文件有误，则还原备份文件，然后重新解析。之后回调告知App策略文件错误。
        if (!result) {
            #ifdef DEBUG
            NSLog(@"Update parse faild. Ready to revert the strategy file.");
            #endif
            NSData *backupData = [[NSFileHandle fileHandleForReadingAtPath:backupFilePath] readDataToEndOfFile];
            [fileManager createFileAtPath:oldFilePath contents:backupData attributes:nil];
            [[UsageStrategyController getCurrent] generate];
            [[UsageRecorder sAssist] updateStrategyResult:NO];
        } else {
            #ifdef DEBUG
            NSLog(@"Update parse succeed.");
            #endif
            [[UsageRecorder sAssist] updateStrategyResult:YES];
        }
    });
}

@end
