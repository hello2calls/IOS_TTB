//
//  TPBottomBar.m
//  TouchPalDialer
//
//  Created by tanglin on 15-8-11.
//
//

#import "TPBottomBar.h"
#import "TPBottomButton.h"
#import "UserDefaultsManager.h"


@implementation TPBottomBar
- (id) initWithFrame:(CGRect)frame andArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    int startX = 0;
    int count = array.count;
    if (count > 0) {
        int buttonWidth = self.bounds.size.width / count;
        int offset = [[NSNumber numberWithDouble:self.bounds.size.width] intValue] % count;
        for (NSDictionary* dictionary in array) {
            if ([[dictionary allKeys] containsObject:@"name"]) {
                NSString* name = [dictionary objectForKey:@"name"];
                if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN] && [name rangeOfString:@"订单"].location != NSNotFound) {
                    continue;
                }
            }
            int offsetWidth = 0;
            if (offset > 0) {
                offsetWidth = 1;
                offset--;
            }
            TPBottomButton* button = [[TPBottomButton alloc]initWithFrame:CGRectMake(startX, 0, buttonWidth + offsetWidth, self.bounds.size.height)];
            startX = startX + buttonWidth + offsetWidth;
            [self addSubview:button];
            [button drawView:dictionary];
        }
    }
    if (!self.subviews || self.subviews.count <= 0) {
        self.hidden = YES;
    }

    return self;
}

- (void) drawMenus:(NSArray *)menus
{
    for (UIView* subView in self.subviews) {
        [subView removeFromSuperview];
    }
    int startX = 0;
    int count = menus.count;
    if (count > 0) {
        int buttonWidth = self.bounds.size.width / count;
        int offset = [[NSNumber numberWithDouble:self.bounds.size.width] intValue] % count;
        for (NSDictionary* dictionary in menus) {
            int offsetWidth = 0;
            if (offset > 0) {
                offsetWidth = 1;
                offset--;
            }
            TPBottomButton* button = [[TPBottomButton alloc]initWithFrame:CGRectMake(startX, 0, buttonWidth + offsetWidth, self.bounds.size.height)];
            startX = startX + buttonWidth + offsetWidth;
            [self addSubview:button];
            [button drawViewForService:dictionary];
        }
    }
    if (!self.subviews || self.subviews.count <= 0) {
        self.hidden = YES;
    }
}
@end
