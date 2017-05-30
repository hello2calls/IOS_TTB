//
//  TouchpalHistoryDBA.h
//  TouchPalDialer
//
//  Created by game3108 on 15/1/26.
//
//

#import <Foundation/Foundation.h>
#import "C2CHistoryInfo.h"

@interface TouchpalHistoryDBA : NSObject
+ (BOOL)insertHistory:(C2CHistoryInfo *)info;
+ (NSMutableArray *) getAllTouchpalHistory:(NSInteger)bonusType;
+ (NSInteger)getLatestDatetime:(NSInteger)bonusType;
+ (void)deleteAllData;
@end
