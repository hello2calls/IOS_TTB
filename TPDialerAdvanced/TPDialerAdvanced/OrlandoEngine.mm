//
//  OrlandoEngine.mm
//  TPDialerAdvanced
//
//  Created by Xu Elfe on 12-10-09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include "def.h"
#include <list>
#include <fcntl.h>
#include "TPDialerAdvanced.h"
#import "AdvancedSettingKeys.h"
#import "Util.h"
#import "ContactEngine.h"
#import "CStringUtils.h"
#import "SearchResult_CallerID.h"
#import "OrlandoEngine.h"
#import "DatabaseEngine.h"
#import "NumberInfoModel.h"
#import "AdvancedSettingUtility.h"

@implementation OrlandoEngine

using namespace std;
using namespace orlando;

static ContactEngine* engine;


+ (void)initialize {
    engine = new ContactEngine();
    
}

+ (BOOL) fillNumberInfo:(NumberInfoModel*) data {
    @synchronized([OrlandoEngine class]) {
        cootek_log_function;
        
        if(data.isCallerId) {
            return YES;
        }
        
        NSString* number = data.normalizedNumber;
        NSArray* cities = [self loadCityFiles];
            
        SearchResult_CallerID result;
        u16string num = CStringUtils::nsstr2u16str(number);
        cootek_log(@"start to search: %@", number);
        if(engine->GetCallerIDInfo(&result, num)) {
            //TODO: handle fraud/crank
            data.name = CStringUtils::u16str2nsstr(result.getName());
            data.classify = CStringUtils::u16str2nsstr(result.getClassifyType());
            data.markCount = result.GetCrankCount();
            data.versionTime = [NSString stringWithFormat:@"%llu", result.GetDataTime()];
            data.verified = NO;
            data.cacheLevel = 3;
            data.vipId = result.GetVipID();
            data.isCallerId = YES;
            cootek_log(@"get callerid %@, %@, for number %@, markCount %d", data.name, data.classify, number, data.markCount);
        } else {
            cootek_log(@"cannot find callerid for number %@", number);
        }
        
        for(NSNumber* n in cities) {
            engine->DeleteFile([n intValue]);
        }

        return data.isCallerId;
    }
}

+ (NSArray*) loadCityFiles {
    NSArray* allCities = [DatabaseEngine queryAllCityFiles];
    
    NSString* documentPath = [AdvancedSettingUtility dialerDocumentPath];
    NSMutableArray* cityDescriptions = [NSMutableArray arrayWithCapacity:2];
    for(NSString* cityPath in allCities) {
        FileDescription fd;
        fd.type = CallerID;
   
        NSString* folderPath = [NSString stringWithFormat:@"%@%@", documentPath, cityPath];
        
        fd.files[priorityFile] = [self openFile:@"priority.img" inFolder:folderPath];;
        fd.files[dataFile] = [self openFile:@"data.img" inFolder:folderPath];
        fd.files[indexFile] = [self openFile:@"index.img" inFolder:folderPath];
        fd.files[tableFile] = [self openFile:@"table.img" inFolder:folderPath];
        fd.files[calleridFile] = [self openFile:@"number.img" inFolder:folderPath];
        fd.files[delta_dataFile] = [self openFile:@"dataUpdate.img" inFolder:folderPath];
        fd.files[delta_indexFile] = [self openFile:@"indexUpdate.img" inFolder:folderPath];
        fd.files[delta_tableFile] = [self openFile:@"tableUpdate.img" inFolder:folderPath];
        fd.files[delta_calleridFile] = [self openFile:@"numberUpdate.img" inFolder:folderPath];
        
        if(fd.files[dataFile] != NULL &&
           fd.files[indexFile] != NULL &&
           fd.files[tableFile] != NULL) {
            int i = engine->CreatFileForCaller(fd);
            NSLog(@"createFile id: %d", i);
            [cityDescriptions addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return cityDescriptions;
}


+(FILE*) openFile:(NSString*)fileName inFolder:(NSString*)folder
{
    NSString* filePath = [NSString stringWithFormat:@"%@%@",folder, fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExtis = [fileManager fileExistsAtPath:filePath];
    if (fileExtis) {
        return fopen([filePath UTF8String],"r");
    } else {
        return NULL;
    }
}

@end