//
//  SectionGroup.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#import <Foundation/Foundation.h>
#import "SectionGroup.h"
#import "SectionBase.h"

@implementation SectionGroup

- (id) init
{
    self = [super init];
    self.sectionArray = [[NSMutableArray alloc]init];
    self.index = -1;
    self.current = -1;
    
    return self;
}

- (id) initWithType: (NSString*) type andIndex: (NSInteger)idx
{
    self = [super init];
    self.sectionArray = [[NSMutableArray alloc]init];
    self.index = idx;
    self.sectionType = type;
    self.current = 0;
    
    return self;
}

- (BOOL) isValid
{
    for (SectionBase* section in self.sectionArray) {
        if ([section isValid]) {
            return YES;
        }
    }
    
    return NO;
}

- (id) validCopy
{
    SectionGroup* ret = [[SectionGroup alloc]init];
    for (SectionBase* section in self.sectionArray) {
        if ([section isValid]) {
            SectionBase* temp = [section validCopy];
            [ret.sectionArray addObject:temp];
        }
    }
    
    ret.index = self.index;
    ret.sectionType = self.sectionType;
    ret.current = self.current;

    return ret;
}

- (id) copyAll
{
    SectionGroup* ret = [[SectionGroup alloc]init];
    for (SectionBase* section in self.sectionArray) {
        SectionBase* temp = [section validCopy];
        [ret.sectionArray addObject:temp];
    }
    
    ret.index = self.index;
    ret.sectionType = self.sectionType;
    ret.current = self.current;
    
    return ret;
}

- (id) getPreviousItem
{
    if(self.sectionArray == nil || self.sectionArray.count == 0) {
        return nil;
    }
    int idx;
    if(self.current == 0) {
        idx = self.sectionArray.count - 1;
    } else {
        idx = self.current - 1;
    }
    
    return [self.sectionArray objectAtIndex:idx];
}

- (id) getNextItem
{
    //TODO:
    return nil;
}
@end