//
//  DefaultUIAlertViewHandler.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultUIAlertViewHandler : NSObject<UIAlertViewDelegate>

+ (void) showAlertViewWithTitle:(NSString*)title
                        message:(NSString*)message
                    cancelTitle:(NSString*)cancelTitle
                        okTitle:(NSString*)okTitle
            okButtonActionBlock:(void (^)(void))actionBlock;

+ (void) showAlertViewWithTitle:(NSString*)title
                        message:(NSString*)message
                    cancelTitle:(NSString*)cancelTitle
                        okTitle:(NSString*)okTitle
            okButtonActionBlock:(void (^)(void))actionBlock
              cancelActionBlock:(void (^)(void))cancelBlock;

+ (void) showAlertViewWithTitle:(NSString*)title message:(NSString*)message okButtonActionBlock:(void (^)(void))actionBlock;

+ (void) showAlertViewWithTitle:(NSString *)title message:(NSString *)message onlyOkButtonActionBlock:(void (^)(void))actionBlock;

+ (void) showAlertViewWithTitle:(NSString *)title
                        message:(NSString *)message
                        okTitle:(NSString*)okTitle
        onlyOkButtonActionBlock:(void (^)(void))actionBlock;

+ (void) showAlertViewWithTitle:(NSString*)title
                        message:(NSString*)message
            okButtonActionBlock:(void (^)(void))actionBlock
              cancelActionBlock:(void (^)(void))cancelBlock;

+ (void) showAlertViewWithTitle:(NSString *)title message:(NSString *)message;

+ (void) showAlertViewWithTitle:(NSString *)title message:(NSString *)message dismissIn:(NSTimeInterval)seconds;

@end
