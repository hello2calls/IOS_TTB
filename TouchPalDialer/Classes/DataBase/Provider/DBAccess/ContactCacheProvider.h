//
//  ContactCacheProvider.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-26.
//
//

#import <Foundation/Foundation.h>

#define MAX_NUMBER_COUNT_CONTACT_IN_DB 500

@interface ContactCacheProvider : NSObject

+ (NSArray *)allCacheConacts;

+ (void)insertContactCacheData:(NSArray *)contacts;

@end
