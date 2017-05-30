//
//  SearchEngineInputSource.h
//  test_thread
//
//  Created by Bruce_Li_799 on 7/8/11.
//  Copyright 2011 Yellowbook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSearch.h"

@interface SearchEngineInputSource : NSObject<TPSearchDataSource> 
@property(nonatomic,assign)id mainThreadResponse;
- (id)initWithEngine:(TPDefaultSearch *)engine response:(id)response;
- (void)addToCurrentRunLoop;
- (void)removeToCurrentRunRoop;

- (void)addSearchKeyword:(NSString*)pSearchKeyword;
- (void)cleanUpKeywordList;
- (NSString*)getCurrentKeyword;
@end
