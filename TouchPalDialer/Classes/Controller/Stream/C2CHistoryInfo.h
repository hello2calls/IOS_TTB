//
//  C2CHistoryInfo.h
//  TouchPalDialer
//
//  Created by game3108 on 15/1/23.
//
//

#import <Foundation/Foundation.h>

@interface C2CHistoryInfo : NSObject
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, assign) NSInteger bonus;
@property (nonatomic, assign) NSInteger bonusType;
@property (nonatomic, assign) NSInteger datetime;
@property (nonatomic, assign) BOOL pop;
@property (nonatomic, copy) NSString *msg;
@end
