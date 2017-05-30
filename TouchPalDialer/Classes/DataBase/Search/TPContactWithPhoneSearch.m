//
//  TPContactWithPhoneSearch.m
//  TouchPalDialer
//
//  Created by lingmei xie on 12-12-10.
//
//

#import "TPContactWithPhoneSearch.h"

@interface TPContactWithPhoneSearch(){
    NSMutableArray *searchObjects_;
}
@end
@implementation TPContactWithPhoneSearch

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
            NSArray *tmpresults = [search completeQuery:[search query:content]];
            [results insertObjectsFromArray:tmpresults];
        }
    }
    return [self removeRepeatRecord:results];
}

-(SearchResultModel *)wrapResults:(NSArray *)records
                        serachKey:(NSString *)key
{
    return [self wrapResults:records
                   serachKey:key
                  searchType:ContactWithPhoneSearch];
}

-(NSArray *)removeRepeatRecord:(NSArray *)records
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:1];
    for (SearchItemModel *item in records) {
        if (item.personID > 0) {
            NSString *key = [NSString stringWithFormat:@"%d", item.personID];
            SearchItemModel *tmpItem = [resultDic objectForKey:key];
            if (!tmpItem) {
                [results addObject:item];
                [resultDic setObject:item forKey:key];
            }
        }else{
            [results addObject:item];
        }
    }
    return results;
}
@end
