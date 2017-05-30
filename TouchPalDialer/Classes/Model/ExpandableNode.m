//
//  CellNodeBase.m
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ExpandableNode.h"
#import "SmartGroupNode.h"
#import "ContactCacheDataManager.h"
#import "CootekNotifications.h"
@interface ExpandableNode() {
    NSMutableArray* children_;
    BOOL _isRreshData;
}
- (void) loadDataWithSyncMode:(BOOL) sync;
- (void) notifyBeginLoad;
- (void) loadData ;
- (void) notifyEndLoad;
@end
@implementation ExpandableNode

@synthesize data;
@synthesize depth;
@synthesize canHaveChildren;
@synthesize isExpanded;

@synthesize isDataLoaded;
@synthesize isDataLoading;
@synthesize loadDataDelegate;

- (id) initWithData:(id) nodeData {
    self = [super init];
    self.data = nodeData;
    children_ = [[NSMutableArray alloc] init];
    self.isExpanded = NO;
    self.canHaveChildren = YES;
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark index/depth calculation

- (NSInteger) totalVisibleItemCount {
    if(!canHaveChildren && [self visible]) {
        // This is the leaf node. Only have 1 item for itself.
        return 1;
    }
    
    NSInteger count = [self visible] ? 1 : 0;
    
    if([self children] == nil || !isExpanded) {
        return count;
    }
    
    for(int i=0; i < [[self children] count]; i++) {
        ExpandableNode* child = [[self children] objectAtIndex:i];
        count = count + [child totalVisibleItemCount];
    }
    
    return count;
}

- (BOOL)visible{
    if((canHaveChildren && data == nil) || _hidden) {
        // The node only has items for it's children.
        // It does not have items for itself.
        return NO;
    } else {
        return YES;
    }
}

- (ExpandableNode*) visibleItemAtIndex:(NSInteger) index {
    
    if(index >= [self totalVisibleItemCount]) {
        NSLog(@"Error: index out of range.");
        return nil;
    }
    
    if([self visible]) {
        if(index == 0) {
            return  self;
        } else {
            index = index -1;
        }
    }
    
    for(int i = 0; i < [[self children] count]; i++) {
        ExpandableNode* item = (ExpandableNode*) [[self children] objectAtIndex:i];
        int visibleItemCount = [item totalVisibleItemCount];
        if(index >= visibleItemCount) {
            index = index - visibleItemCount;
            continue;
        } else {
            return [item visibleItemAtIndex:index];
        }
    }
    
    NSLog(@"Error: should not hit this line.");
    return nil;
}

#pragma mark loading data

- (NSArray*) children {
    return children_;
}

- (void) loadDataSync {
    [self loadDataWithSyncMode:YES];
}

- (void) loadDataAsync {
        [self loadDataWithSyncMode:NO];
}

- (void) refreshDataAsync{
     @synchronized(self) {
          isDataLoaded = false;
          isDataLoading = false;
          [children_ removeAllObjects];
          [self loadDataAsync];
     }
}

- (void) refreshDataSync{
    @synchronized(self) {
        isDataLoaded = false;
        isDataLoading = false;
        [children_ removeAllObjects];
        [self loadDataSync];
    }
}

- (void) loadDataWithSyncMode:(BOOL) sync {
    @synchronized(self) {
        if(isDataLoaded || isDataLoading) {
            //already loading, don't load again
            NSLog(@"Don't reload the data. The refresh function is not implemented yet.");
            return;
        }
        
        isDataLoading = YES;
        if(sync) {
            [self notifyBeginLoad];
            [self loadData];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self notifyBeginLoad];
                [self loadData];
            });
        }
    }
}

- (void) loadData {
    @autoreleasepool {
        @synchronized(self) {
            [children_ removeAllObjects];
            [self onLoadData];
            isDataLoading = NO;
            isDataLoaded = YES;
            //isExpanded = YES;
        }
    }
    
    [self performSelectorOnMainThread:@selector(notifyEndLoad) withObject:nil waitUntilDone:NO];
}

- (void) addChild:(ExpandableNode*) child {
    @synchronized(self) {
        child.depth = self.depth + 1;
        [children_ addObject:child];
    }
}

- (void) onLoadData {
    // Derive this class to load data
}

- (void) notifyBeginLoad {
    if(loadDataDelegate != nil) {
        [loadDataDelegate onBeginLoadData];
    }
    [self onBeginLoadData];
}

- (void) notifyEndLoad {
    if(loadDataDelegate != nil) {
        [loadDataDelegate onEndLoadData:self];
    }
    [self onEndLoadData];
    _isRreshData = NO;
}

- (void) reloadData{

}

- (void)observePersonDataChange {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPersonDataChange) name:N_PERSON_DATA_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPersonDataChange) name:N_SYSTEM_CONTACT_DATA_CHANGED object:nil];
}

- (void)onPersonDataChange {
    if (!_isRreshData) {
        _isRreshData = YES;
        [self refreshDataAsync];
    }
}

- (void)onEndLoadData {

}

- (void)onBeginLoadData {

}

- (BOOL)isEqual:(id)object {
    if ( ![object isKindOfClass:[ExpandableNode class]]){
        return NO;
    }
    if (self == object) {
        return YES;
    }
    ExpandableNode *node2 = object;
    if (!self.nodeDescription || !node2.nodeDescription) {
        return NO;
    }
    if ([self.nodeDescription isEqual:node2.nodeDescription]) {
        return YES;
    }
    return NO;
}

- (ExpandableNode *)isNodeExist:(ExpandableNode *)node {
    if (node == nil) {
        return nil;
    }
    if ((node == self || [self isEqual:node]) && !self.hidden) {
        return self;
    }
    if (self.children.count == 0) {
        return nil;
    }
    for (ExpandableNode *child in self.children) {
        ExpandableNode *result = [child isNodeExist:node];
        if (result) {
            return result;
        }
    }
    return nil;
}

@end
