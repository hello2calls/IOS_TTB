//
//  AlipayController.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-1.
//
//

@interface AlipayController: NSObject
+ (AlipayController *)instance;

- (void) sendPay:(NSDictionary*) data callbackBlock:(void(^)(NSDictionary*))payBackAction;

- (BOOL)handleResultDic:(NSDictionary *)result;



@end