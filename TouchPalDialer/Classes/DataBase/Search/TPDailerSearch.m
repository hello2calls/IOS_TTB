//
//  TPDailerSearch.m
//  TouchPalDialer
//
//  Created by lingmei xie on 12-12-4.
//
//

#import "TPDailerSearch.h"
#import "TPQueryCallog.h"


@interface TPDailerSearch(){
    NSMutableArray *searchObjects_;
    TPQueryCallogDefault *calllogQuery_;
    TPDailNameSearch *nameSearch_;
}
@end

@implementation TPDailerSearch

- (id)initWithKeyBoard:(DailerKeyBoardType)keyboradType
               calllog:(CalllogFilterType)calllogType
{
    self =[super init];
    if (self) {
        calllogQuery_ = nil;
        nameSearch_ = nil;

        
        searchObjects_ = [[NSMutableArray alloc] initWithCapacity:3];
        
        @synchronized (searchObjects_) {
            TPDefaultSearch *search = [[TPNumberSearch alloc] init];
            [searchObjects_ addObject:search];
            
            search = [[TPCalllogSearch alloc] init];
            [searchObjects_ addObject:search];
        }
        
        [self setKeyBoradType:keyboradType];
        [self setTPQueryCallog:calllogType];
    }
    return self;
}

- (void)setKeyBoradType:(DailerKeyBoardType)type
{
    if (searchObjects_ ) {
        @synchronized (searchObjects_) {
            if (nameSearch_) {
                [searchObjects_ removeObjectAtIndex:0];
                nameSearch_ = nil;
            }
            switch (type) {
                case QWERTYBoardType:
                    nameSearch_ = [[TPQwertyNameSearch alloc] init];
                    break;
                case T9KeyBoardType:
                    nameSearch_ = [[TPT9NameSearch alloc] init];
                    break;
                default:
                    break;
            }
            [searchObjects_ insertObject:nameSearch_ atIndex:0];
        }
    }
}

- (void)setTPQueryCallog:(CalllogFilterType)type
{
    cootek_log_function;
    if (calllogQuery_ != nil) {
        calllogQuery_ = nil;
    }
    calllogQuery_ = [TPQueryCallogDefault createQueryCalllogObject:type];
}

- (BOOL)validateQuery:(NSString *)content
{
    NSString *current = [self.dataSource  lastestQueryContent];
    if (![current isEqualToString:current]) {
        return NO;
    }
    return YES;
}

- (NSArray *)query:(NSString *)content
{
    if ([content length] == 0) {
        return [calllogQuery_ queryCallog];
    }else{
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
                NSArray * res = [search query:content];
                //cootek_log(@"%d", [res count]);
                [results insertObjectsFromArray:res];
            }
        }
        return [self removeRepeatRecord:results];
    }
}

- (SearchResultModel *)wrapResults:(NSArray *)records
                        serachKey:(NSString *)key
{
    return [self wrapResults:records serachKey:key searchType:DialSearch];
}
@end
