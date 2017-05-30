//
//  TPTextFlowView.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/26/12.
//
//

#import <UIKit/UIKit.h>

@interface TPTextFlowView : UIView

- (id)initWithFrame:(CGRect)frame
               text:(NSString *)text
          textColor:(UIColor *)textColor
      textAlignment:(NSTextAlignment)textAlignment
               font:(UIFont *)font
         spaceWidth:(CGFloat)spaceWidth
       timeInterval:(NSTimeInterval)interval;

@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, copy) NSString *text;

@end