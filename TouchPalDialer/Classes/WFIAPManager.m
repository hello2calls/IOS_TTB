////
////  WFIAPManager.m
////  TouchPalDialer
////
////  Created by 江文帆 on 2017/6/19.
////
////
//
//#import "WFIAPManager.h"
//
//@interface SKPaymentTransaction(desc)
//
//@end
//
//@implementation SKPaymentTransaction(desc)
//
//- (NSString *)description {
//    return [NSString stringWithFormat:@"transaction %@ time:%@ state:%ld", self.transactionIdentifier, self.transactionDate, (long)self.transactionState];
//}
//
//@end
//
//
//@implementation WFIAPOrder
//
//@end
//
//@interface WFIAPManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate>
//@property (nonatomic, assign) BOOL isPurchasing;
//@property (nonatomic, copy) WFIAPSuccessBlock successBlock;
//@property (nonatomic, copy) WFIAPFailureBlock failureBlock;
//@property (nonatomic, copy) WFIAPReceiptBlock receiptBlock;
//
//@property (nonatomic, copy) WFIAPRestoreBlock restoreBlock;
//@property (nonatomic, copy) WFIAPRestoreCompleteBlock restoreCompleteBlock;
//@property (nonatomic, copy) WFIAPRestoreFailureBlock restoreFailedBlock;
//
//@property (nonatomic, strong) NSArray<SKProduct *> *products;
//@end
//
//@implementation WFIAPManager
//SINGLETON_IMPLEMENTION(WFIAPManager)
//
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    }
//    return self;
//}
//
//- (void)purchaseWithProductId:(NSString *)productId
//                   success:(WFIAPSuccessBlock)successBlock
//                   receipt:(WFIAPReceiptBlock)receiptBlock
//                   failure:(WFIAPFailureBlock)failureBlock
//{
//    if (self.isPurchasing) {
//        return;
//    }
//    self.isPurchasing = YES;
//    
//    self.successBlock = successBlock;
//    self.receiptBlock = receiptBlock;
//    self.failureBlock = failureBlock;
//    
//    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
//    request.delegate = self;
//    [request start];
//}
//
//- (void)restoreForEachTransaction:(WFIAPRestoreBlock)restoreBlock
//                         complete:(WFIAPRestoreCompleteBlock)completeBlock
//                          failure:(WFIAPRestoreFailureBlock)failureBlock
//{
//    self.restoreBlock = restoreBlock;
//    self.restoreCompleteBlock = completeBlock;
//    self.restoreFailedBlock = failureBlock;
//    
//    
//    if (![SKPaymentQueue canMakePayments]) {
//        NSError *error = [NSError errorWithDomain:SKErrorDomain code:WFIAPErrorNoPermission userInfo:nil];
//        self.restoreFailedBlock?self.restoreFailedBlock(error):nil;
//        self.isPurchasing = NO;
//    }else {
//        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
//    }
//}
//
//- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
//{
//    self.products = response.products;
//    if (!self.successBlock) {
//        NSError *error = [NSError errorWithDomain:SKErrorDomain code:WFIAPErrorParamsError userInfo:@{NSLocalizedDescriptionKey:@"未设置successBlock"}];
//        self.failureBlock?self.failureBlock(error):nil;
//        self.isPurchasing = NO;
//        return;
//    }
//    [self purchase:self.successBlock()];
//}
//
//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
//{
//    for (SKPaymentTransaction *transaction in transactions) {
//        switch (transaction.transactionState) {
//            case SKPaymentTransactionStatePurchasing:
//            {
////                NSError *error = [NSError errorWithDomain:SKErrorDomain code:WFIAPErrorPurchasing userInfo:@{NSLocalizedDescriptionKey:@"上一笔订单尚未完成，本次不会扣款，请重启App尝试恢复上一次订单"}];
////                self.failureBlock(error);
////                self.isPurchasing = NO;
//            }
//                break;
//            case SKPaymentTransactionStatePurchased:
//            {
//                NSURL *receiptUrl = [NSBundle mainBundle].appStoreReceiptURL;
//                NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
//                if (!receiptData) {
//                    NSError *error = [NSError errorWithDomain:SKErrorDomain code:WFIAPErrorNoReceipt userInfo:nil];
//                    self.failureBlock(error);
//                    self.isPurchasing = NO;
//                    return;
//                }
//                NSString *receiptString = [receiptData base64EncodedStringWithOptions:0];
//                
//                if (self.receiptBlock) {
//                    self.receiptBlock(receiptString, transaction, queue);
//                }else {
//                    if (self.unFinishedTransactionBlock) {
//                        self.unFinishedTransactionBlock(receiptString, transaction.originalTransaction?:transaction, queue);
//                    }
//                }
//                self.isPurchasing = NO;
//            }
//                break;
//            case SKPaymentTransactionStateFailed:
//            {
//                if (self.failureBlock) {
//                    self.failureBlock(transaction.error);
//                }
//                [queue finishTransaction:transaction];
//                self.isPurchasing = NO;
//            }
//                break;
//            case SKPaymentTransactionStateRestored:
//            {
//                if (self.restoreBlock) {
//                    self.restoreBlock(transaction, queue);
//                }
//            }
//                break;
//            case SKPaymentTransactionStateDeferred:
//            {
//                if (self.failureBlock) {
//                    NSError *error = [NSError errorWithDomain:SKErrorDomain code:WFIAPErrorDeferred userInfo:nil];
//                    self.failureBlock(error);
//                }
//                self.isPurchasing = NO;
//            }
//                break;
//        }
//    }
//}
//
//- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
//{
//    for(SKPaymentTransaction *transaction in transactions) {
//        NSLog(@"payment queue now remove %@", transaction);
//    }
//}
//
//- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
//{
//    if (self.restoreFailedBlock) {
//        self.restoreFailedBlock(error);
//    }
//    self.isPurchasing = NO;
//}
//
//- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
//{
//    if (self.restoreCompleteBlock) {
//        self.restoreCompleteBlock(queue.transactions);
//    }
//    self.isPurchasing = NO;
//}
//
//- (void)purchase:(WFIAPOrder *)order
//{
//    __block SKProduct *validProduct = nil;
//    [self.products enumerateObjectsUsingBlock:^(SKProduct * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj.productIdentifier isEqualToString:order.productIdentifier]) {
//            validProduct = obj;
//            *stop = YES;
//        }
//    }];
//    
//    if (!validProduct) {
//        NSError *error = [NSError errorWithDomain:SKErrorDomain code:WFIAPErrorNoExist userInfo:nil];
//        self.failureBlock(error);
//        self.isPurchasing = NO;
//    }else {
//        if (![SKPaymentQueue canMakePayments]) {
//            NSError *error = [NSError errorWithDomain:SKErrorDomain code:WFIAPErrorNoPermission userInfo:nil];
//            self.failureBlock(error);
//            self.isPurchasing = NO;
//        }else {
//            SKMutablePayment *paymentRequest = [SKMutablePayment paymentWithProduct:validProduct];
//            paymentRequest.applicationUsername = order.applicationUserName;
//            [[SKPaymentQueue defaultQueue] addPayment:paymentRequest];
//        }
//    }
//}
//@end
