//
//  GestureView.m
//  Gestures
//
//  Created by Adam Preble on 4/27/09.
//  Copyright 2010 Giraffe Lab. All rights reserved.
//

#import "PhonePadGestureView.h"
#import "GLGestureRecognizer.h"
#import "GLGestureRecognizer+JSONTemplates.h"
#import "FunctionUtility.h"
#import "GestureModel.h"
#import "PhonePadModel.h"
#import "CallLogDataModel.h"
#import "DialResultModel.h"
#import "TouchPalDialerAppDelegate.h"
#import "PhoneDataModel.h"

#import "CootekNotifications.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"

#define minX -107
#define minY -CELL_HEIGHT
#define maxX 107
#define maxY CELL_HEIGHT

#define DEFAULT_LENGTH 0
#define VIEW_RESULT_TAG 500
#define GESTURE_COLOR @"gestureColor"

@interface PhonePadGestureView (){  
    BOOL isGestureMode;
    BOOL isPreGestureMode;
    GestureModel *gestureModel;
    Strokie *stroke;
}
@end

@implementation PhonePadGestureView
@synthesize currentPath;
@synthesize is_gesture_mode;
@synthesize caption;
@synthesize delegate;
@synthesize gesture_color;

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:bgImage];
        gestureModel = [GestureModel getShareInstance];
        isEnableRecognizer = gestureModel.isOpenSwitchGesture; 
        stroke = [[Strokie alloc] init];
        self.currentPath = [UIBezierPath bezierPath];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGesture) name:N_DAILER_WILL_APPEAR object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGestureMode) name:N_UN_RECOGNIZER_EXIT_BAR object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingChanged:) name:N_GESTURE_SETTING_CHNAGE object:nil];
     }
    return self;
}
- (void)settingChanged:(NSNotification *)noti{
    isEnableRecognizer = [noti.object boolValue];
}
- (void)dealloc {
    [SkinHandler removeRecursively:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshGesture{
    [self exitGestureMode];
}
- (void)drawRect:(CGRect)rect 
{
    if (isGestureMode && isEnableRecognizer) {
        [gesture_color set];
        [currentPath stroke];      
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isEnableRecognizer) {
        isPreGestureMode = isGestureMode;
        if (isGestureMode) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_HIDE_UNREGN_BAR object:nil]; 
        }else {
            self.currentPath = [UIBezierPath bezierPath];
            [stroke removeAllPoints];
        }
        CGPoint tmpPoint = [[touches anyObject] locationInView:self];
        [stroke addPointToStroike:tmpPoint];
        startPoint = [[touches anyObject] locationInView:[[touches anyObject] view]];
        [currentPath moveToPoint:tmpPoint];
        currentPath.lineWidth = 5.0;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_KEYBOARD_USED object:nil];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isEnableRecognizer)  {
        [self exitGestureMode];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isEnableRecognizer) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [stroke addPointToStroike:point];
        [self.currentPath addLineToPoint:point];
       
        CGPoint tmppoint = [touch locationInView:[touch view]];
        if (//(tmppoint.x < DEFAULT_LENGTH || tmppoint.y < DEFAULT_LENGTH) || 
            (tmppoint.x-startPoint.x > maxX || tmppoint.x-startPoint.x < minX )
            || (tmppoint.y - startPoint.y > maxY || tmppoint.y - startPoint.y < minY)) {
            if (isGestureMode == NO) {
                self.backgroundColor =  [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[skinStyle_Dic objectForKey:BACK_GROUND_COLOR]];
            }
            isGestureMode = YES;
        }
        if (isGestureMode == YES) {
            [self setNeedsDisplay];
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isEnableRecognizer){
        if (isGestureMode) {
            NSString *notificationName = @"";
            isEndSignalUnRecoginer = NO;
            Gesture *gesture = [[Gesture alloc] initWithGesture:@"input"];
            [gesture addStrokieToGesture:stroke];
            GesturesResults *result = [gestureModel.mGestureRecognier recognizerGesture:gesture];
            self.caption = [NSString stringWithFormat:@"%@,%f",result.name,result.score];
            PhonePadModel *shared_phonepadmodel = [PhonePadModel getSharedPhonePadModel];
            if (result.score <= GESTURE_RECOGNIZER_THREHOLD) {
                [delegate onWillChangeGestureRecginzer:result.name];
            }else {
                ItemType type = [GestureUtility getGestureItemType:result.name];
                if (type != FirstItemType || [[[shared_phonepadmodel calllog_list] searchResults] count] != 0) {
                    notificationName = result.name;
                }
                isEndSignalUnRecoginer = YES;
            }
            
            if (isEndSignalUnRecoginer == YES) {
                gestureModel.pointArray = stroke.pointsArray;
                [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_UN_RECOGNIZER object:notificationName]; 
            }else {
                [self exitGestureMode];
            }
        }
        [stroke removeAllPoints];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_KEYBOARD_NOT_USED object:nil];
}
-(void)exitGestureMode{
    if (isGestureMode) {
        self.backgroundColor = [UIColor clearColor];
        self.currentPath = [UIBezierPath bezierPath];
        [stroke removeAllPoints];
        isGestureMode = NO;
        [self setNeedsDisplay]; 
    }
}

- (id)selfSkinChange:(NSString *)style{
     skinStyle_Dic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
     self.gesture_color = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[skinStyle_Dic objectForKey:GESTURE_COLOR]];
     NSNumber *toTop = [NSNumber numberWithBool:NO];
     return toTop;
}
-(BOOL)isGestureMode{
    return isEnableRecognizer&&isGestureMode;
}
-(BOOL)preGesturePadState{
    return isPreGestureMode;
}
@end
