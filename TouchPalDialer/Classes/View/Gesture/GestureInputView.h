//
//  GestureInputView.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureRecognizer.h"
#import "GestureDrawView.h"
#import "ImageViewUtility.h"

@protocol GestureInputDelegate
@optional
- (void)didFinishDraw;
- (void)beginDraw;
@end
@interface GestureInputView : UIView<GestureDrawViewDelegate>{

    UIBezierPath *currentPath;
    Strokie *stroke;
    id<GestureInputDelegate> __unsafe_unretained delegate;
     UIColor __strong *strokeColor;
}

@property(nonatomic,retain) UIBezierPath *currentPath;
@property(nonatomic,retain) Strokie *stroke;
@property(nonatomic,retain)NSDictionary* skinStyle_Dic;
@property (nonatomic, retain) UIColor *gesture_color;
@property (nonatomic, retain)UIView *pressView;
@property (nonatomic, retain)ImageViewUtility *imageView;
@property (nonatomic, retain)GestureDrawView *drawView;
@property(nonatomic,assign) id<GestureInputDelegate> delegate;

-(void)refreshGestureInputView; 
-(void)refreshDraw;
@end
