//
//  FeatureTipModel.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-22.
//
//

#import "FeatureTipModel.h"
#import "BasicUtil.h"
#import "UserDefaultsManager.h"

@implementation FeatureTipModel

@synthesize tipKey;
@synthesize expectedValue;
@synthesize showTip;

+(FeatureTipModel*) featureTipModelWithKey:(NSString*)key expectedValue:(id)value {
    return [[FeatureTipModel alloc] initWithKey:key expectedValue:value];
}

-(id) initWithKey:(NSString*)key expectedValue:(id)value {
    self = [super init];
    if(self) {
        self.tipKey = key;
        self.expectedValue = value;
        self.showTip = YES;
        id obj = [UserDefaultsManager objectForKey:key];
        if(obj != nil) {
            if([BasicUtil object:obj equalTo:value]) {
                self.showTip = NO;
            }
        }
    }
    
    return self;
}

-(void)removeTip {
    if(self.showTip) {
        [UserDefaultsManager setObject:expectedValue forKey:tipKey];
        self.showTip = NO;
    }
}


@end
