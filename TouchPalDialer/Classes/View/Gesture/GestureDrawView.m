//
//  GestureDrawView.m
//  TouchPalDialer
//
//  Created by wen on 16/7/22.
//
//

#import "GestureDrawView.h"
#import "TPDialerResourceManager.h"
#import "NumberKey.h"
#import "UserDefaultsManager.h"
#define GESTURE_COLOR @"gestureColor"
@implementation GestureDrawView
@synthesize stroke;
@synthesize currentPath;
@synthesize delegate;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.currentPath = [UIBezierPath bezierPath];
        Strokie *tmpstrokie = [[Strokie alloc] init];
        self.stroke = tmpstrokie;
        
        BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
        UIColor *tColor = [TPDialerResourceManager getColorForStyle:@"skinGestureDrawBoardStroke_color"];
        _skinStyle_Dic=[[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"gesturePad_style"];
        strokeColor = isVersionSix ? tColor : [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[_skinStyle_Dic objectForKey:GESTURE_COLOR]];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    cootek_log(@"touchesBegan");
    [delegate beginDrawView];
    self.currentPath = [UIBezierPath bezierPath];
    CGPoint tmpPoint = [[touches anyObject] locationInView:self];
    [stroke removeAllPoints];
    [stroke addPointToStroike:tmpPoint];
    currentPath.lineWidth = 5.0;
    [currentPath moveToPoint:tmpPoint];
    [self setNeedsDisplay];
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    //     _pressView.hidden = YES;
    [delegate didFinishDrawView];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    cootek_log(@"*********x=%f,y=%f",point.x,point.y);
    [stroke addPointToStroike:point];
    [self.currentPath addLineToPoint:point];
    [self setNeedsDisplay];
}
-(void)refreshGestureInputView{
    self.currentPath = [UIBezierPath bezierPath];
    [self setNeedsDisplay];
    Strokie *tmpstrokie = [[Strokie alloc] init];
    self.stroke = tmpstrokie;
}
-(void)refreshDraw{
    self.currentPath = [UIBezierPath bezierPath];
    currentPath.lineWidth = 5.0;
    NSArray *pointArray  = stroke.pointsArray;
    int ponitCount = [pointArray count];
    for (int i =0; i<ponitCount; i++) {
        CGPoint tmpPoint = [[pointArray objectAtIndex:i] CGPointValue];
        if (i == 0) {
            [currentPath moveToPoint:tmpPoint];
        }else {
            [currentPath addLineToPoint:tmpPoint];
        }
    }
    [delegate didFinishDrawView];
    [self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{   cootek_log(@"touchesEnded");
    [delegate didFinishDrawView];
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor =[UIColor clearColor];
    [strokeColor set];
    [currentPath stroke];
}


@end
