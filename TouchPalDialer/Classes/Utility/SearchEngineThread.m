//
//  SearchEngineThread.m
//  test_thread
//
//  Created by Bruce_Li_799 on 7/8/11.
//  Copyright 2011 Yellowbook. All rights reserved.
//

#import "SearchEngineThread.h"
#import "SearchEngineInputSource.h"


@interface SearchEngineThread(){
	SearchEngineInputSource* inputSource;
}
@end

@implementation SearchEngineThread

- (id)initWithEngine:(TPDefaultSearch *)engine respone:(id)response{
    self = [super init];
	if (self != nil) {
		inputSource = [[SearchEngineInputSource alloc] initWithEngine:engine response:response];
	}
	return self;
}
- (void) dealloc
{
    cootek_log(@"dealloc SearchEngineThread");
}
- (void)stopRunLoop{
    inputSource.mainThreadResponse = nil;
    [inputSource removeToCurrentRunRoop];
    [self cancel];
}

- (void)main
{
    [inputSource addToCurrentRunLoop];
	while (![self isCancelled]) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
}
- (NSString *)currentQueryContent{
    return [inputSource getCurrentKeyword];
}
- (void)addQueryContent:(NSString *)content{
    [inputSource addSearchKeyword:content];
}
- (void)cleanAllContent{
    [inputSource cleanUpKeywordList];
}
@end
