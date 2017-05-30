//
//  CustomInputTextFiled.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-10-23.
//
//

#import <UIKit/UIKit.h>

@interface CustomInputTextFiled : UITextField
@property(nonatomic,strong) UIView *middleLine;
- (id)initWithFrame:(CGRect)frame andPlaceHolder:(NSString*)placeHolder andID:(id)object;
- (id)initWithFrame:(CGRect)frame withDefaultPadding:(int)defaultPadding andPlaceHolder:(NSString*)placeHolder andID:(id)object;
@end
