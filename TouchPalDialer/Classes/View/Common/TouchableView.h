//
//  TouchableView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-10-17.
//
//

#import <UIKit/UIKit.h>
@protocol ViewTouchDelegate
- (void)onViewTouch;
@end

@interface TouchableView : UIView
@property (nonatomic, assign)id<ViewTouchDelegate> delegate;
@end
