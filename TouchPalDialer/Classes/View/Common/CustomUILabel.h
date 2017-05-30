//
//  CustomUILabel.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/2/12.
//
//

#import <UIKit/UIKit.h>

@interface CustomUILabel : UILabel
@property (nonatomic, copy)void(^pressBlock)(void);
@property (nonatomic, retain)UIColor *disableColor;
@end
