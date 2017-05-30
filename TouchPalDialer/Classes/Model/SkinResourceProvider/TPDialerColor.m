//
//  TPDialerColor.m
//  TouchPalIME
//
//  Created by gan lu on 12/14/11.
//  Copyright (c) 2011 CooTek. All rights reserved.
//

#import "TPDialerColor.h"

@implementation TPDialerColor

@synthesize alpha;
@synthesize R = red;
@synthesize G = green;
@synthesize B = blue;

- (TPDialerColor *)initWithString:(NSString *)string{   
    unsigned int colorInt;
    if ([string hasPrefix:@"0x"]) {
        [[NSScanner scannerWithString:string] scanHexInt:&colorInt];
    }else{
        colorInt = [string intValue];
    }
    return [self initWithInt:colorInt];
}

- (TPDialerColor *)initWithInt:(int)intVal{  
	if (self = [self init]) {        
        self.alpha = (1.0 - ((intVal >> 24) & 0xff) / 255.0);
        self.R = ((intVal >> 16) & 0xff) / 255.0 ;
        self.G = ((intVal >> 8) & 0xff) / 255.0;
        self.B = (intVal & 0xff) / 255.0;
    }
    
    return self;
}

- (UIColor *)uiColor{
    return [UIColor colorWithRed:self.R green:self.G blue:self.B alpha:self.alpha];
}
@end
