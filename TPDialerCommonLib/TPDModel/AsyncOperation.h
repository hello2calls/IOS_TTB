//
//  AsyncOperation.h
//  TouchPalDialer
//
//  Created by weyl on 16/11/14.
//
//

#import <Foundation/Foundation.h>
#import "ASIWrapper.h"

@interface AsyncOperation : NSObject
@property (nonatomic,copy) BOOL (^workerBlock)(void) ;
@property (nonatomic,copy) ASIWrapper* (^workerBlock2)(void) ;
@property (nonatomic,copy) void (^successHandler)(ASIWrapper*) ;
@property (nonatomic,copy) void (^failHandler)(ASIWrapper*) ;
@property (nonatomic,strong) NSString* successText ;
@property (nonatomic,strong) NSString* failText ;
@property (nonatomic,strong) NSString* processingText ;
@property (nonatomic,strong) ASIWrapper* wrapper ;
@property (nonatomic) BOOL showSuccessText ;
@property (nonatomic) BOOL showFailText ;
@property (nonatomic) BOOL showProcessingText ;
@property (nonatomic,strong) UIView* baseView ;



+(AsyncOperation*)defaultConfig;

+(void) asyncOperation:(BOOL (^)(void))workerBlock successHandler:(void (^)(void))successHandler failHandler:(void (^)(void))failHandler;

+(void) asyncOperationWithASIWrapper:(AsyncOperation*)d;

-(AsyncOperation*)withProcessingText:(NSString*)str;
-(AsyncOperation*)withSuccessText:(NSString*)str;
-(AsyncOperation*)withSuccessHandler:(void (^)(ASIWrapper *wrapper))success;
-(AsyncOperation*)withFailHandler:(void (^)(ASIWrapper *wrapper))fail;
-(AsyncOperation*)withWorker:(ASIWrapper *(^)())worker;
-(void)run;
@end
