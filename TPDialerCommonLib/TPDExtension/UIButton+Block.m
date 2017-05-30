#import "UIButton+Block.h"

@implementation UIButton(Block)

static char overviewKey;
@dynamic event;

- (void)addBlockEventWithEvent:(UIControlEvents)event withBlock:(ActionBlock)block {
    id previousBlock = objc_getAssociatedObject(self, &overviewKey);
    objc_removeAssociatedObjects(previousBlock);
    objc_setAssociatedObject(self, &overviewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActBlock:) forControlEvents:event];
}

- (void)callActBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, &overviewKey);
    if (block) {
        block();
    }
}

@end
