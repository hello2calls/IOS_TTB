//
//  AsyncOperation.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/14.
//
//

#import "AsyncOperation.h"
#import "TPDLib.h"

@implementation AsyncOperation

+(void) asyncOperation:(BOOL (^)(void))workerBlock successHandler:(void (^)(void))successHandler failHandler:(void (^)(void))failHandler{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL ret = workerBlock();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret) {
                successHandler();
            } else {
                failHandler();
            }
        });
    });
}

+(AsyncOperation*)defaultConfig{
    AsyncOperation* ret = [[AsyncOperation alloc] init];
    
    ret.successHandler = ^(ASIWrapper* wrapper){};
    ret.failHandler = ^(ASIWrapper* wrapper){};
    
    ret.processingText = @"请稍候...";
    ret.showProcessingText = NO;
    
    ret.successText = @"请求成功";
    ret.showSuccessText = NO;
    
    ret.showFailText = YES;
    ret.failText = nil;
    
    ret.baseView = [UIView tpd_topWindow];
    return ret;
}

+(void) asyncOperationWithObject2:(AsyncOperation*)d{
    
    if (d.showProcessingText) {
        //        [MBProgressHUD showMessage:d.processingText toView:d.baseView];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        d.wrapper = d.workerBlock2();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [MBProgressHUD hideHUDForView:d.baseView];
            if (d.wrapper.success) {
                if (d.showSuccessText) {
                    //                    [MBProgressHUD showText:d.successText toView:d.baseView];
                }
                EXEC_BLOCK(d.successHandler, d.wrapper);
            } else {
                if (d.showFailText) {
                    if (d.failText != nil) {
                        // 后台未传错误信息
                        //                        [MBProgressHUD showText:d.failText toView:d.baseView];
                    }else if (d.wrapper.errInfo.length){
                        // 后台有传错误信息
                        //                        [MBProgressHUD showText:d.wrapper.errInfo toView:d.baseView];
                    }
                }
                EXEC_BLOCK(d.failHandler, d.wrapper);
            }
        });
    });
}


#pragma mark - setter
- (void)setProcessingText:(NSString *)processingText {
    if (processingText.length == 0) return;
    _processingText = processingText;
    _showProcessingText = YES;
}

- (void)setSuccessText:(NSString *)successText {
    if (successText.length == 0) return;
    _successText = successText;
    _showSuccessText = YES;
}

#pragma mark - 链式helper方法
-(AsyncOperation*)withProcessingText:(NSString*)str{
    self.processingText = str;
    return self;
}

-(AsyncOperation*)withSuccessText:(NSString*)str{
    self.successText = str;
    return self;
}

-(AsyncOperation*)withSuccessHandler:(void (^)(ASIWrapper *))success{
    self.successHandler = success;
    return self;
}

-(AsyncOperation*)withFailHandler:(void (^)(ASIWrapper *))fail{
    self.failHandler = fail;
    return self;
}

-(AsyncOperation*)withWorker:(ASIWrapper *(^)())worker{
    self.workerBlock2 = worker;
    return self;
}

-(void)run{
    [AsyncOperation asyncOperationWithASIWrapper:self];
}
@end
