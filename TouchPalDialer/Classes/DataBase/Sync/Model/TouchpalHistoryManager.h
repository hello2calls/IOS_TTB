//
//  TouchpalHistoryManager.h
//  TouchPalDialer
//
//  Created by game3108 on 15/1/26.
//
//

#import <Foundation/Foundation.h>
#import "C2CHistoryInfo.h"

@interface TouchpalHistoryManager : NSObject
@property (nonatomic, strong) NSMutableArray *touchpalHistoryCacheArray;
- (void)loadArrayWithBonusType:(NSInteger)bonusType;
+ (BOOL)insertHistory:(C2CHistoryInfo *)info;
+ (NSInteger)getLatestDatetime:(NSInteger)bonusType;
+ (void)deleteAllData;
@end
