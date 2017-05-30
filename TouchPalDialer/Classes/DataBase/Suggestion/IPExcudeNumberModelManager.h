//
//  IPExcudeNumberModelManager.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//

#import <Foundation/Foundation.h>

@interface IPExcudeNumberModelManager : NSObject

+ (IPExcudeNumberModelManager *)sharedManager;

- (void)addItemsToExcludedList:(NSArray *)items;

- (void)removeItemFromExcludedList:(NSString *)item;

- (NSArray *)getPersonListThatIsNotInExcludedList;

- (BOOL)isThisNumberExcludedFromSmartDial:(NSString *)number;

- (NSArray *)getExcludedFromSmartDialPersonList;

@end
