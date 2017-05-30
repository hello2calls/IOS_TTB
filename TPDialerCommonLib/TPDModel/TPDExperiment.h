//
//  TPDExperiment.h
//  TouchPalDialer
//
//  Created by weyl on 16/12/1.
//
//

#import <Foundation/Foundation.h>

#define MULTI_CALL @"multi_call"
#define MULTI_CALL_DEFAULT @"no_multi_call"

#define GRAY_LEVEL_DISTRIBUTE @"gray_level_distribution"
#define GRAY_LEVEL_DISTRIBUTE_DEFAULT @"normal_package"
#define GRAY_LEVEL_DISTRIBUTE_GRAY_LEVEL @"gray_level_package"


@interface TPDExperiment : NSObject
@property (nonatomic, strong) NSString* key;
@property (nonatomic,strong) NSString* defaultValue;
@property (nonatomic,strong) NSString* result;
@property (nonatomic) BOOL isDefaultValue;

+(TPDExperiment*)multiCallExperiment;
+(BOOL)runExperiments:(NSArray*)experiments;
+(void)runAllExperiment;
@end
