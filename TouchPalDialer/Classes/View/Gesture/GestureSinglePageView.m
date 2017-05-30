//
//  GestureSinglePageView.m
//  TouchPalDialer
//
//  Created by Admin on 7/1/13.
//
//


#import "GestureSinglePageView.h"
#import "consts.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "CootekNotifications.h"
#import "GestureSinglePersonView.h"
#import "TPDialerResourceManager.h"
#import "GestureSettingsViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "UserDefaultsManager.h"

#define ROWS 3
#define COLUMNS 3
#define PADDING_LEFT 10.0
#define WIDTH ((TPScreenWidth()- 4*PADDING_LEFT)/3)
#define PADDING_UP 15
#define PADDING_DOWN 28

@interface GestureSinglePageView() <DeleteDelegate>
@property (nonatomic, retain)NSMutableArray *_gestureButtons;
@property (nonatomic, assign)UIView *_addPersonButtonNormal;
@property (nonatomic, assign)UIView *_addPersonButtonEdit;
@end

@implementation GestureSinglePageView

@synthesize gestureCustomList;
@synthesize gestureModel;
@synthesize pageNumber;
@synthesize parentView;
@synthesize maskBtn;

-(id)initWithPageNumber:(NSInteger)number Frame:(CGRect)frame EditMode:(Boolean)editMode
{
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        self._gestureButtons = buttons;
        self.gestureModel = [GestureModel getShareInstance];
        self.pageNumber = number;
        [self setData];
        if (editMode) {
            [self addDeleteBtn];
        } 
    }
    return self;
}

- (void) setData
{
    for(UIView *view in [self subviews])
    {
        [view removeFromSuperview];
    }
    
    self.gestureCustomList = [NSMutableArray arrayWithArray:[self.gestureModel.mGestureRecognier getGestureList]];
    int height = (self.frame.size.height - PADDING_UP - PADDING_DOWN) / 3;
    int gestureCount = [self.gestureCustomList count];
    
    for (NSInteger i = 0 ; i < ROWS ; i++) {
        for(NSInteger j = 0 ; j < COLUMNS; j ++) {
            int currentGesture = self.pageNumber*ROWS*COLUMNS+i*COLUMNS+j;
            if (currentGesture == gestureCount) {
                GestureSinglePersonView *person = [[GestureSinglePersonView alloc]
                                                   initWithAdd:CGRectMake(PADDING_LEFT+(WIDTH+PADDING_LEFT)*j,
                                                                          PADDING_UP+height * i, WIDTH, height)];
                [self addSubview:person];
                __addPersonButtonNormal = person;
                [self._gestureButtons addObject:person];
            }else if(currentGesture < gestureCount){
                currentGesture --;
                GestureSinglePersonView *person = [[GestureSinglePersonView alloc]
                                                   initWithGesture:[self.gestureCustomList objectAtIndex:currentGesture+1]
                                            Frame:CGRectMake(PADDING_LEFT+(WIDTH+PADDING_LEFT)*j,
                                                             PADDING_UP+height * i, WIDTH, height) andIndex:currentGesture];
                [self addSubview:person];
                [self._gestureButtons addObject:person];
                person.deleteDelegate = self;
            }
        }
    }
}

- (void)addDeleteBtn
{
    for (GestureSinglePersonView *button in self._gestureButtons) {
        [button showDeleteButton];
    }
}

- (void) hideDeleteBtn
{
    for (GestureSinglePersonView *button in self._gestureButtons) {
        [button hideDeleteButton];
    }
}

- (void)onDeletePressed:(UIButton *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete prompt",@"")
                                                    message:nil                                                delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel",@"" )
                                          otherButtonTitles:NSLocalizedString(@"Ok",@"" ), nil];
    alert.tag = button.tag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (1 == buttonIndex) {
        int index = alertView.tag;
        Gesture *tmpGesture = [self.gestureCustomList objectAtIndex:index+1];
        [self.gestureModel.mGestureRecognier removeGesture:tmpGesture.name];
        self.gestureCustomList = [NSMutableArray arrayWithArray:[self.gestureModel.mGestureRecognier getGestureList]];
        if ([self.gestureCustomList count] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_NOGESTURE
                                                                object:nil
                                                              userInfo:nil];
            
        }
        if ((self.pageNumber == [self.gestureCustomList count]/9) && ([self.gestureCustomList count]%9 != 8)) {
            [self setData];
            [self addDeleteBtn];
        } else {
            self.parentView.isEdit = YES;
            [self.parentView loadScrollView];
        }
        [UserDefaultsManager setIntValue:0 forKey:HOW_MUCH_GESTURES];
    }
}

- (void)dealloc
{
    
    [SkinHandler removeRecursively:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
