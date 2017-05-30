//
//  CustomTextView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-10.
//
//

#import <UIKit/UIKit.h>

@interface CallingStateTextView : UIView
@property (nonatomic, copy)NSString *line1;
@property (nonatomic, copy)NSString *line2;
@property (nonatomic, copy)NSString *line3;
@property (nonatomic, retain)UIColor *line1Color;
@property (nonatomic, retain)UIColor *line2Color;
@property (nonatomic, retain)UIColor *line3Color;
@property (nonatomic, assign)int font1Size;
@property (nonatomic, assign)int font2Size;
@property (nonatomic, assign)int font3Size;
- (void)setLine1:(NSString *)line1 line2:(NSString *)line2 line3:(NSString *)line3;
- (void)setFont1:(int)font1 font2:(int)font2 font3:(int)font3;
@end
