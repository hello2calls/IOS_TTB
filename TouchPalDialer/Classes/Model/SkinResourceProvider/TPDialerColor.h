//
//  TPDialerColor.h
//  TouchPalIME
//
//  Created by gan lu on 12/14/11.
//  Copyright (c) 2011 CooTek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPDialerColor : NSObject{
    float alpha;
    float red;
    float green;
    float blue;
}

@property float alpha;
@property float R;
@property float G;
@property float B;

- (TPDialerColor *)initWithInt:(int)intVal;
- (TPDialerColor *)initWithString:(NSString *)string;
- (UIColor *)uiColor;
@end
