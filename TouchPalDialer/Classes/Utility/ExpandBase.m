//
//  ExpandBase.m
//  TouchPalDialer
//
//  Created by Sendor on 11-11-11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "ExpandBase.h"


TinyColor TinyColorMake(CGFloat redValue, CGFloat greenValue, CGFloat blueValue,CGFloat alphaValue) {
    TinyColor color = {redValue, greenValue, blueValue, alphaValue};
    return color;
}

TinyColor TinyColorMakeClearColor() {
    return TinyColorMake(0, 0, 0, 0);
}

TinyColor TinyColorMakeBlackColor() {
    return TinyColorMake(0, 0, 0, 1);
}

TinyColor TinyColorMakeWhiteColor() {
    return TinyColorMake(1, 1, 1, 1);
}

BOOL isClearTinyColor(TinyColor color) {
    return (color.alpha == 0.0);
}

CGRect CreateInvalidFrame() {
    return CGRectMake(-1, -1, 0, 0);
}

BOOL IsInValidFrame(CGRect frame) {
    return frame.origin.x == -1 && frame.origin.y == -1 && 
    frame.size.width == 0 && frame.size.height == 0;
}
