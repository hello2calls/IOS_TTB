//
//  ContactSearchModel.m
//  TouchPalDialer
//
//  Created by Alice on 11-12-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactSearchModel.h"
#import "CootekNotifications.h"
#import "TPGestureSearch.h"
#import "TPContactWithPhoneSearch.h"

@interface ContactSearchModel(){
	SearchEngineThread  *searchEngineThread_;
    SearchType seachtype_;
}
@end

@implementation ContactSearchModel

- (id)initWithSearchType:(SearchType)type
{
    self =[super init];
    if (self) {
        seachtype_ = type;
        [self initSearchEngine];
    }
    return self;
}
- (void)searchDidFinish:(SearchResultModel *)tmpResult
{
	[[NSNotificationCenter defaultCenter] postNotificationName:N_CONTACT_SEARCH_RESULT_CHANGED
														object:nil
													  userInfo:[NSDictionary dictionaryWithObject:tmpResult
                                                                                           forKey:KEY_RESULT_LIST_CHANGED]];
}
- (void)query:(NSString *)content
{
	if ([content length]>0) {
		[searchEngineThread_ addQueryContent:content];
	}else {
		[searchEngineThread_ cleanAllContent];
	}
}
- (TPDefaultSearch *)createSearchEngine
{
    TPDefaultSearch *searchEngine_ = nil;
    switch (seachtype_) {
        case GestureSearch:
            searchEngine_ = [[TPGestureSearch alloc] init];
            break;
        case ContactSearch:
            searchEngine_ = [[TPContactSeach alloc] init];
            break;
        case PickerSearch:
            searchEngine_ = [[TPContactPickerSeach alloc] init];
            break;
        case ContactWithPhoneSearch:
            searchEngine_ = [[TPContactWithPhoneSearch alloc] init];
        default:
            break;
    }
    return searchEngine_;
}

- (void)initSearchEngine
{
    TPDefaultSearch *searchEngine = [self createSearchEngine];
    searchEngineThread_ = [[SearchEngineThread alloc] initWithEngine:searchEngine
                                                             respone:self];
    [searchEngineThread_ start];
}
- (void)dealloc
{
    [searchEngineThread_ stopRunLoop];
}
@end
