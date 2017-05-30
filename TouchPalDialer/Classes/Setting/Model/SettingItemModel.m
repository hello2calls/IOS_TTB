//
//  SettingItemModel.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SettingItemModel.h"

@implementation SettingItemModel

@synthesize isEnabled;
@synthesize title;
@synthesize subtitle;
@synthesize monitorKey;
@synthesize hintCount;
@synthesize hintType;
@synthesize featureTip;

-(id) init {
    self = [super init];
    if(self) {
        self.isEnabled = YES;
    }
    return self;
}

@end
