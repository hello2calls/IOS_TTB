//
//  YPTask.h
//  TouchPalDialer
//
//  Created by tanglin on 15/9/2.
//
//

#import <Foundation/Foundation.h>

#define TYPE_PUSH 1
#define TYPE_POP 2

@interface YPNavigationTask : NSObject

@property(nonatomic, assign)NSInteger type;
@property(nonatomic, strong)UIViewController *viewController;
@end
