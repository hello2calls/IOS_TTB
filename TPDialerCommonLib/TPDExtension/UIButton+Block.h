#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

typedef void (^ActionBlock)();
@interface UIButton(Block)
@property (readonly) NSMutableDictionary *event;

- (void) addBlockEventWithEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;

@end