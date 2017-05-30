//
//  SearchEngineThread.h
//  test_thread
//
//  Created by Bruce_Li_799 on 7/8/11.
//  Copyright 2011 Yellowbook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPSearch.h"

@class SearchEngineInputSource;

@interface SearchEngineThread : NSThread

- (id)initWithEngine:(TPDefaultSearch *)engine respone:(id)response;
- (void)stopRunLoop;

- (NSString *)currentQueryContent;
- (void)addQueryContent:(NSString *)content;
- (void)cleanAllContent;
@end
