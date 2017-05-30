//
//  CallerTypeSticker.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-10-15.
//
//

#import <UIKit/UIKit.h>

@interface CallerTypeSticker : UIView
@property(nonatomic, retain) NSString *currentNumber;
@property(nonatomic, retain) UILabel *typeLabel;
@property(nonatomic, retain) UIImageView *typeImageView;
@property(nonatomic, retain) UILabel *dotLabel;
@end
