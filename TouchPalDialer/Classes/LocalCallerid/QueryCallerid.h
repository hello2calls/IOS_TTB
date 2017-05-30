//
//  QueryCallerid.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//

#import <Foundation/Foundation.h>
#import "QueryResult.h"
#import "BaseDB.h"
#import "CallerIDInfoModel.h"

@interface QueryCallerid : NSObject

@property (nonatomic, retain) BaseDB *nationDB;
@property (nonatomic, retain) BaseDB *nationUpDB;
@property (nonatomic, retain) BaseDB *tagDB;
@property (nonatomic, copy) NSString *nationId;
@property (nonatomic, copy) NSString *nationUpId;
@property (nonatomic, copy) NSString *tagId;

+ (QueryCallerid*)shareInstance;

- (CallerIDInfoModel*) getLocalCallerid:(NSString*)number;
- (void)checkUpdate;
- (NSString*)longToString:(long)number;

@end
