//
//  TPContactSeach.m
//  TouchPalDialer
//
//  Created by lingmei xie on 12-12-10.
//
//

#import "TPContactSeach.h"

@interface TPContactSeach(){
    NSMutableArray *searchObjects_;
}
@end
@implementation TPContactSeach

@synthesize dataSource = dataSource_;

- (id)init
{
    self =[super init];
    if (self) {
        searchObjects_ = [[NSMutableArray alloc] initWithCapacity:3];
        
        @synchronized (searchObjects_) {
            TPDefaultSearch *search = [[TPContactNameSearch alloc] init];
            [searchObjects_ addObject:search];
            
            search = [[TPNameSearch alloc] init];
            [searchObjects_ addObject:search];
            
            search = [[TPNumberSearch alloc] init];
            [searchObjects_ addObject:search];
            
            search = [[TPAttributeSearch alloc] init];
            [searchObjects_ addObject:search];
        }

    }
    return self;
}

- (void)setDataSource:(id<TPSearchDataSource>)dataSource
{
    dataSource_ = dataSource;
    TPDefaultSearch *search = [searchObjects_ lastObject];
    search.dataSource = dataSource_;
}

- (BOOL)validateQuery:(NSString *)content
{
    NSString *current = [self.dataSource lastestQueryContent];
    if (![current isEqualToString:current]||[content length] ==0) {
        return NO;
    }
    return YES;
}

- (NSArray *)query:(NSString *)content
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
    NSArray *tmpSearch = nil;
    @synchronized (searchObjects_) {
        tmpSearch = [NSArray arrayWithArray:searchObjects_];
    }
    
    for (TPDefaultSearch *search in tmpSearch) {
        if (![self validateQuery:content]) {
            return nil;
        }
        if ([search isExcuteQuery:content count:[results count]]) {
            [results insertObjectsFromArray:[search query:content]];
        }
    }
    return [self removeRepeatRecord:results];
}

- (SearchResultModel *)wrapResults:(NSArray *)records
                         serachKey:(NSString *)key
{
    return [self wrapResults:records
                   serachKey:key
                  searchType:ContactSearch];
}
@end

@implementation TPContactPickerSeach

- (SearchResultModel *)wrapResults:(NSArray *)records
                        serachKey:(NSString *)key
{
    return [self wrapResults:records
                   serachKey:key
                  searchType:PickerSearch];
}
@end
