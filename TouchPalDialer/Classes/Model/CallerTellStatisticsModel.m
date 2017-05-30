//
//  CallerTellStatisticsModel.m
//  CallerInfoShow
//
//  Created by lingmei xie on 13-1-30.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//

#import "CallerTellStatisticsModel.h"
#import "CallLogDBA.h"
#import "CallLogDataModel.h"

@implementation CallerTellStatisticsModel
@synthesize totalCount = totalCount_;
@synthesize count = count_;
@synthesize types = types_;

-(id)initCallerTellStatisticsModel:(NSInteger)totalCount
                             count:(NSInteger)count
                        typesCount:(NSArray *)types
{
    if (self = [super init]) {
        totalCount_ = totalCount;
        count_ = count;
        types_ = types;
    }
    return self;
}
+ (CallerTellStatisticsModel *)callerTellStatistics:(CallerTellStatisticsModelType)type
{
    int totalCount = [CallLogDBA unknowCalllogCount];
    int count = 0;
    NSArray *types = nil;
    switch (type) {
        case CallerTellStatisticsModelTypeKnow:{
            NSArray *knows = [CallLogDBA queryAllRecognitionCallogs];
            count = [knows count];
            types = [CallerTellStatisticsModel arrayCountTypes:knows];
            break;
        }
        case CallerTellStatisticsModelTypeMark:{
            NSArray *knows = [CallLogDBA queryAllMarkCallogs];
            count = [knows count];
            types = [CallerTellStatisticsModel arrayCountTypes:knows];
            break;
        }
        default:
            break;
    }
   return  [[CallerTellStatisticsModel alloc] initCallerTellStatisticsModel:totalCount
                                                                       count:count
                                                                  typesCount:types];
}

+(NSArray *)arrayCountTypes:(NSArray *)datas
{
    NSMutableDictionary *typesDict = [NSMutableDictionary dictionaryWithCapacity:[datas count]];
    for (CallLogDataModel *calllog in datas) {
        NSString *knownTypeOrEmpty = [CallerIDInfoModel knownCallerTypeOrEmpty:calllog.callerID.callerType];
        int count = [[typesDict objectForKey:knownTypeOrEmpty] integerValue];
        [typesDict setObject:@(count + 1) forKey:knownTypeOrEmpty];
    }    
    NSMutableArray *types = [NSMutableArray arrayWithCapacity:[typesDict count]];
    for (NSString *key in [typesDict allKeys]) {
        [types addObject:@{key: typesDict[key]}];
    }
    return [types sortedArrayUsingFunction:compareNSDictionary context:nil];
}

NSInteger compareNSDictionary(id obj1, id obj2, void *context)
{
	int obj1Count = [[[(NSDictionary *)obj1 allValues] objectAtIndex:0] integerValue];
	int obj2Count = [[[(NSDictionary *)obj2 allValues] objectAtIndex:0] integerValue];
    
	if (obj1Count > obj2Count) {
		return NSOrderedAscending;
	} else if (obj1Count == obj2Count) {
		return NSOrderedSame;
	} else {
		return NSOrderedDescending;
	}
}
@end
