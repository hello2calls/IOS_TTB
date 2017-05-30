//
//  NSAttributedString+TPDExtension.h
//  TouchPalDialer
//
//  Created by weyl on 16/11/7.
//
//

#import <Foundation/Foundation.h>

@interface TPDAttributedStringInfoTuple : NSObject
@property (nonatomic, strong) NSString* regPattern;
@property (nonatomic, strong) UIFont* hightlightFont;
@property (nonatomic, strong) UIColor* hightlightColor;
@end


@interface NSAttributedString (TPDExtension)
+(NSAttributedString*)tpd_attributedString:(NSString*)string withRegExp:(NSString*)regExp normalColor:(UIColor*)nc normalFont:(UIFont*)nf highlightColor:(UIColor*)hc highlightFone:(UIFont*)hf;

+(NSAttributedString*)tpd_attributedString:(NSString*)string withTupleArray:(NSArray*)highlightTuples normalColor:(UIColor*)nc normalFont:(UIFont*)nf;
@end
