//
//  LeafNode.m
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LeafNode.h"
#import "CootekNotifications.h"

@implementation StringNumberPair
@synthesize string;
@synthesize number;
- (NSString *)stringNumberPair{
    return [NSString stringWithFormat:@"%@ (%d)",string,number];
}
@end

@implementation LeafNodeWithContactIds
@synthesize contactIds = contactIds_;
- (BOOL)addObserverToDataChangedNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataAsync) name:N_PERSON_DATA_CHANGED object:nil];
    return true;
}
- (void)removeObserverToDataChangedNofication{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)dealloc{
     [self removeObserverToDataChangedNofication];
}
@end

@implementation LeafNode

+ (LeafNode*) leafNodeWithData:(id) nodeData {
    return [[LeafNode alloc] initWithData:nodeData];
}
- (id) initWithData:(id) nodeData {
     self = [super initWithData:nodeData];
     self.canHaveChildren = NO;
     return self;
}

@end
