//
//  HistoryModel.h
//  TouchPalDialer
//
//  Created by by.huang on 2017/7/10.
//
//

#import <Foundation/Foundation.h>

@interface HistoryModel : NSObject

@property (copy, nonatomic) NSString *phone;

@property (copy, nonatomic) NSString *paid_at;

@property (copy, nonatomic) NSString *minutes;

@property (copy, nonatomic) NSString *out_trade_no;

@property (copy, nonatomic) NSString *charged;

@property (copy, nonatomic) NSString *fee;

@end
