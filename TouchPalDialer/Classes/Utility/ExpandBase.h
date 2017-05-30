//
//  ExpandBase.h
//  TouchPalDialer
//
//  Created by Sendor on 11-11-11.
//  Copyright 2011 Cootek. All rights reserved.
//

typedef struct tag_TinyColor {
    float red;
    float green;
    float blue;
    float alpha;
} TinyColor;

TinyColor TinyColorMake(CGFloat redValue, CGFloat greenValue, CGFloat blueValue,CGFloat alphaValue); 
TinyColor TinyColorMakeClearColor(); 
TinyColor TinyColorMakeBlackColor(); 
TinyColor TinyColorMakeWhiteColor(); 
BOOL isClearTinyColor(TinyColor color);

CGRect CreateInvalidFrame();
BOOL IsInValidFrame(CGRect frame);
