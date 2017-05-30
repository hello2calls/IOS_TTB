//
//  SpecialKey.h
//  TouchPalDialer
//
//  Created by zhang Owen on 8/10/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperKey.h"

@interface SpecialKey : SuperKey <SelfSkinChangeProtocol> {
    int toneNumber;

    UIColor *textColor;
    UIColor *textColor_ht;
    UIImage *imageOnKey;
    UIImage *imageOnKey_ht;

}
@property(nonatomic,retain) UIColor *textColor;
@property(nonatomic,retain) UIColor *textColor_ht;
@property(nonatomic,retain) UIImage *imageOnKey_ht;
@property(nonatomic,retain) UIImage *imageOnKey;
@property(nonatomic,retain) UIColor *minorTextColor;


- (id)initSpecialKeyWithFame:(CGRect)frame andKeyString:(NSString *) keyString andKeyToneNumber:(int)tone_number andKeyStyle:(NSString *)keyStyle;
@end
