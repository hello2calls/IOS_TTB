//
//  TPAdDSPController.m
//  TouchPalDialer
//
//  Created by siyi on 16/6/22.
//
//

#import "TPAdDSPController.h"
#import "SeattleFeatureExecutor.h"
#import "NSString+TPHandleNil.h"
#import "FileUtils.h"
#import "TouchPalVersionInfo.h"

@implementation TPAdDSPController {
    NSMutableDictionary *_cachedStrategies;
    NSMutableDictionary *_cachedRawMessages;
    NSString *_filePath;
}

+ (instancetype) sharedController {
    static TPAdDSPController *_shareInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _shareInstance = [[TPAdDSPController alloc] init];
    });
    return _shareInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _filePath = [FileUtils getAbsoluteFilePath:AD_CONTROLLER_STRATEGY_FILE];
        if (_cachedStrategies == nil) {
            _cachedStrategies = [[NSMutableDictionary alloc] initWithCapacity:1];
        }
        if (_cachedRawMessages == nil) {
            _cachedRawMessages = [[NSMutableDictionary alloc] initWithCapacity:1];
        }
        @autoreleasepool {
            if ([FileUtils fileExistAtAbsolutePath:_filePath]) {
                NSDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:_filePath];
                for(NSString *key in dict.allKeys) {
                    NSString *rawString = [dict objectForKey:key];
                    TPAdControlStrategy *strategy = [[TPAdControlStrategy alloc] initWithRawString:rawString];
                    [_cachedStrategies setObject:strategy forKey:key];
                    [_cachedRawMessages setObject:rawString forKey:key];
                }
            }
        }
    }
    return self;
}

- (TPAdControlStrategy *) requestForStrategyByParams:(TPAdControlRequestParams *)requestParams {
    if (requestParams == nil
        || [NSString isNilOrEmpty:requestParams.tu]) {
        return nil;
    }
    TPAdControlStrategy *retStrategy = nil;
    @synchronized (self) {
        NSString *key = [NSString stringWithFormat:@"%@_%d", CURRENT_TOUCHPAL_VERSION, requestParams.feedsId];
        retStrategy = [SeattleFeatureExecutor getControlServerData:requestParams];
        if (retStrategy == nil) {
            retStrategy = [_cachedStrategies objectForKey:key];
        } else {
            [_cachedStrategies setObject:retStrategy forKey:key];
            [_cachedRawMessages setObject:retStrategy.rawMessageString forKey:key];
            BOOL writeSuccess = [_cachedRawMessages writeToFile:_filePath atomically:YES];
            cootek_log(@"%s, file: %@, writeSuccess: %d", __func__, _filePath, writeSuccess);
        }
    } // @synchronized
    return retStrategy;
}

- (void) asyncRequestForStrategyByParams:(TPAdControlRequestParams *)requestParams
                       completitionBlock:(void (^)(TPAdControlStrategy *strategy))completitionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TPAdControlStrategy *retStrategy =
            [[TPAdDSPController sharedController] requestForStrategyByParams:requestParams];
        if (completitionBlock != nil) {
            completitionBlock(retStrategy);
        }
    });
}

- (TPAdControlStrategy *) getCachedStrategy:(NSString *)ftu {
    NSString *key = [NSString stringWithFormat:@"%@_%@", CURRENT_TOUCHPAL_VERSION, ftu];
    return [_cachedStrategies objectForKey:key];
}

@end
