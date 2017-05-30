//
//  SixpackUtil.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/21.
//
//

#import "SixpackUtil.h"
#import "Sixpack.h"
#import "SeattleFeatureExecutor.h"

#define ABTEST_URL @"http://dialer-abtest.cootekservice.com:5000/"

static NSString * _Nonnull const EXPERIMENT_NAME = @"experiment_name";

@interface SixpackUtil ()

@property (nonatomic,strong) NSMutableDictionary *allExperiment;

@end

@implementation SixpackUtil

+ (instancetype)sharedInstance
{
    static SixpackUtil *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSMutableDictionary *) allExperiment
{
    if (!_allExperiment) {
        _allExperiment = [NSMutableDictionary dictionary];
    }
    return _allExperiment;
}

- (instancetype) init
{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(experimentSucess:) name:SGSixpackExperimentSetupComplete object:nil];
    }
    return self;
}

- (void) connectToHost
{
    [Sixpack connectToHost:ABTEST_URL
                     token:[SeattleFeatureExecutor getToken]];
}

- (void) buildExperiment:(nonnull NSString *)experiment
           alternatives:(nonnull NSArray *)alternatives
{
    NSString *experimentName = [self generateExperimentNameWith:experiment];
    
    [self.allExperiment setObject:alternatives forKey:experimentName];
    
    [Sixpack setupExperiment:experimentName alternatives:alternatives];

}

- (void) experimentSucess:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    
    if ([self.allExperiment valueForKey:userInfo[EXPERIMENT_NAME]] != nil) {
        [Sixpack participateIn:userInfo[EXPERIMENT_NAME] onChoose:^(NSString *chosenAlternative) {
            
        }];
    }
}

+ (void) initialize
{
    [[self sharedInstance] connectToHost];
}

#pragma mark - public Method


+ (void) setupExperiment:(nonnull NSString *)experiment
           alternatives:(nonnull NSArray *)alternatives
{
    [[self sharedInstance] buildExperiment:experiment alternatives:alternatives];
}

+ (void) participateIn:(nonnull NSString *)experiment
             onChoose:(void( ^ _Nullable )( NSString * _Nullable chosenAlternative))block
{
    [Sixpack participateIn:[self generateExperimentNameWith:experiment] onChoose:block];
}

+ (void) convert:(nonnull NSString *)experiment
        withKpi:(nullable NSString *)kpi
{
    [Sixpack convert:[self generateExperimentNameWith:experiment] withKpi:kpi];
}

#pragma mark - private Method

+ (NSString *) generateExperimentNameWith:(NSString *)experiment
{
    NSString *bulidVersion = [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleVersion"];
    bulidVersion = [bulidVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [NSString stringWithFormat:@"iOS_%@_%@",bulidVersion,experiment];
}
- (NSString *) generateExperimentNameWith:(NSString *)experiment
{
    NSString *bulidVersion = [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleVersion"];
    bulidVersion = [bulidVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [NSString stringWithFormat:@"iOS_%@_%@",bulidVersion,experiment];
}
@end
