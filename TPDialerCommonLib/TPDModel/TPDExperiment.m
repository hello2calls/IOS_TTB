//
//  TPDExperiment.m
//  TouchPalDialer
//
//  Created by weyl on 16/12/1.
//
//

#import "TPDExperiment.h"
#import "SeattleFeatureExecutor.h"
#import "TouchPalVersionInfo.h"
#import "ASIWrapper.h"
#import "IndexConstant.h"

#import <MJExtension.h>
#import "TPDLib.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"



@implementation TPDExperiment
static int interval = 60 * 120;

+(TPDExperiment*)multiCallExperiment{
    static dispatch_once_t onceToken;
    static TPDExperiment* exp = nil;
    dispatch_once(&onceToken, ^{
        exp = [[TPDExperiment alloc] init];
        exp.key = MULTI_CALL;
        exp.defaultValue = MULTI_CALL_DEFAULT;
        exp.isDefaultValue = YES;

    });
    return exp;
}

+(TPDExperiment*)grayLevelDistributeExperiment{
    static dispatch_once_t onceToken;
    static TPDExperiment* exp = nil;
    dispatch_once(&onceToken, ^{
        exp = [[TPDExperiment alloc] init];
        exp.key = GRAY_LEVEL_DISTRIBUTE;
        exp.defaultValue = GRAY_LEVEL_DISTRIBUTE_DEFAULT;
        exp.isDefaultValue = YES;
        
    });
    return exp;
}

+(BOOL)runExperiments:(NSArray*)experiments{
    NSString* url = [NSString stringWithFormat:@"%@/yellowpage_v3/experiment_query",TOUCHLIFE_SITE];
//    NSString* url = [NSString stringWithFormat:@"%@/yellowpage_v3/experiment_query",@"http://121.52.235.231:40013"];
    
    ASIWrapper* wrapper = [ASIWrapper defaultWrapperObject];
//    wrapper.pathStr
    wrapper.pathStr = url;
    wrapper.params = [@{
                        @"app_name":COOTEK_APP_NAME,
                        @"_token":[SeattleFeatureExecutor getToken],
                        @"app_version":CURRENT_TOUCHPAL_VERSION,
                        } mutableCopy];
    wrapper.responseStructKey = @"result";
    
    for (TPDExperiment* exp in experiments) {
        [wrapper.params setValue:exp.key forKey:@"experiments_name"];
    }
    
    [ASIWrapper getRequest:wrapper];
    

    NSDictionary* d = wrapper.responseStruct;
    if (wrapper.success) {
        if ([d[@"error_code"] integerValue] == 2000) {
            for (TPDExperiment* exp in experiments) {
                NSString* key = exp.key;
                NSDictionary* tmp = [d[@"experiments_results"] tpd_JSONValue];
                if (tmp[key] !=nil) {
                    exp.result = tmp[key];
                    exp.isDefaultValue = [exp.result isEqualToString:exp.defaultValue];
                    
                }
            }
            return YES;
        }
    }
    
    return NO;
    
}

+(void)runAllExperiment{
    FIRST_TIME_RUN_IN_VERSION(@"V603",(^{
        [UserDefaultsManager setBoolValue:NO forKey:GRAY_LEVEL_DISTRIBUTE];
    }))
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        while([SeattleFeatureExecutor getToken]== nil ){
            [NSThread sleepForTimeInterval:3.f];
        }
        TPDExperiment* exp = [TPDExperiment multiCallExperiment];
        [TPDExperiment runExperiments:@[exp]];
        

        
        if ([FunctionUtility systemVersionFloat] >= 8.0) {
            
            TPDExperiment* exp2 = [TPDExperiment grayLevelDistributeExperiment];
            if ([TPDExperiment runExperiments:@[exp2]] && exp2.result != nil) {
                if (exp2.isDefaultValue) {
                    [UserDefaultsManager setBoolValue:NO forKey:GRAY_LEVEL_DISTRIBUTE];
                }else{
                    [UserDefaultsManager setBoolValue:YES forKey:GRAY_LEVEL_DISTRIBUTE];
                }
            }
            
        }
        
    });
    
    
}


@end
