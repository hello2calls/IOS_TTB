//
//  GestureDrawView.h
//  TouchPalDialer
//
//  Created by wen on 16/7/22.
//
//

#import <UIKit/UIKit.h>
#import "GestureRecognizer.h"

@protocol GestureDrawViewDelegate
@optional
- (void)didFinishDrawView;
- (void)beginDrawView;
@end

@interface GestureDrawView : UIView{
    
    UIBezierPath *currentPath;
    Strokie *stroke;
    id<GestureDrawViewDelegate> __unsafe_unretained delegate;
    UIColor __strong *strokeColor;
}

@property(nonatomic,retain) UIBezierPath *currentPath;
@property(nonatomic,retain) Strokie *stroke;
@property(nonatomic,retain)NSDictionary* skinStyle_Dic;
@property (nonatomic, retain) UIColor *gesture_color;
@property(nonatomic,assign) id<GestureDrawViewDelegate> delegate;

-(void)refreshGestureInputView;
-(void)refreshDraw;
@end

