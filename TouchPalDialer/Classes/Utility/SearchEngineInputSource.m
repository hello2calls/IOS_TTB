//
//  SearchEngineInputSource.m
//  test_thread
//
//  Created by Bruce_Li_799 on 7/8/11.
//  Copyright 2011 Yellowbook. All rights reserved.
//

#import "SearchEngineInputSource.h"
#import "DataBaseModel.h"
#import "PhonePadModel.h"
#import "ContactSearchModel.h"

@interface SearchEngineInputSource() {
    TPDefaultSearch __strong *searchEngine_;
    CFRunLoopSourceRef runLoopSource;
    CFRunLoopRef runLoop;
    NSMutableArray* keywordList;
}
- (void)searchCallBack:(NSString *)pKeyWord withResult:(NSArray *)result_list;
- (void)sourceFired:(NSString *)m_current;
- (void)updateUIElements:(SearchResultModel *)results;
- (void)fireOnRunLoop:(CFRunLoopRef)runloop;

void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine (void *info);
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);

@end

@implementation SearchEngineInputSource
@synthesize mainThreadResponse;
- (id) initWithEngine:(TPDefaultSearch *)engine response:(id)response{
    self = [super init];
	if (self != nil) {
		CFRunLoopSourceContext    context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
			&RunLoopSourceScheduleRoutine,
			RunLoopSourceCancelRoutine,
			RunLoopSourcePerformRoutine};
		runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
		keywordList = [[NSMutableArray alloc] init];
		searchEngine_ = engine;
        searchEngine_.dataSource = self;
        self.mainThreadResponse = response;
		return self;
	}
	return self;
}
- (void) dealloc
{
    searchEngine_.dataSource = nil;
    SAFE_CFRELEASE_NULL(runLoopSource);
}
- (void)addToCurrentRunLoop{
    runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
}
-(void)removeToCurrentRunRoop{
    CFRunLoopRemoveSource(runLoop,runLoopSource,kCFRunLoopDefaultMode);
    CFRunLoopStop(runLoop);
}
//Delays 操作
- (void)updateUIElements:(SearchResultModel *)results;
{
	NSString *searchKeyword=results.searchKey;
	if (![searchKeyword isEqualToString:[self getCurrentKeyword]] || mainThreadResponse == nil) {
		return;
	}
    [mainThreadResponse performSelectorOnMainThread:@selector(searchDidFinish:)
                                          withObject:results
                                       waitUntilDone:NO];
}

- (void)sourceFired:(NSString *)keyword
{
    @autoreleasepool {
        if (![keyword isEqualToString:[self getCurrentKeyword]] || mainThreadResponse == nil) {
            return;
        }
        NSArray *resultList = nil;
        if ([keywordList count] > 0) {
            resultList =[searchEngine_ query:keyword];
            [self searchCallBack:keyword withResult:resultList];
        }
    }
}

- (void)searchCallBack:(NSString *)pKeyWord withResult:(NSArray *)result_list{
	if ([pKeyWord isEqualToString:[self getCurrentKeyword]] && mainThreadResponse) {
		SearchResultModel *search_result = [searchEngine_ wrapResults:result_list
                                                            serachKey:pKeyWord];
		int sKeySize = (5 - [pKeyWord length]);
		if((sKeySize > 0)&& ([pKeyWord length]>0))
		{
			[self performSelector:@selector(updateUIElements:)
                       withObject:search_result
                       afterDelay:(sKeySize * 0.05)];
		}else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([mainThreadResponse isKindOfClass:[PhonePadModel class]]) {
                    [(PhonePadModel*)mainThreadResponse searchDidFinish:search_result];
                } else {
                    [mainThreadResponse performSelector:@selector(searchDidFinish:) withObject:search_result];
                }
            });
		}
	}
}
- (void)fireOnRunLoop:(CFRunLoopRef)runloop
{
    if(runloop) {
        CFRunLoopSourceSignal(runLoopSource);
        CFRunLoopWakeUp(runloop);
    }
}
- (void)addSearchKeyword:(NSString*)pSearchKeyword
{
	[keywordList addObject:pSearchKeyword];
    [self fireOnRunLoop:runLoop];
}
- (void)cleanUpKeywordList
{
	[keywordList removeAllObjects];
}
-(NSString *)lastestQueryContent{
    return [self getCurrentKeyword];
}
- (NSString*) getCurrentKeyword
{
	return [keywordList lastObject];
}
void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
}
void RunLoopSourcePerformRoutine (void *info)
{
    SearchEngineInputSource*  obj = (__bridge SearchEngineInputSource*)info;
	NSString *pString=[obj getCurrentKeyword];
    [obj sourceFired:pString];
}
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
}
@end
