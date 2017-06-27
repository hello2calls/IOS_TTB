//
//  TouchpalHttpRequest.h
//  demo
//
//  Created by by.huang on 2017/2/6.
//  Copyright © 2017年 by.huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPHttpRequest : NSObject

SINGLETON_DECLARATION(TPHttpRequest)

typedef void(^SuccessCallback)(id respondObj);

typedef void(^FailCallback)(id respondObj,NSError *error);

-(void) get : (NSString *)url parameters : (NSMutableDictionary *)parameters
    success : (SuccessCallback)success fail : (FailCallback)fail;


-(void) post : (NSString *)url content : (NSString *)jsonStr
     success : (SuccessCallback)success fail : (FailCallback)fail;



@end
