//
//  SixpackUtil.h
//  TouchPalDialer
//
//  Created by ALEX on 16/7/21.
//
//

#import <Foundation/Foundation.h>

static NSString * _Nonnull const EXPERIMENT_SKIPBUTTON = @"skip";
static NSString * _Nonnull const SKIPBUTTON_CIRLE = @"style_cirle";
static NSString * _Nonnull const SKIPBUTTON_WAVE = @"sytle_wave";
static NSString * _Nonnull const SKIPBUTTON_COUNTDOWN = @"style_countdown";
static NSString * _Nonnull const SKIPBUTTON_NORMAL = @"style_normal";

@interface SixpackUtil : NSObject

+ (void) setupExperiment:(nonnull NSString *)experiment
            alternatives:(nonnull NSArray *)alternatives;

+ (void) participateIn:(nonnull NSString *)experiment
              onChoose:(void( ^ _Nullable )( NSString * _Nullable chosenAlternative))block;

+ (void) convert:(nonnull NSString *)experiment
         withKpi:(nullable NSString *)kpi;

@end
