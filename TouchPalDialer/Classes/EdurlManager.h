//
//  EdurlManager.h
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 15/12/18.
//
//

#ifndef EdurlManager_h
#define EdurlManager_h
#import "FindNewsItem.h"
#import "IndexConstant.h"

@interface EdurlManager : NSObject

+ (id) instance;
- (void) requestEdurl:(NSArray*)edurlArray;
- (void) addNewsRecord:(NSIndexPath *)indexPath andNewsInfo:(FindNewsItem*)newsInfo;
- (void)removeNewsRecord:(UITableView *)tableView tu:(NSString *)tu;
- (void) removeAllNewsRecordWithCloseType:(CTCloseType)closeType;
- (void) clear;
- (void) sendCMonitorUrl:(BaseItem*) item;


@end

#endif /* EdurlManager_h */
