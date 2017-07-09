////
////  TPDInAppPurchase.m
////  TouchPalDialer
////
////  Created by 江文帆 on 2017/6/20.
////
////
//
//#import "TPDInAppPurchase.h"
//#import "WFIAPManager.h"
//#import "IndexConstant.h"
//#import "FunctionUtility.h"
//#import "NSString+MD5.h"
//#import "DateTimeUtil.h"
//#import "TPHttpRequest.h"
//#import "TouchPalVersionInfo.h"
//#import "SeattleFeatureExecutor.h"
//#import "UserDefaultsManager.h"
//#import "TPChargeUtil.h"
//#import <MJExtension.h>
//#define TPD_IAP_PURCHASE_PRODUCT_ID_TEST @"com.cootek.Contacts.coin.test1"
//
//#define TPD_IAP_USE_DEBUG YES
//
//
//#define TPD_IAP_REQUEST_URL_PRO @"http://open.cootekservice.com"
//#define TPD_IAP_REQUEST_URL_DEBUG @"http://121.52.235.231:40027"
//
//#define TPD_IAP_REQUEST_URL (TPD_IAP_USE_DEBUG ? TPD_IAP_REQUEST_URL_DEBUG : TPD_IAP_REQUEST_URL_PRO)
//
//
//@interface TPDIAPData : NSObject
//@property (nonatomic, copy) NSString *accountID;
//@property (nonatomic, copy) NSString *transactionID;
//@property (nonatomic, copy) NSString *receipt;
//@end
//@implementation TPDIAPData
//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"<TPDIAPData %p> accountId : %@ transactionID : %@",self,self.accountID,self.transactionID];
//}
//@end
//
//
//@implementation TPDInAppPurchase
//
//+ (void)start
//{
//    [self handleUnFinishedTransactions];
//}
//
//+ (void)purchaseWithProductId:(NSString *)productId orderId:(NSString *)orderId complete:(TPDBooleanResultBlock)complete
//{
//    [[WFIAPManager sharedWFIAPManager] purchaseWithProductId:productId
//                                                     success:^WFIAPOrder *{
//        WFIAPOrder *order = [WFIAPOrder new];
//        order.productIdentifier = productId;
//        order.applicationUserName = orderId;
//        return order;
//    } receipt:^(NSString *receipt, SKPaymentTransaction *transaction, SKPaymentQueue *queue) {
//        TPDIAPData *data = [TPDIAPData new];
//        data.accountID = transaction.payment.applicationUsername;
//        data.receipt = receipt;
//        data.transactionID = transaction.transactionIdentifier;
//        NSLog(@"IAP -- %@",data);
//        
//        [self validateReceiptWithData:data complete:^(BOOL finished, NSError *error) {
//            if (finished) {
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                NSLog(@"购买成功");
//            }else {
//                NSLog(@"验证您的购买信息失败，请稍后重试");
//            }
//            complete?complete(finished,error):nil;
//        }];
//    } failure:^(NSError *error) {
//        NSString *message = [self messageWithError:error];
//        if (message) {
//            NSLog(message);
//        }
//        complete?complete(NO,error):nil;
//    }];
//}
//
//+ (void)handleUnFinishedTransactions
//{
//    [WFIAPManager sharedWFIAPManager].unFinishedTransactionBlock = ^(NSString *receipt, SKPaymentTransaction *transaction, SKPaymentQueue *queue) {
//        TPDIAPData *data = [TPDIAPData new];
//        data.accountID = transaction.payment.applicationUsername;
//        data.receipt = receipt;
//        data.transactionID = transaction.transactionIdentifier;
//        
//        NSLog(@"IAP -- %@",data);
//        
//        [self validateReceiptWithData:data complete:^(BOOL finished, NSError *error) {
//            if (finished) {
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//            }
//        }];
//    };
//}
//
//#define TPD_IAP_ERRORC_CODE_VALIDATE_FAILED 4010
//#define TPD_IAP_ERRORC_CODE_TIMEOUT 4020
//+ (void)validateReceiptWithData:(TPDIAPData *)data complete:(TPDBooleanResultBlock)completeBlock
//{
//    NSDictionary *params = @{
//                             @"order_id":data.accountID?:@"",
//                             @"iap_transaction_id":data.transactionID?:@"",
//                             @"receipt":data.receipt?:@"",
//                             };
//    
//    NSData *paramsData=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *content=[[NSString alloc]initWithData:paramsData encoding:NSUTF8StringEncoding];
//    
//    [[TPHttpRequest sharedTPHttpRequest] post:TPD_IAP_REQUEST_URL content:content success:^(id respondObj) {
//        completeBlock(YES, nil);
//    } fail:^(id respondObj, NSError *error) {
//        completeBlock(NO, error);
//    }];
//}
//
///*
// NSDictionary *requestBody = @{
// @"skill_id":params[@"skill_id"],
// @"service_time":params[@"service_time"],
// @"service_num":params[@"service_num"],
// @"content":params[@"content"],
// @"trade_str":tradeString,
// @"product_id":@"coin_001"
// };
// */
//+ (void)createOrderWithParams:(NSDictionary *)params productId:(NSString *)productId complete:(TPDBooleanResultBlock)complete
//{
//    NSString *tradeStr = [NSString stringWithFormat:@"{\"paymentType\":\"iap\",\"authToken\":\"%@\"}",[SeattleFeatureExecutor getToken]];
//    tradeStr = [[tradeStr dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
//    
//    NSString *customRequestStr = [NSString stringWithFormat:@"{\"trade_str\":\"%@\",\"plan\":\"%@\"}",tradeStr,productId];
//    
//    
//    
//    NSString *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
//    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
//    [jsonDic setObject:customRequestStr forKey:@"custom_request"];
//    [jsonDic setObject:accountName forKey:@"phone"];
//    [jsonDic setObject:@"iap" forKey:@"pay_type"];
//    [jsonDic setObject:@"v1.3" forKey:@"pay_version"];
//    [jsonDic setObject:@"13" forKey:@"module_id"];
//    [jsonDic setObject:tradeStr forKey:@"trade_str"];
//    [jsonDic setObject:IPHONE_CHANNEL_CODE forKey:@"channel_code"];
//    
//    
//    NSString *url = @"http://121.52.250.39:30007/voip/ttbpay_trade_request";
//    [[TPHttpRequest sharedTPHttpRequest]post:url content:[TPChargeUtil transformJson:jsonDic] success:^(id respondObj) {
//        NSData *data = respondObj;
//        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//        NSDictionary *resDic  = [resultDic objectForKey:@"result"];
//        NSDictionary *res1Dic = [resDic objectForKey:@"result"];
//        
//        NSData *payData = [[NSData alloc] initWithBase64EncodedString:[res1Dic objectForKey:@"payStr"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
//        NSString *payStr =[[NSString alloc] initWithData:payData encoding:NSUTF8StringEncoding];
//        NSDictionary *payStrJson = [payStr mj_JSONObject];
//        NSDictionary *paymentData = [payStrJson[@"paymentData"] mj_JSONObject];
//        NSString *orderId = paymentData[@"order_id"];
//        NSString *productId = paymentData[@"product_id"];
//        
//        [self purchaseWithProductId:@"ttb_100" orderId:orderId complete:complete];
//    
//    } fail:^(id respondObj, NSError *error) {
//        
//    }];
//}
//
//+ (NSString *)messageWithError:(NSError *)error
//{
//    NSString *message = nil;
//    switch (error.code) {
//        case SKErrorPaymentCancelled:
//            message = NSLocalizedString(@"Payment Canceled", nil);
//            break;
//        case SKErrorPaymentNotAllowed:
//            message = NSLocalizedString(@"Payment Not Allowed", nil);
//            break;
//        case SKErrorClientInvalid:
//            message = NSLocalizedString(@"Client Invalid", nil);
//            break;
//        case SKErrorPaymentInvalid:
//            message = NSLocalizedString(@"Payment Invalid", nil);
//            break;
//        case SKErrorStoreProductNotAvailable:
//            message = NSLocalizedString(@"Product Not Available", nil);
//            break;
//        case SKErrorUnknown:
//            message = error.userInfo[NSLocalizedDescriptionKey];
//            break;
//        case WFIAPErrorMissMatching:
//            message = NSLocalizedString(@"内购ID出现异常", nil);
//            break;
//        case WFIAPErrorNoPermission:
//            message = NSLocalizedString(@"您的AppleId无法购买,请联系苹果公司", nil);
//            break;
//        case WFIAPErrorNoExist:
//            message = NSLocalizedString(@"商品信息不存在", nil);
//            break;
//        case WFIAPErrorFailTransactions:
//            message = NSLocalizedString(@"购买失败", nil);
//            break;
//        case WFIAPErrorNoReceipt:
//            message = NSLocalizedString(@"发票信息异常", nil);
//            break;
//        case WFIAPErrorRestoreFailed:
//            message = NSLocalizedString(@"恢复购买失败", nil);
//            break;
//        case WFIAPErrorDeferred:
//            message = nil;
//            break;
//        default:
//            message = error.userInfo[NSLocalizedDescriptionKey];
//            break;
//    }
//    
//    return message;
//}
//
//@end
