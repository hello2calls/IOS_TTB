////
////  WFIAPManager.h
////  TouchPalDialer
////
////  Created by 江文帆 on 2017/6/19.
////
////
//
//#import <Foundation/Foundation.h>
//#import <StoreKit/StoreKit.h>
//
//typedef NS_ENUM(NSUInteger, WFIAPError) {
//    
//    //SKErrorDomain
//    WFIAPErrorUnknown = SKErrorUnknown,
//    WFIAPErrorClientInvalid = SKErrorClientInvalid,
//    WFIAPErrorPaymentCancelled = SKErrorPaymentCancelled,
//    WFIAPErrorPaymentInvalid = SKErrorPaymentInvalid,
//    WFIAPErrorPaymentNotAllowed = SKErrorPaymentNotAllowed,
//    WFIAPErrorStoreProductNotAvailable = SKErrorStoreProductNotAvailable,
//    //内购Id不匹配
//    WFIAPErrorMissMatching = 101,
//    //没有传入successBlock
//    WFIAPErrorParamsError,
//    /// 没有内购许可
//    WFIAPErrorNoPermission,
//    /// 不存在该商品: 商品未在appstore中\商品已经下架
//    WFIAPErrorNoExist,
//    /// 交易结果未成功
//    WFIAPErrorFailTransactions,
//    /// 交易成功但未找到成功的凭证
//    WFIAPErrorNoReceipt,
//    // 恢复购买失败
//    WFIAPErrorRestoreFailed,
//    // 等待家长控制
//    WFIAPErrorDeferred,
//    //上一笔订单还未完成，不会扣款
//    WFIAPErrorPurchasing
//};
//
//@class WFIAPOrder;
//typedef WFIAPOrder *(^WFIAPSuccessBlock)();
//typedef void(^WFIAPFailureBlock)(NSError *error);
//typedef void(^WFIAPRestoreBlock)(SKPaymentTransaction *transaction, SKPaymentQueue *queue);
//typedef void(^WFIAPRestoreCompleteBlock)(NSArray *transactions);
//typedef void(^WFIAPRestoreFailureBlock)(NSError *error);
//typedef void(^WFIAPReceiptBlock)(NSString *receipt, SKPaymentTransaction *transaction, SKPaymentQueue *queue);
//
//
//@interface WFIAPOrder : NSObject
//@property (nonatomic, copy) NSString *productIdentifier;
//@property (nonatomic, copy) NSString *applicationUserName;
//@end
//
//
//@interface WFIAPManager : NSObject
//SINGLETON_DECLARATION(WFIAPManager)
//
///**
// 在App启动时配置此block,用于恢复用户付款但未完成验证的订单
// */
//@property (nonatomic, copy) WFIAPReceiptBlock unFinishedTransactionBlock;
//
///**
// 发起内购
//
// @param productId iTunes后台创建的商品Id
// @param successBlock 发起内购请求成功的回调，在此block中创建并返回一个 WFIAPOrder 对象，用于记录该笔订单在开发者服务器的唯一ID或者对应唯一用户
// @param receiptBlock 验证发票的回调，在此block中对该笔transaction进行服务器验证，验证结束后调用 - finishTransaction:
// @param failureBlock 购买失败的回调
// */
//- (void)purchaseWithProductId:(NSString *)productId
//                   success:(WFIAPSuccessBlock)successBlock
//                   receipt:(WFIAPReceiptBlock)receiptBlock
//                   failure:(WFIAPFailureBlock)failureBlock;
//
//
///**
// 恢复购买，用于非消耗型内购的恢复
//
// @param restoreBlock 应在此block中对该笔transaction进行服务器验证，验证结束后调用 - finishTransaction:
// @param completeBlock 全部订单恢复完毕的回调
// @param failureBlock 恢复失败的回调
// */
//- (void)restoreForEachTransaction:(WFIAPRestoreBlock)restoreBlock
//                         complete:(WFIAPRestoreCompleteBlock)completeBlock
//                          failure:(WFIAPRestoreFailureBlock)failureBlock;
//@end
