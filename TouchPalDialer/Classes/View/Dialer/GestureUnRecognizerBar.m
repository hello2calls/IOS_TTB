//
//  GestureUnRecognizerBar.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-6-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GestureUnRecognizerBar.h"
#import "CootekNotifications.h"
#import "GestureRecognizer.h"
#import "GestureModel.h"
#import "GesturePersonPickerViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "PhonePadModel.h"
#import "GestureUtility.h"
#import "ContactCacheDataManager.h"
#import "TPDialerResourceManager.h"
#import "NSString+PhoneNumber.h"
#import "GestureEditViewController.h"

#define DURATION 3
@implementation TPLabelUIButton
@synthesize iconString;
@synthesize iconImageView;
@synthesize customImageSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.backgroundColor = [UIColor clearColor];
        UILabel *mlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        mlabel.backgroundColor = [UIColor clearColor];
        mlabel.font = [UIFont systemFontOfSize:CELL_FONT_TITILE];
        mlabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:mlabel];
        self.iconString = mlabel;
        
        //icon
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:imageView];
        self.iconImageView = imageView;
        
    }
    return self;
}
- (void)resetButton:(UIImage *)icon withTitile:(NSString *)title withModel:(ButtonModeType)type{
    self.iconImageView.image = icon;
    self.iconString.text = title;
    switch (type) {
        case ButtonModeTypeLabelLeft:{
            self.iconImageView.image = nil;
            iconImageView.frame = CGRectMake(10, (self.frame.size.height - icon.size.width)/2, icon.size.width, icon.size.height);
            iconString.frame =CGRectMake(0, 0,self.frame.size.width, self.frame.size.height);
            break;
        }
        case ButtonModeTypeLabelCustom:{
            iconImageView.frame = CGRectMake(10, (self.frame.size.height - customImageSize.width)/2, customImageSize.width, customImageSize.height);
            iconString.frame =CGRectMake(customImageSize.width, 0,self.frame.size.width-customImageSize.width, self.frame.size.height);
            if (!icon) {
                iconString.frame =CGRectMake(0, 0,self.frame.size.width, self.frame.size.height);
            }
            break;
        }
        default:
            break;
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (void)resetIconString:(NSString *)str {
	iconString.text = str;
}
@end
@implementation GestureUnRecognizerBar

@synthesize gestureBtn;
@synthesize keyName;
- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //left
        self.backGroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.backGroundImage];
        leftBtn = [[TPLabelUIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height)];
        [leftBtn addTarget:self action:@selector(cancelGesture) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftBtn];
        //[leftBtn release];
        
        //right
        TPLabelUIButton *rightBtn = [[TPLabelUIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, self.frame.size.height)];
        [rightBtn addTarget:self action:@selector(excuteAction) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.customImageSize = CGSizeMake(40, 40);
        self.gestureBtn = rightBtn;
        [self addSubview:rightBtn];
        
        self.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGestureBtn:) name:N_GESTURE_UN_RECOGNIZER object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disAppearBar) name:N_GESTURE_HIDE_UNREGN_BAR object:nil];
    }
    return self;
}

-(void)reloadGestureBtn:(NSNotification*)noti {
    NSString *name = noti.object;
    UIImage *icon = nil;
    NSString *title = @"";
    if ([name length] > 0) {
        self.keyName = name;
        ItemType type = [GestureUtility getGestureItemType:name];
        switch (type) {
            case FirstItemType:
                title = [GestureUtility getDisplayName:name];
                break; 
            default:{
                GestureActionType type = [GestureUtility getActionType:name];
                NSInteger personID = [GestureUtility getPersonID:name withAction:type];
                title = [[[ContactCacheDataManager instance] contactCacheItem:personID] fullName];
                if ([title length] == 0) {
                    title = [[GestureUtility getNumber:name withAction:type] formatPhoneNumber];
                }
                break;
            } 
        }
        Gesture *gesture = [[GestureModel getShareInstance].mGestureRecognier getGesture:name];
        icon = [gesture convertToImage];
        gestureBtn.customImageSize = CGSizeMake(40, 40);
        [gestureBtn resetButton:icon withTitile:title withModel:ButtonModeTypeLabelCustom];
        [gestureBtn removeTarget:self action:@selector(ceateNewGesture) forControlEvents:UIControlEventTouchUpInside];
        [gestureBtn addTarget:self action:@selector(excuteAction) forControlEvents:UIControlEventTouchUpInside];
        

    }else {
       //没有匹配条目 
        self.keyName = @"";
        [gestureBtn resetButton:nil withTitile:NSLocalizedString(@"Add a gesture",@"添加手势") withModel:ButtonModeTypeLabelCustom];
        [gestureBtn removeTarget:self action:@selector(excuteAction) forControlEvents:UIControlEventTouchUpInside];
        [gestureBtn addTarget:self action:@selector(ceateNewGesture) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.hidden = NO;  
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disAppearBar_auto) object:nil];
    [self performSelector:@selector(disAppearBar_auto) withObject:nil afterDelay:DURATION];

}
-(void)excuteAction{
    if ([keyName length] >0) {
        [[PhonePadModel getSharedPhonePadModel] excuteGestureAction:keyName];
        [self disAppearBar];
    } else {
        [self disAppearBar_auto];
    }
}
-(void)ceateNewGesture{
    GestureEditViewController *editViewController = [[GestureEditViewController alloc] initWithGesturePic];
    
    UINavigationController *m_navigationController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    [m_navigationController  pushViewController:editViewController animated:YES];
    [self disAppearBar];
}

-(void)cancelGesture{
    [self disAppearBar];
}
-(void)disAppearBar{
    self.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disAppearBar_auto) object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_UN_RECOGNIZER_EXIT_BAR object:nil userInfo:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)disAppearBar_auto{
   self.hidden = YES;
   [[NSNotificationCenter defaultCenter] postNotificationName:N_UN_RECOGNIZER_EXIT_BAR object:nil userInfo:nil];
}

- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
     if([propertyDic objectForKey:BACK_GROUND_IMAGE]){
       self.backGroundImage.image = [TPDialerResourceManager getImage:[propertyDic objectForKey:BACK_GROUND_IMAGE]];
     }
      leftBtn.iconString.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"GestureUnRecognizerBarText_color"]];
      gestureBtn.iconString.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"GestureUnRecognizerBarText_color"]];         
      [leftBtn resetButton:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"leftButtonImage"]] withTitile:NSLocalizedString(@"Cancel","") withModel:ButtonModeTypeLabelLeft];
     NSNumber *toTop = [NSNumber numberWithInt:YES];
     return toTop;
}
@end
