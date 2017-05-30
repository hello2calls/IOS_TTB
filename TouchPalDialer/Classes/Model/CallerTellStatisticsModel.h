//
//  CallerTellStatisticsModel.h
//  CallerInfoShow
//
//  Created by lingmei xie on 13-1-30.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CallerTellStatisticsModelTypeKnow,
    CallerTellStatisticsModelTypeMark,
}CallerTellStatisticsModelType;

@interface CallerTellStatisticsModel : NSObject
@property(nonatomic,assign,readonly) NSInteger totalCount;
@property(nonatomic,assign,readonly) NSInteger count;
@property(nonatomic,retain,readonly) NSArray *types;

+ (CallerTellStatisticsModel *)callerTellStatistics:(CallerTellStatisticsModelType)type;

- (id)initCallerTellStatisticsModel:(NSInteger)totalCount
                             count:(NSInteger)count
                        typesCount:(NSArray *)types;
@end
