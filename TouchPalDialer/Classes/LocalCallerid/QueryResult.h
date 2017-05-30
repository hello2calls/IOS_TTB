//
//  QueryResult.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//

#import <Foundation/Foundation.h>

#define CALLERID_TAG_NORMAL 1
#define CALLERID_TAG_SALES 5
#define CALLERID_TAG_CRANK 10
#define CALLERID_TAG_FRAUD 11

@interface QueryResult : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, assign) NSInteger tagIndex;
@property (nonatomic, copy) NSString *normalizedNumber;
@property (nonatomic, copy) NSString *originNumber;

@end
