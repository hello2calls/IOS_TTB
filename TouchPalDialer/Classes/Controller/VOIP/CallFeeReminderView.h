//
//  CallFeeReminderView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14/12/4.
//
//

#import <UIKit/UIKit.h>

@interface CallFeeReminderView : UIView
- (void)setText:(NSString *)text andSize:(UIFont *)size;
- (UILabel*)getLabel;
@end
