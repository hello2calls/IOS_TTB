//
//  UILabel+TPDExtension.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import <UIKit/UIKit.h>
#import "TPDExtension.h"
@interface UILabel (TPDExtension)

+ (UILabel *)tpd_commonLabel;

-(UILabel*)tpd_withText:(NSString*)text color:(UIColor*)color;

-(UILabel*)tpd_withText:(NSString*)text color:(UIColor*)color font:(NSInteger)fontSize;

-(UILabel*)tpd_withDateAttributedText:(NSString*)text normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf;

-(UILabel*)tpd_withDigitalAttributedText:(NSString*)text normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf;

-(UILabel*)tpd_withDialKeyAttributedText:(NSString*)text normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf;

-(UILabel*)tpd_withAttributedText:(NSString*)text normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf ofPattern:(NSRegularExpression*)reg;
@end
