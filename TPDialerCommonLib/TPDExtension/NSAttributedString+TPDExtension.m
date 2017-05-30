//
//  NSAttributedString+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/7.
//
//

#import "NSAttributedString+TPDExtension.h"
#import "TPDExtension.h"

@implementation NSAttributedString (TPDExtension)
+(NSAttributedString*)tpd_attributedString:(NSString*)string withRegExp:(NSString*)regExp normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:regExp options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray* resultArr = [reg matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    [attributeString addAttribute:NSForegroundColorAttributeName value:nc range:NSMakeRange(0, string.length)];
    [attributeString addAttribute:NSFontAttributeName value:nf range:NSMakeRange(0, string.length)];
    
    for (NSTextCheckingResult* result in resultArr) {
        [attributeString addAttribute:NSForegroundColorAttributeName value:hc range:result.range];
        [attributeString addAttribute:NSFontAttributeName value:hf range:result.range];
    }
    return attributeString;
}

+(NSAttributedString*)tpd_attributedString:(NSString*)string withTupleArray:(NSArray*)highlightTuples normalColor:(UIColor*)nc normalFont:(UIFont*)nf{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributeString addAttribute:NSForegroundColorAttributeName value:nc range:NSMakeRange(0, string.length)];
    [attributeString addAttribute:NSFontAttributeName value:nf range:NSMakeRange(0, string.length)];
    
    for (TPDAttributedStringInfoTuple* tuple in highlightTuples) {
        NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:tuple.regPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray* resultArr = [reg matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        
        
        for (NSTextCheckingResult* result in resultArr) {
            [attributeString addAttribute:NSForegroundColorAttributeName value:tuple.hightlightColor range:result.range];
            [attributeString addAttribute:NSFontAttributeName value:tuple.hightlightFont range:result.range];
        }
    }
    return attributeString;
}

@end
