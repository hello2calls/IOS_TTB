//
//  UILabel+DynamicHeight.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/9/6.
//
//

#import "UILabel+DynamicHeight.h"
#import "VoipConsts.h"
#import "FunctionUtility.h"

@implementation UILabel (DynamicHeight)

-(CGSize)sizeOfMultiLineLabel{
    
    if ([self attributedText]) {
    
         CGSize size = [[self attributedText] boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) \
             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
        if ( [self.text isEqualToString:@"S"]&&[UIDevice currentDevice].systemVersion.integerValue>6) {
            return CGSizeMake(size.width+80,size.height);
        }else{
            return size;
        }
    }
    
    //Label text
    NSString *aLabelTextString = [self text];
    
    //Label font
    UIFont *aLabelFont = [self font];
    
    //Width of the Label
    CGFloat aLabelSizeWidth = self.frame.size.width;
    
    
    if (SYSTEM_VERSION_LESS_THAN(iOS7_0)) {
        return [aLabelTextString sizeWithFont:aLabelFont
                            constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByCharWrapping];
    }
    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        return [aLabelTextString boundingRectWithSize:CGSizeMake(aLabelSizeWidth, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : aLabelFont
                                                        }
                                              context:nil].size;
        
    }
    
    return [self bounds].size;

}

- (void) adjustSizeByFixedWidth {
    UIFont *font = self.font;
    NSString *labelText = self.text;
    if (!font || !labelText) {
        return;
    }
    CGRect oldFrame = self.frame;
    CGSize oldSize = self.bounds.size;
    
    // the size after adjusting
    CGSize newSize = oldSize;
    
    if ([FunctionUtility systemVersionFloat] < 7.0) {
        newSize = [labelText sizeWithFont:font
                     constrainedToSize:CGSizeMake(oldSize.width, CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByCharWrapping];
        
    } else {
        newSize = [labelText boundingRectWithSize:CGSizeMake(oldSize.width, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName: font
                                                        }
                                           context:nil].size;
    }
    self.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, newSize.width, newSize.height);
}

- (void) adjustSizeByFixedHeight {
    UIFont *font = self.font;
    NSString *labelText = self.text;
    if (!font || !labelText) {
        return;
    }
    CGRect oldFrame = self.frame;
    CGSize oldSize = self.bounds.size;
    
    // the size after adjusting
    CGSize newSize = oldSize;
    
    if ([FunctionUtility systemVersionFloat] < 7.0) {
        newSize = [labelText sizeWithFont:font
                        constrainedToSize:CGSizeMake(CGFLOAT_MAX, oldSize.height)
                            lineBreakMode:NSLineBreakByCharWrapping];
        
    } else {
        newSize = [labelText boundingRectWithSize:CGSizeMake(MAXFLOAT, oldSize.height)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{
                                                    NSFontAttributeName: font
                                                    }
                                          context:nil].size;
    }
    self.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, newSize.width, newSize.height);
    
}

- (void) adjustSizeByFillContent {
    UIFont *font = self.font;
    NSString *labelText = self.text;
    if (!font || !labelText) {
        return;
    }
    if (CGRectIsNull(self.frame)) {
        self.frame = CGRectZero;
    }
    CGRect oldFrame = self.frame;
    CGSize oldSize = self.bounds.size;
    
    // the size after adjusting
    CGSize newSize = oldSize;
    
    if ([FunctionUtility systemVersionFloat] < 7.0) {
        newSize = [labelText sizeWithFont:font];
        
    } else {
        newSize = [labelText boundingRectWithSize:oldSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{
                                                    NSFontAttributeName: font
                                                    }
                                          context:nil].size;
    }
    self.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, newSize.width, newSize.height);
}

@end
