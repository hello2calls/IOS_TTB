//
//  TPBottomBar.h
//  TouchPalDialer
//
//  Created by tanglin on 15-8-11.
//
//

#import <Foundation/Foundation.h>

@interface TPBottomBar : UIView

- (id) initWithFrame:(CGRect)frame andArray:(NSArray *)array;
- (void) drawMenus:(NSArray *)menus;
@end
