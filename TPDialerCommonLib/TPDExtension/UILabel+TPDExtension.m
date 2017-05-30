//
//  UILabel+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import "UILabel+TPDExtension.h"

@implementation UILabel (TPDExtension)


+ (UILabel *)tpd_commonLabel{
    UILabel *label = [[UILabel alloc] init];
    
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    return label;
}

-(UILabel*)tpd_withText:(NSString*)text color:(UIColor*)color{
    self.text = text;
    self.textColor = color;
    return self;
}

-(UILabel*)tpd_withText:(NSString*)text color:(UIColor*)color font:(NSInteger)fontSize{
    self.text = text;
    self.textColor = color;
    self.font = [UIFont systemFontOfSize:fontSize];
    return self;
}


-(UILabel*)tpd_withDigitalAttributedText:(NSString*)text normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:@"[0-9]+\\.?[0-9]*" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray* resultArr = [reg matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    self.font = nf;
    self.textColor = nc;
    
    for (NSTextCheckingResult* result in resultArr) {
        [attributeString addAttribute:NSForegroundColorAttributeName value:hc range:result.range];
        [attributeString addAttribute:NSFontAttributeName value:hf range:result.range];
    }
    
    self.attributedText = attributeString;
    
    return self;
}

-(UILabel*)tpd_withDateAttributedText:(NSString*)text normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:@"[0-9]+\\.[0-9]+\\.[0-9]+" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray* resultArr = [reg matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    self.font = nf;
    self.textColor = nc;
    
    for (NSTextCheckingResult* result in resultArr) {
        [attributeString addAttribute:NSForegroundColorAttributeName value:hc range:result.range];
        [attributeString addAttribute:NSFontAttributeName value:hf range:result.range];
    }
    
    self.attributedText = attributeString;
    
    return self;
}

-(UILabel*)tpd_withDialKeyAttributedText:(NSString*)text normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf{
    
    
    NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:@"[0-9*#]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    [self tpd_withAttributedText:text normalColor:nc normalFont:nf highlightColor:hc highlightFone:hf ofPattern:reg];
    
    return self;
}

-(UILabel*)tpd_withAttributedText:(NSString*)text normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf ofPattern:(NSRegularExpression*)reg{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSArray* resultArr = [reg matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    self.font = nf;
    self.textColor = nc;
    
    for (NSTextCheckingResult* result in resultArr) {
        [attributeString addAttribute:NSForegroundColorAttributeName value:hc range:result.range];
        [attributeString addAttribute:NSFontAttributeName value:hf range:result.range];
    }
    
    self.attributedText = attributeString;
    
    return self;
}
@end