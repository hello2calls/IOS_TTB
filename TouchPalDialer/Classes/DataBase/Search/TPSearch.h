//
//  TPSearch.h
//  TouchPalDialer
//
//  Created by lingmei xie on 12-12-3.
//
//

#import <Foundation/Foundation.h>
#import "SearchResultModel.h"

@interface NSMutableArray (HandleNilArray)

- (void)insertObjectsFromArray:(NSArray *)otherArray;

@end

@interface NSString (HandleQueryContent)

- (BOOL)isContentLetter;

- (NSRange)isContainString:(NSString *)target;

- (BOOL)isQueryName;

@end

@protocol TPSearchDataSource

- (NSString *)lastestQueryContent;

@end

@protocol TPSearchDelegate

@property(nonatomic,assign) id<TPSearchDataSource> dataSource;

- (NSArray *)query:(NSString *)content;

- (BOOL)isExcuteQuery:(NSString *)content
                count:(NSInteger)count;

- (SearchResultModel *)wrapResults:(NSArray *)records
                         serachKey:(NSString *)key;

- (SearchResultModel *)wrapResults:(NSArray *)records
                         serachKey:(NSString *)key
                        searchType:(SearchType)type;
@end

@interface TPDefaultSearch : NSObject<TPSearchDelegate>

-(NSArray *)completeQuery:(NSArray *)records;

-(NSArray *)removeRepeatRecord:(NSArray *)records;

@end


@interface TPCalllogSearch : TPDefaultSearch

@end

@interface TPNumberSearch : TPDefaultSearch

@end

@interface TPNameSearch : TPDefaultSearch

- (BOOL)isOnlyNumberContact;

@end

@interface TPContactNameSearch : TPNameSearch

@end

@interface TPGestureNameSearch : TPDefaultSearch

@end

@interface TPDailNameSearch : TPNameSearch

@end

@interface TPT9NameSearch : TPDailNameSearch

@end

@interface TPQwertyNameSearch : TPDailNameSearch

@end

@interface TPAttributeSearch : TPDefaultSearch

@end
