//
//  TPDDialerPad.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/7.
//
//

#import "TPDDialerPad.h"
#import "TPDLib.h"
#import <Masonry.h>
#import <BlocksKit.h>
#import <UIGestureRecognizer+BlocksKit.h>
#import "PhoneNumber.h"
#import "NSString+PhoneNumber.h"    
#import "TPDPhoneCallViewController.h"
#import "AppSettingsModel.h"
#import "CootekSystemService.h"
#import "PhonePadGestureView.h"
#import "GestureUtility.h"
#import "GestureRecognizer.h"
#import "GestureModel.h"
#import "PhonePadModel.h"
#import "FunctionUtility.h"
#import "InputNumberPasteUtility.h"
#import "CootekNotifications.h"
#import "GestureEditViewController.h"
#import "TPDialerResourceManager.h"
#import "ContactCacheDataManager.h"

@interface EllipseView : UIView
@end

@implementation EllipseView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,-4);
        self.layer.shadowOpacity = .03f;
        self.layer.shadowRadius = 1.0f;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;
    NSInteger steps = 50;
    
    
    UIBezierPath *p=[UIBezierPath bezierPath];
    [p moveToPoint:CGPointMake(0, h)];
    //    double stepLength = w/(steps-1);
    //    for (int i=0; i<steps; i++) {
    //        [p addLineToPoint:CGPointMake(stepLength*i, h - (h-1)*sin(stepLength*i/w*M_PI))];
    //    }
    //    [p addLineToPoint:CGPointMake(w, h)];
    [p addQuadCurveToPoint:CGPointMake(w, h) controlPoint:CGPointMake(w/2, -h/2)];
    self.layer.shadowPath = p.CGPath;
    
    [p closePath];
    [p fill];
    
    
}

@end


@interface TPDNumberLabel : UILabel
@property (nonatomic) id delegate;
@end



@interface TPDGesturePad : UIView
@property (nonatomic, strong) NSMutableArray* gesturePoints;
@property (nonatomic, strong) UIBezierPath* bezierPath;
@property (nonatomic) id delegate;

@property (nonatomic, strong) UIPanGestureRecognizer* pan;
@property (nonatomic) BOOL gestureEnabled;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint currentPoint;

@property (nonatomic, strong) UIColor* gestureColor;
@property (nonatomic, strong) UIImageView* coverView;
@end


@interface TPDDialerPad ()
@property (nonatomic,strong) UIView* ellipse;
@property (nonatomic,strong) TPDNumberLabel* numDialed;
//@property (nonatomic,strong) UILabel* numAttr;
@property (nonatomic,strong) NSString* numAttrString;
@property (nonatomic,strong) UIView* keyPad;
@property (nonatomic,strong) UIView* btnBar;
@property (nonatomic,strong) UIImageView* backspaceImg;
@property (nonatomic, strong) UIView* upperPartWrapper;
@property (nonatomic,strong) UIImageView* collpaseImg;
@property (nonatomic, strong) TPDGesturePad* gestureView;
@property (nonatomic, strong) UIView* addGestureBar;
@property (nonatomic, strong) UIButton* dialBtn;

@property (nonatomic, strong) UIImageView* backgroundImage;

@property (nonatomic, strong) UIButton* backupGestureButton;
@property (nonatomic, strong) UILabel* backupGestureName;
@property (nonatomic, strong) UIImageView* backupGestureImage;
@property (nonatomic, strong) UIButton* addGestureButton;

@property (nonatomic, strong) UIView* part1;
@property (nonatomic, strong) UIView* part2;

@end

@implementation TPDNumberLabel


-(void)copy:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;
}

-(void)paste:(id)sender{
    [self.delegate pasteNum];
}


- (BOOL)canBecomeFirstResponder{
    return YES;
    
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(copy:) || action == @selector(paste:)) {
        
        return YES;
    }
    return NO;
    
}

- (id)init
{
    self = [super init];
    if (self)
    {
        UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            if (sender.state == UIGestureRecognizerStateBegan) {
                [self becomeFirstResponder  ];
                
                [[UIMenuController sharedMenuController] setTargetRect:self.bounds inView:self];
                [[UIMenuController sharedMenuController] setMenuVisible:YES animated: YES];
            }
        }];
        
        [self addGestureRecognizer:touch];
        self.userInteractionEnabled = YES;
        
    }
    return self;
}
@end



@implementation TPDGesturePad
-(NSString*)createTitleFromName:(NSString*)name{
    NSString* title = @"";
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
    return title;
}

- (void)cover {
    [self decover];
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size,NO,0);
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextAddPath(con, [self.bezierPath CGPath]);
    CGContextSetStrokeColorWithColor(con,self.gestureColor.CGColor);
    CGContextSetLineCap(con, kCGLineCapSquare);
    CGContextSetLineWidth(con, 5);
    CGContextStrokePath(con);
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView* ret = [[UIImageView alloc] initWithImage:viewImage];
    [self addSubview:ret];
    [ret makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    ret.backgroundColor = [UIColor colorWithHexString:@"FFFFFF" alpha:0.5];
    
    ret.userInteractionEnabled = YES;
    WEAK(self)
    [ret addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [weakself.delegate showAddGestureBar:NO];
    }]];
    self.coverView = ret;
}

-(void)decover{
    [self.coverView removeFromSuperview];
}

-(BOOL)gestureLongEnough{
    double total = 0;
    for (int i=1; i<self.gesturePoints.count; i++) {
        CGPoint p1 = [self.gesturePoints[i] CGPointValue];
        CGPoint p2 = [self.gesturePoints[i-1] CGPointValue];
        total +=fabs(p1.x - p2.x) + fabs(p1.y - p2.y);
        if (total > 50) {
            return YES;
        }
    }
    return NO;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        WEAK(self)
        
        self.gestureColor = [TPDialerResourceManager getColorForStyle:@"skinGestureDrawBoardStroke_color"];
        self.backgroundColor = [UIColor clearColor];
        self.bezierPath = [UIBezierPath bezierPath];
        self.pan = [[UIPanGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            
            WEAK(self)
            
            if (state == UIGestureRecognizerStatePossible) {
                NSLog(@"UIGestureRecognizerStatePossible");
                self.currentPoint = location;
            }
            
            if (state == UIGestureRecognizerStateFailed) {
                NSLog(@"UIGestureRecognizerStateFailed");
                //        self.currentPoint = location;
            }
            
            if (state == UIGestureRecognizerStateBegan) {
                weakself.gesturePoints = [NSMutableArray array];
                self.bezierPath = [UIBezierPath bezierPath];
                self.bezierPath.lineWidth = 5.f;
                [self.bezierPath moveToPoint:location];
                self.startPoint = location;
                
                
            }
            if (state == UIGestureRecognizerStateChanged) {
                if (fabs(location.x - self.startPoint.x) + fabs(location.y - self.startPoint.y) > 50){
                    self.pan.cancelsTouchesInView = YES;
                }
                
                
            }
            
            if(state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateRecognized){
                [weakself.gesturePoints addObject:[NSValue valueWithCGPoint:location]];
                [self.bezierPath addLineToPoint:location];
                [self setNeedsDisplay];
            }
            if (state == UIGestureRecognizerStateRecognized) {
                if (![self gestureLongEnough]) {
                    [weakself clearStroke];
                    NSLog(@"手势太短");
                }else{
                    Gesture *gesture = [[Gesture alloc] initWithGesture:@"input"];
                    Strokie* stroke = [[Strokie alloc] init];
                    stroke.pointsArray = weakself.gesturePoints;
                    [gesture addStrokieToGesture:stroke];
                    
                    GestureModel* gestureModel = [GestureModel getShareInstance];
                    GesturesResults *result = [gestureModel.mGestureRecognier recognizerGesture:gesture];
                    PhonePadModel *shared_phonepadmodel = [PhonePadModel getSharedPhonePadModel];
                    if (result.score <= GESTURE_RECOGNIZER_THREHOLD) {
                        [weakself.delegate onWillChangeGestureRecginzer:result.name];
                        [weakself clearStroke];
                    }else{
                        //                    [MBProgressHUD showText:@"手势未识别" toView:weakself.delegate];
                        if (result.name != nil && ![result.name isEqualToString:@""]) {
                            ItemType type = [GestureUtility getGestureItemType:result.name];
                            if (type != FirstItemType || [[[shared_phonepadmodel calllog_list] searchResults] count] != 0) {
                                NSString* backupGestureName = result.name;
                                [self.delegate backupGestureButton].hidden = NO;
                                [self.delegate addGestureButton].hidden = YES;
                                [[self.delegate backupGestureName] setText:[self createTitleFromName:backupGestureName]];
                                Gesture *gesture = [[GestureModel getShareInstance].mGestureRecognier getGesture:backupGestureName];
                                [[self.delegate backupGestureImage] setImage:[gesture convertToImage]];
                                [[self.delegate backupGestureButton] tpd_withBlock:^(id sender) {
                                    [weakself.delegate onWillChangeGestureRecginzer:result.name];
                                    [weakself clearStroke];
                                }];
                            }else{
                                [self.delegate backupGestureButton].hidden = YES;
                                [self.delegate addGestureButton].hidden = NO;
                            }
                        }else{
                            [self.delegate backupGestureButton].hidden = YES;
                            [self.delegate addGestureButton].hidden = NO;
                        }
                        
                        [weakself.delegate showAddGestureBar:YES];
                        NSLog(@"手势够长但未识别");
                    }
                }
                self.pan.cancelsTouchesInView = NO;
                self.startPoint = CGPointZero;
            }
            NSLog(@"pan, %@", NSStringFromCGPoint(location));
        }];
        
        self.gestureEnabled =  [GestureModel getShareInstance].isOpenSwitchGesture;
        [self refreshSwitchStatus];
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:N_GESTURE_SETTING_CLOSE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            weakself.gestureEnabled = YES;
            [weakself refreshSwitchStatus];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:N_GESTURE_SETTING_OPEN object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            weakself.gestureEnabled = NO;
            [weakself refreshSwitchStatus];
        }];
        self.pan.cancelsTouchesInView = NO;
        self.startPoint = CGPointZero;
    }
    return self;
}

-(void)refreshSwitchStatus{
    if (self.gestureEnabled) {
        [self addGestureRecognizer:self.pan];
    }else{
        [self removeGestureRecognizer:self.pan];
    }
}

- (void)drawRect:(CGRect)rect
{
    
    if (self.gesturePoints.count > 0 && self.gestureEnabled) {
        [self.gestureColor set];
        [self.bezierPath stroke];
    }
}

-(void)clearStroke{
    self.gesturePoints = [NSMutableArray array];
    [self setNeedsDisplay];
}
@end



@implementation TPDDialerPad
+(double)getHeight{
    return 36 + 50 + 60*4 + 96;
}

-(void)pasteNum{
    NSString* tmp = [[UIPasteboard generalPasteboard].string getNumberOnly];
    if (tmp != nil && ![tmp isEqualToString:@""]) {
        [self research:tmp];
    }else{
        [MBProgressHUD showText:@"剪贴板中没有内容"];
    }
}

-(instancetype)init{
    self = [super init];
    if (self) {
        WEAK(self)
        
        
//        self.ellipse = [[[EllipseView alloc] init] tpd_withHeight:20];
        
        
        self.inputChangeSignal = [RACSubject subject];
        
        [self createPart1];
        // 小键盘
        [self create9KeyPad];
        // 全键盘
        [self createFullPad];
        
        [self createPart2];
        
        
        [self createBtnBar];
        
        
        self.upperPartWrapper = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[self.part1,self.part2]];
        self.upperPartWrapper.clipsToBounds = YES;
        [self tpd_addSubviewsWithVerticalLayout:@[self.upperPartWrapper,self.btnBar] offsets:@[@0,@0]];
        
        
        [self showAllKeys:NO];
        
        
        
        [self createGestureBar];
        
        [self createBackgroundSkin];
        
    }
    return self;
}

-(void)createBackgroundSkin{
    self.backgroundImage = [[UIImageView alloc] initWithImage:[TPDialerResourceManager getImage:@"dailer_keyboard_t9_bj@2x.png"]];
    [self insertSubview:self.backgroundImage atIndex:0];
    
    [self.backgroundImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.bottom).offset(-[TPDDialerPad getHeight]);
        make.height.equalTo([TPDDialerPad getHeight]);
    }];

}
-(void)createPart1{
    self.ellipse = [[[UIView alloc] init] tpd_withHeight:36];
    self.ellipse.backgroundColor = [UIColor clearColor];
    

    
    self.numDialed = [[TPDNumberLabel alloc] init];
    [self.numDialed tpd_withText:@"直接拨号或开始搜索" color:[TPDialerResourceManager getColorForStyle:@"skinKeyboardInputHintText_color"] font:18];
    self.numDialed.textAlignment = NSTextAlignmentCenter;
    self.numDialed.numberOfLines = 0;
    self.numDialed.delegate = self;
    
    self.numAttrString = @"";
    self.numStr = @"";
    
    self.part1 = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[self.ellipse, [[[self.numDialed tpd_wrapperWithEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 30)] tpd_withBackgroundColor:[UIColor clearColor]] tpd_withHeight:50]]];
}

-(void)createPart2{
    self.gestureView = [[TPDGesturePad alloc] init];
    self.gestureView.delegate = self;
    
    UIView* padWrapper = [[[UIView alloc] init] tpd_withBackgroundColor:[UIColor clearColor]];
    [self.gestureView addSubview:self.keyPad];
    [self.gestureView addSubview:self.numPad];
    [padWrapper addSubview:self.gestureView];
    [self.keyPad makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.gestureView);
    }];
    [self.numPad makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.gestureView);
    }];
    [self.gestureView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(padWrapper);
    }];
    padWrapper.clipsToBounds = YES;
    
    self.part2 = padWrapper;
    [self.part2 updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(240);
    }];
    
//    [self.part2 tpd_withBorderWidth:3.f color:[UIColor yellowColor]];
}

-(void)create9KeyPad{
    WEAK(self)
    self.numPad = [[UIView alloc] init];
    NSArray* padKeys = @[
                         @"1     ",@"2 ABC ",@"3 DEF ",
                         @"4 GHI ",@"5 JKL ",@"6 MNO ",
                         @"7 PQRS",@"8 TUV ",@"9 WXYZ",
                         @"* 全键盘",@"0 +",@"# 粘帖",
                         ];
    NSArray* rawKeys = @[
                         @"1",@"2",@"3",
                         @"4",@"5",@"6",
                         @"7",@"8",@"9",
                         @"*",@"0",@"#",
                         ];
    NSArray* numKeyTone = @[
                            @1,@2,@3,
                            @4,@5,@6,
                            @7,@8,@9,
                            @10,@0,@11,
                            ];
    NSMutableArray* totalArr = [NSMutableArray array];
    
    double padButtonTextPadding = ([UIScreen mainScreen].bounds.size.width / 3 - 50)/2+5 ;
    for (int row=0; row<4; row++) {
        NSMutableArray* lineArr = [NSMutableArray array];
        for (int col=0; col<3; col++) {
            int index = row*3+col;
            UILabel* padKeyLabel = [UILabel tpd_commonLabel];
            padKeyLabel.textAlignment = NSTextAlignmentLeft;
            UIButton* padKeyButton = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
                // index
                

                [weakself research:[weakself.numStr stringByAppendingString:rawKeys[index]]];
                if ([AppSettingsModel appSettings].dial_tone) {
                    [CootekSystemService playCustomKeySound:[numKeyTone[index] integerValue]]; //按键声音
                }
            }];
            
            [padKeyButton setAttributedTitle:[NSAttributedString tpd_attributedString:padKeys[index] withRegExp:@"[0-9*#]" normalColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardMinorText_color"] normalFont:[UIFont fontWithName:@"keyboard" size:12] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardMainText_color"] highlightFone:[UIFont fontWithName:@"keyboard" size:30]] forState:UIControlStateNormal];
            
            
            [padKeyButton setAttributedTitle:[NSAttributedString tpd_attributedString:padKeys[index] withRegExp:@"[0-9*#]" normalColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardHighlightText_color"] normalFont:[UIFont fontWithName:@"keyboard" size:12] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardHighlightText_color"] highlightFone:[UIFont fontWithName:@"keyboard" size:30]] forState:UIControlStateHighlighted];
            padKeyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            padKeyButton.contentEdgeInsets = UIEdgeInsetsMake(0, padButtonTextPadding, 0, 0);
            
            
            
            [padKeyButton setBackgroundImage:[TPDialerResourceManager getImage:@"t9_plate_number_key_pressed@2x.png"] forState:UIControlStateHighlighted];
            [padKeyButton setBackgroundImage:[TPDialerResourceManager getImage:@"t9_plate_number_key_normal@2x.png"] forState:UIControlStateNormal];
            
            [padKeyButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                NSString* s = padKeys[index];
                if (state == UIGestureRecognizerStateBegan) {
                    if ([s rangeOfString:@"*"].location!=NSNotFound) {
                        // 切换全键盘
                        [weakself showAllKeys:YES];
                        [weakself research:@""] ;
                    }else if ([s rangeOfString:@"#"].location!=NSNotFound){
                        // 复制剪贴板
                        [weakself pasteNum];
                        
                    }else if([s rangeOfString:@"0"].location!=NSNotFound){
                        [weakself research:[weakself.numStr stringByAppendingString:@"+"]];
                    }
                }
                
            }]];
            [lineArr addObject:padKeyButton];
        }
        UIView* line = [[UIView tpd_horizontalGroupFullScreenForIOS7:lineArr horizontalPadding:0 verticalPadding:0 interPadding:0 weightArr:@[@1,@1,@1]] tpd_withHeight:60];
        [totalArr addObject:line];
    }
    [self.numPad tpd_addSubviewsWithVerticalLayout:totalArr offsets:@[@0,@0,@0,@0]];
    
}
-(void)createFullPad{
    WEAK(self)
    self.keyPad = [[UIView alloc] init];
    NSArray* alphabetKeys = @[
                              @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",],
                              @[@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",],
                              @[@" ",@"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L",@" "],
                              @[@"*\n9键",@"Z",@"X",@"C",@"V",@"B",@"N",@"M",@"#\n粘贴",],
                              ];
    NSArray* alphabetKeyTone = @[@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@1,],
                                 @[@2,@3,@4,@5,@6,@7,@8,@9,@1,@2,],
                                 @[@0,@3,@4,@5,@6,@7,@8,@9,@1,@2,@0],
                                 @[@3,@4,@5,@6,@7,@8,@9,@1,@2,],];
    NSMutableArray* totalArr = [NSMutableArray array];
    for (int row=0; row<4; row++) {
        NSMutableArray* lineArr = [NSMutableArray array];
        NSMutableArray* weightArr = [NSMutableArray array];
        for (int col=0; col<[alphabetKeys[row] count]; col++) {
            UIButton* padKeyButton = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
                NSString* s = alphabetKeys[row][col];
                if ([s rangeOfString:@"*"].location!=NSNotFound) {
                    // 切换小键盘
                    s=@"*";
                }else if ([s rangeOfString:@"#"].location!=NSNotFound){
                    s=@"#";
                }
                [weakself research:[weakself.numStr stringByAppendingString:s]];
                if ([AppSettingsModel appSettings].dial_tone) {
                    [CootekSystemService playCustomKeySound:[alphabetKeyTone[row][col] integerValue]]; //按键声音
                }
            }];
            
            [padKeyButton setAttributedTitle:[NSAttributedString tpd_attributedString:alphabetKeys[row][col] withRegExp:@"^[0-9A-Z#\\*]" normalColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardMinorText_color"] normalFont:[UIFont fontWithName:@"keyboard" size:9] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardMainText_color"] highlightFone:[UIFont fontWithName:@"keyboard" size:18]] forState:UIControlStateNormal];
            [padKeyButton setAttributedTitle:[NSAttributedString tpd_attributedString:alphabetKeys[row][col] withRegExp:@"^[0-9A-Z#\\*]" normalColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardHighlightText_color"] normalFont:[UIFont fontWithName:@"keyboard" size:9] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardHighlightText_color"] highlightFone:[UIFont fontWithName:@"keyboard" size:18]] forState:UIControlStateHighlighted];
            //                padKeyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            //                padKeyButton.contentEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
            [padKeyButton setBackgroundImage:[TPDialerResourceManager getImage:@"qwerty_plate_normal_key_pressed@2x.png"] forState:UIControlStateHighlighted];
            
            //                [padKeyButton setBackgroundImage:[TPDialerResourceManager getImage:@"qwerty_plate_normal_key_pressed@2x.png"] forState:UIControlStateHighlighted];
            [padKeyButton setBackgroundImage:[TPDialerResourceManager getImage:@"qwerty_plate_normal_key_normal@2x.png"] forState:UIControlStateNormal];
            
            [padKeyButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                NSString* s = alphabetKeys[row][col];
                if (state == UIGestureRecognizerStateBegan) {
                    if ([s rangeOfString:@"*"].location!=NSNotFound) {
                        // 切换小键盘
                        [weakself showAllKeys:NO];
                        [weakself research:@""];
                    }else if ([s rangeOfString:@"#"].location!=NSNotFound){
                        // 复制剪贴板
                        [weakself pasteNum];
                        
                    }else{
                        
                    }
                }
                
            }]];
            [lineArr addObject:padKeyButton];
            NSString* s = alphabetKeys[row][col];
            if ([s rangeOfString:@" "].location!=NSNotFound) {
                [weightArr addObject:@1.0f];
            }else if ([s rangeOfString:@"*"].location!=NSNotFound || [s rangeOfString:@"#"].location!=NSNotFound){
                [weightArr addObject:@3.01f];
                [padKeyButton setBackgroundImage:[TPDialerResourceManager getImage:@"qwerty_plate_star_key_pressed@2x.png"] forState:UIControlStateHighlighted];
                [padKeyButton setBackgroundImage:[TPDialerResourceManager getImage:@"qwerty_plate_star_key_normal@2x.png"] forState:UIControlStateNormal];
                padKeyButton.titleLabel.numberOfLines = 2;
                
            }else{
                [weightArr addObject:@2.0f];
            }
        }
        UIView* line = [[UIView tpd_horizontalGroupFullScreenForIOS7:lineArr horizontalPadding:0 verticalPadding:0 interPadding:0 weightArr:weightArr] tpd_withHeight:60];
        [totalArr addObject:line];
    }
    [self.keyPad tpd_addSubviewsWithVerticalLayout:totalArr offsets:@[@0,@0,@0,@0]];
    
}
-(void)createBtnBar{
    WEAK(self)
    self.collpaseImg = [[UIImageView alloc] initWithImage:[TPDialerResourceManager getImage:@"common_tabbar_dial_plate_hide@2x.png"]];
    UIButton* collapseBtn = [[[self.collpaseImg tpd_wrapper] tpd_wrapperWithButton] tpd_withBlock:^(id sender) {
        UIButton* btn = sender;
        [weakself foldPad:!btn.selected];
    }];
    
    UIView* dummyBtn = [[UIView alloc] init];
    UIButton* backspaceBtn = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        NSInteger length = [weakself.numStr length];
        if (length > 0) {
            [weakself research: [weakself.numStr substringToIndex:length-1]];
            if ([weakself.numStr length] == 0) {
                [weakself foldPad:NO];
            }
        }else{
            [weakself foldPad:YES];
        }
        if ([AppSettingsModel appSettings].dial_tone){
            [CootekSystemService playCustomKeySound:101];
        }
    }];
    [backspaceBtn setImage:[TPDialerResourceManager getImage:@"dialer_delete_normal@2x.png"] forState:UIControlStateNormal];
    [backspaceBtn setImage:[TPDialerResourceManager getImage:@"dialer_delete_pressed@2x.png"] forState:UIControlStateHighlighted];
    
    [backspaceBtn addGestureRecognizer:[[UILongPressGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateBegan) {
            [weakself research: @""];
            [weakself foldPad:NO];
        }
    }]];
    UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateRecognized) {
            [weakself research: @""];
            [weakself foldPad:NO];
        }
    }];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [backspaceBtn addGestureRecognizer:swipeRecognizer];
    
    
    self.btnBar = [[[UIView tpd_horizontalGroupWith:@[collapseBtn,dummyBtn,backspaceBtn] horizontalPadding:0 verticalPadding:0 interPadding:0 weightArr:@[@1,@1,@1]] tpd_withHeight:96] tpd_withBackgroundColor:[UIColor clearColor]];

    self.dialBtn = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        id vc = [UIViewController tpd_topViewController];
        [vc makeCallWithNumber:[PhonePadModel getSharedPhonePadModel].input_number];
        if ([AppSettingsModel appSettings].dial_tone){
            [CootekSystemService playCustomKeySound:101];
        }
        
    }];
    [self.dialBtn setBackgroundImage:[TPDialerResourceManager getImage:@"dialer_view_call_icon_normal@2x.png"] forState:UIControlStateNormal];
    [self.dialBtn setBackgroundImage:[TPDialerResourceManager getImage:@"dialer_view_call_icon_pressed@2x.png"] forState:UIControlStateHighlighted];
    
    [self.btnBar addSubview:self.dialBtn];
    
    self.dialBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 96 - 50);
    self.dialBtn.bounds = CGRectMake(0, 0, 94, 94);
    
}
-(void)createGestureBar{
    WEAK(self)
    
    // 取消
    UIButton* cancelAddGesture = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        [weakself showAddGestureBar:NO];
    }];
    UILabel* l1 = [[UILabel tpd_commonLabel] tpd_withText:@"G" color:[TPDialerResourceManager getColorForStyle:@"skinGestureOperation_text_color"]];
    l1.font = [UIFont fontWithName:@"iPhoneIcon4" size:30];
    UILabel* l2 = [[UILabel tpd_commonLabel] tpd_withText:@" 取消" color:[TPDialerResourceManager getColorForStyle:@"skinGestureOperation_text_color"] font:17];
    UIView* v = [UIView tpd_horizontalLinearLayoutWith:@[l1,l2] horizontalPadding:0 verticalPadding:0 interPadding:0];
    v.userInteractionEnabled = NO;
    [cancelAddGesture addSubview:v];
    [v makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(cancelAddGesture);
        make.height.equalTo(30);
    }];

    // 添加手势
    UIButton* addNewGesture = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        [weakself showAddGestureBar:NO];
        // 推入添加手势控制器
        GestureEditViewController *vc = [[GestureEditViewController alloc] initWithGesturePic];
        [[UIViewController tpd_topViewController].navigationController pushViewController:vc animated:YES];
    }];
    l1 = [[UILabel tpd_commonLabel] tpd_withText:@"w" color:[TPDialerResourceManager getColorForStyle:@"skinGestureOperation_text_color"]];
    l1.font = [UIFont fontWithName:@"iPhoneIcon4" size:30];
    
    l2 = [[UILabel tpd_commonLabel] tpd_withText:@" 添加手势" color:[TPDialerResourceManager getColorForStyle:@"skinGestureOperation_text_color"] font:17];
    v = [UIView tpd_horizontalLinearLayoutWith:@[l1,l2] horizontalPadding:0 verticalPadding:0 interPadding:0];
    v.userInteractionEnabled = NO;
    [addNewGesture addSubview:v];
    [v makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(addNewGesture);
        make.height.equalTo(30);
    }];
    self.addGestureButton = addNewGesture;
    
    self.addGestureBar = [UIView tpd_horizontalGroupFullScreenForIOS7:@[cancelAddGesture,addNewGesture] horizontalPadding:0 verticalPadding:0 interPadding:0 weightArr:@[@1,@1]];
    [self addSubview:self.addGestureBar];
    [self.addGestureBar makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.btnBar);
    }];
    UIView *middleLine = [[[UIView alloc] init] tpd_withBackgroundColor:[TPDialerResourceManager getColorForStyle:@"skinGestureOperation_line_color"]];
    [self.addGestureBar addSubview:middleLine];
    [middleLine makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.addGestureBar);
        make.width.equalTo(.3f);
        make.height.equalTo(self.addGestureBar).offset(-50);
    }];
    
    
    // 相似匹配
    self.backupGestureButton = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        
    }];
    self.backupGestureImage = [[[UIImageView alloc] init] tpd_withSize:CGSizeMake(36, 36)].cast2UIImageView;
    self.backupGestureName = [[UILabel tpd_commonLabel] tpd_withText:@"" color:[TPDialerResourceManager getColorForStyle:@"skinGestureOperation_text_color"] font:17];
    v = [UIView tpd_horizontalLinearLayoutWith:@[self.backupGestureImage,self.backupGestureName] horizontalPadding:0 verticalPadding:0 interPadding:0];
    v.userInteractionEnabled = NO;
    [self.backupGestureButton addSubview:v];
    [v makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.backupGestureButton);
        make.height.equalTo(30);
    }];
    [self.addGestureBar addSubview:self.backupGestureButton];
    [self.backupGestureButton makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(addNewGesture);
    }];
    self.backupGestureButton.hidden = YES;
    
    
    [addNewGesture setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    
    [self showAddGestureBar:NO];
}

-(UIView*)generateGestureGuideMaskView{
    WEAK(self)
    UIImageView* guildText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gesture_guild_text"]];
    guildText.contentMode = UIViewContentModeScaleAspectFit;
    UIView* container = [guildText tpd_maskViewContainer:^(id sender) {
        SET_VALUE_IN_DEFAULT(@1, @"gesture_guild_has_show");
        weakself.userInteractionEnabled = YES;
    }];
    guildText.tpd_maskView.alpha = 0.7f;
    
    [self.superview addSubview:container];
    [container makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superview);
    }];
    
    [guildText makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(container);
        make.bottom.equalTo(self.top);
        make.width.equalTo(container).offset(-100);
        make.height.equalTo(60);
    }];
    return container;
}

-(void)showAddGestureBar:(BOOL)b{
    if (b) {
        self.addGestureBar.hidden = NO;
        self.btnBar.hidden = YES;
        [self.gestureView cover];
        
        WEAK(self)
        // 5秒后复原
        [NSTimer bk_scheduledTimerWithTimeInterval:5 block:^(NSTimer *timer) {
            [weakself showAddGestureBar:NO];
            [self.gestureView decover];
        } repeats:NO];
    }else{
        self.addGestureBar.hidden = YES;
        self.btnBar.hidden = NO;
        // 清除手势
        [self.gestureView clearStroke];
        [self.gestureView decover];
    }
}
-(void)onWillChangeGestureRecginzer:(NSString *)key
{
    GestureActionType type = [GestureUtility getActionType:key];
    if(type != ActionNone) {
        NSString *number = [GestureUtility getNumber:key withAction:type];
        
        
        [self.delegate makeCallWithNumber:number];
        if ([AppSettingsModel appSettings].dial_tone){
            [CootekSystemService playCustomKeySound:101];
        };
        
        [self research:number];
    }
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

-(void)foldPad:(BOOL)b{
    UIButton* collapseBtn = (UIButton*)self.collpaseImg.superview.superview;

    if (b) {
        // 点击的时候处于展开状态
        NSInteger length = [self.numStr length];
        if (length > 0) {
            
            
            [self setAnchorPoint:CGPointMake(0.5, 1) forView:self.part2];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.part1.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0,240);
                self.backgroundImage.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0,240);
                self.part2.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1,0.001);
            } completion:^(BOOL finished){
                [self.collpaseImg setImage:[TPDialerResourceManager getImage:@"common_tabbar_dial_plate_show@2x.png"]];
                [self.part2 updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(0);
                }];
                [self setAnchorPoint:CGPointMake(0.5, 0) forView:self.part2];
                self.part2.transform = CGAffineTransformIdentity;
                self.part1.transform = CGAffineTransformIdentity;
                
                
            }];
            
            collapseBtn.selected = YES;
        }else{
            // 如果拨号为空，则直接收起全部
            [self.delegate showKeyPad:NO];
            [self.part2 updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(240);
            }];
            [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.part2];

            self.backgroundImage.transform = CGAffineTransformIdentity;
            self.part2.transform = CGAffineTransformIdentity;
            self.part1.transform = CGAffineTransformIdentity;

        }
    }else{
        if (collapseBtn.selected == NO) {
            return;
        }
        [self.part2 updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(240);
        }];
        self.part1.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0,240);
        self.part2.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1,0.001);
        self.part2.alpha = .0f;
        
        [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.part2];
        [UIView animateWithDuration:0.2 delay:0.01 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.backgroundImage.transform = CGAffineTransformIdentity;
            self.part1.transform = CGAffineTransformIdentity;
            self.part2.transform = CGAffineTransformIdentity;
            self.part2.alpha = 1;

        } completion:^(BOOL finished){
            [self.collpaseImg setImage:[TPDialerResourceManager getImage:@"common_tabbar_dial_plate_hide@2x.png"]];
            collapseBtn.selected = NO;
            self.backgroundImage.transform = CGAffineTransformIdentity;
            self.part2.transform = CGAffineTransformIdentity;
            self.part1.transform = CGAffineTransformIdentity;
            [self.part2 updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(240);
            }];
            
        }];

    }

}

-(void)showAllKeys:(BOOL)b{
    if (b) {
        self.keyPad.hidden = NO;
        self.numPad.hidden = YES;
        [self.backgroundImage setImage:[TPDialerResourceManager getImage:@"dailer_keyboard_qwert_bj@2x.png"]];
    }else{
        self.keyPad.hidden = YES;
        self.numPad.hidden = NO;
        [self.backgroundImage setImage:[TPDialerResourceManager getImage:@"dailer_keyboard_t9_bj@2x.png"]];
    }
}

-(void)research:(NSString*)numStr{
    self.numStr = numStr;
    [self.inputChangeSignal sendNext:self.numStr];
}

-(void)setNumStr:(NSString *)numStr{
    
    _numStr = numStr;
    
    
    if ([numStr isEqualToString:@""]) {
        [self.numDialed tpd_withText:@"直接拨号或开始搜索" color:[TPDialerResourceManager getColorForStyle:@"skinKeyboardInputHintText_color"] font:18];
    }else if([self.numAttrString isEqualToString:@""]){

        NSAttributedString* s = [NSAttributedString tpd_attributedString:numStr withRegExp:self.numAttrString normalColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardInputMainText_color"] normalFont:[UIFont systemFontOfSize:30] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardInputMinorText_color"] highlightFone:[UIFont systemFontOfSize:10]];
        [self.numDialed setAttributedText:s];
    }else{
        
        NSString*tmp = [numStr stringByReplacingOccurrencesOfString:@"*" withString:@"\\*"];
        tmp =[NSString stringWithFormat:@"^%@",tmp];
        NSString* numberToShow = [NSString stringWithFormat:@"%@\n%@",numStr, self.numAttrString];
        NSAttributedString* s = [NSAttributedString tpd_attributedString:numberToShow withRegExp:tmp normalColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardInputMinorText_color"]  normalFont:[UIFont systemFontOfSize:10] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinKeyboardInputMainText_color"] highlightFone:[UIFont systemFontOfSize:30]];
        [self.numDialed setAttributedText:s];
    }
    
    
    if (self.numStr.length > 0) {
        [self.backspaceImg setImage:[UIImage imageNamed:@"dialer_delete_fg_h"]];
    }else{
        [self.backspaceImg setImage:[UIImage imageNamed:@"dialer_delete_fg"]];
        
    }
    
    
    
    
}

-(void)refreshAttrLabel{
    NSString *callerIDString = nil;
    CallerIDInfoModel *callerInfo = [PhonePadModel getSharedPhonePadModel].caller_id_info;
    if(callerInfo != nil &&
       [callerInfo isCallerIdUseful]){
        callerIDString = callerInfo.name;
        if([FunctionUtility isNilOrEmptyString:callerIDString]) {
            callerIDString = callerInfo.localizedTag;
        }
    }
    
    NSString *attrString = [PhonePadModel getSharedPhonePadModel].number_attr;
    NSString *numberAttrString = nil;
    if(callerIDString.length>0 && attrString.length > 0){
        numberAttrString = [NSString stringWithFormat:@"%@  %@",callerIDString,attrString];
    }else if(callerIDString.length > 0){
        numberAttrString = callerIDString;
    }else if(attrString.length > 0){
        numberAttrString = attrString;
    }
    if(numberAttrString == nil){
        self.numAttrString = @"";
        self.numStr = self.numStr;
    }else if(![numberAttrString isEqualToString:self.numStr]){
        self.numAttrString = numberAttrString;
        self.numStr = self.numStr;
    }
}
@end

