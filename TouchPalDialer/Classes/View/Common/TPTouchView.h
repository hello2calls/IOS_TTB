//
//  TPTouchView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/30.
//
//

#import <UIKit/UIKit.h>

@protocol TPTouchViewDelegate <NSObject>
- (void)tpTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)tpTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)tpTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface TPTouchView : UIView

@property (nonatomic, weak)id<TPTouchViewDelegate>delegate;

@end
