//
//  ScrollViewButton.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/23.
//
//

#import <UIKit/UIKit.h>

@interface ScrollViewButton : UIButton

@property (nonatomic, retain)UIColor *highlightColor;

- (void)clearHighlightState;

@end
