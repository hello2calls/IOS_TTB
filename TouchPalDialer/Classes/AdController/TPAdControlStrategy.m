//
//  TPAdControlStrategy.m
//  TouchPalDialer
//
//  Created by siyi on 16/6/22.
//
//

#import "TPAdControlStrategy.h"
#import "TPAdControlRequestParams.h"
#import "NSString+TPHandleNil.h"

@implementation TPAdControlStrategy

#pragma mark - Override

- (instancetype) init {
    self = [super init];
    if (self) {
        _effectivePlatformIds = @[@(DSP_TYPE_TP_DAVINCI)];
    }
    return self;
}

- (instancetype) initWithRawString:(NSString *)rawMessage {
    self = [self init];
    if (self && ![NSString isNilOrEmpty:rawMessage]) {
        NSError *error = nil;
        NSData *data = [rawMessage dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (data && error == nil) {
            _tu = [[dict objectForKey:@"tu"] stringValue];
            _s = [dict objectForKey:@"s"];
            _platformIdsForNextRequst = [dict objectForKey:@"enable_platform_list"];
            _effectivePlatformIds = [dict objectForKey:@"ad_platform_id"];
            _expId = [[dict objectForKey:@"expid"] longValue];
            _dataId = [dict objectForKey:@"data_id"];
        }
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"\n, <%p>, \ntu=%@, \nexpId=%d, \ns=%@, \neffectivePlatformIds=%@, \nplatformIdsForNextRequst=%@, \ndataId=%@", \
            self, _tu, _expId, _s, _effectivePlatformIds, _platformIdsForNextRequst, _dataId];
}


@end
