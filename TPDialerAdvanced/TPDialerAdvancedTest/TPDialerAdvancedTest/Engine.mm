//
//  Engine.m
//  TPDialerAdvancedTest
//
//  Created by Elfe Xu on 12-10-9.
//  Copyright (c) 2012年 Elfe Xu. All rights reserved.
//

#import "Engine.h"
#import "NumberInfoModel.h"

@implementation Engine

-(id) initWithNumber:(NSString*) number {
    self = [super init];
    if(self != nil) {
        self.number = number;
        self.model = [[[NumberInfoModel alloc] initWithNumber:number] autorelease];
    }
    return self;
}

-(void) queryLocation {
    [self.model loadLocation];
    self.text1 = [self.model location];
    self.text2 = [self.model textForNumber:self.number originalText:self.number originalLabel:@"" hasLocation:YES];
    self.text3 = [self.model textForNumber:self.number originalText:self.number originalLabel:@"" hasLocation:NO];

}

-(void) queryCallerId {
    [self.model loadCallerId];
    self.text2 = [self.model textForNumber:self.number originalText:self.text2 originalLabel:@"" hasLocation:YES];
    self.text3 = [self.model textForNumber:self.number originalText:self.text3 originalLabel:self.text1 hasLocation:NO];
}



@end
