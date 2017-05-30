//
//  SeattleEngine.h
//  TPDialerAdvanced
//
//  Created by Elfe Xu on 12-10-10.
//
//

#import <Foundation/Foundation.h>
#import "NumberInfoModel.h"

typedef enum {
    FeatureExecuteResultSuccess,
    FeatureExecuteResultFailCouldRetry,
    FeatureExecuteResultFail
} FeatureExecuteResult;

typedef enum {
    ActivateTypeNew,
    ActivateTypeRenew,
    ActivateTypeUpgrade,
} ActivateType;

@interface SeattleEngine : NSObject

+(BOOL) fillNumberInfo:(NumberInfoModel*) data;

+(BOOL) activateWithType:(ActivateType) type;

+(BOOL) uploadCallHistory;

@property (nonatomic, assign) int lastSuccessTime;

@end
