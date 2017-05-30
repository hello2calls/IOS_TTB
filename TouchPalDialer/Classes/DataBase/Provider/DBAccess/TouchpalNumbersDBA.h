//
//  TouchpalNumbersDBA.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-19.
//
//

#import <Foundation/Foundation.h>

@interface TouchpalNumbersDBA : NSObject
+ (NSInteger)insertNumber:(NSString *)numebr andIfCootekUser:(BOOL)ifCootekUser;
+ (NSInteger)isNumberRegistered:(NSString *)number;
+ (NSMutableDictionary *) getAllTouchPalNumbers;
@end
