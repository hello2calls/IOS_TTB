//
//  GestureView.h
//  Gestures
//
//  Created by Adam Preble on 4/27/09.
//  Copyright 2010 Giraffe Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WithSkin.h"
#import "PhonePadKeyProtocol.h"

@class GLGestureRecognizer;

@interface PhonePadGestureView : UIView <SelfSkinChangeProtocol,GesturePadKeyDelegate>{
    
    CGPoint startPoint;
    UIBezierPath *currentPath;
    BOOL isEndSignalUnRecoginer;
    BOOL isDrawMask;
    BOOL isEnableRecognizer;
    NSString *caption;
    NSDictionary *skinStyle_Dic;
}
@property (nonatomic, retain) UIBezierPath *currentPath;
@property (nonatomic, assign) BOOL is_gesture_mode; 
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, assign) id<PhonePadKeyProtocol> delegate;
@property (nonatomic, retain) UIColor *gesture_color;

- (id)initWithFrame:(CGRect)frame;
- (void)exitGestureMode;
@end
