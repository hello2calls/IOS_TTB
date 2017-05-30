//
//  GestureEditViewController.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "GestureEditViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "GestureInputView.h"
#import "GestureModel.h"
#import "CootekNotifications.h"
#import "GestureUtility.h"
#import "ImageViewUtility.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "UserDefaultsManager.h"
#import "GesturePersonPickerViewController.h"
#import "GestureSettingsViewController.h"
#import "UIButton+DoneButton.h"
#import "SelectModel.h"
#import "PersonDBA.h"
#import "ContactSort.h"
#import "Person.h"
#import "PhonePadModel.h"
#import <QuartzCore/QuartzCore.h>
#import "KeypadView.h"
#import "FunctionUtility.h"
#import <RDVTabBarController.h>
#import "TPDPhoneCallViewController.h"

#define MIN_POINT_COUNT 16
#define VIEW_REDRAW_TAG 400
#define VIEW_FISRTUSE_TAG 402
#define RADIUS 80
#define DURATION 5
#define IPHONE6 TPScreenHeight() > 600

@interface GestureEditViewController ()
@property(nonatomic, retain)GestureModel *gestureModel;
@property(nonatomic, assign)BOOL isFromKeyboard;
@property(nonatomic, retain)TPUIButton *saveBtn;
@property(nonatomic, retain)UILabel *validateLabel;
@property(nonatomic, retain)UILabel *promptLabel;
@property(nonatomic, retain)UILabel *gestureLabel;
@property(nonatomic,retain)GestureInputView *mInputGestureView;
@property(nonatomic,retain)NSString *gestureKey;
@property(nonatomic,retain)UIImage *iconImage;
@property(nonatomic,retain)Gesture *mGesture;
@property(nonatomic,retain)GesturesResults *result;
@property(nonatomic,assign)BOOL hasAddedContact;
@property(nonatomic,assign)BOOL hasAddedGesture;
@property(nonatomic,retain)UIButton *addContactBtn;
@property(nonatomic,assign)GestureActionType actionKey;
@property(nonatomic,readonly)CAShapeLayer *circle;
@property(nonatomic,retain)UIView *circleHandView;
@property(nonatomic,assign)BOOL hasFinishedDemo;
@property(nonatomic,readonly)ContactCacheDataModel *contactItem;
@property(nonatomic,retain)KeypadView *T9_phonePad;
@property(nonatomic,retain) UIImageView *addView;
@property(nonatomic,retain)UIImageView *gestureImageView;
@property(nonatomic,retain)UIView *contentView;
//@property(nonatomic,retain)UIView *noContactView;
@end

@implementation GestureEditViewController

@synthesize gestureModel;
@synthesize isFromKeyboard;
@synthesize isEditGesture;
@synthesize saveBtn;
@synthesize validateLabel;
@synthesize promptLabel;
@synthesize gestureLabel;
@synthesize mInputGestureView;
@synthesize gestureKey;
@synthesize mGesture;
@synthesize result;
@synthesize hasAddedContact;
@synthesize hasAddedGesture;
@synthesize shouldClearGesture;
@synthesize addContactBtn;
@synthesize iconImage;
@synthesize actionKey;
@synthesize circle;
@synthesize hasFinishedDemo;
@synthesize circleHandView;
@synthesize contactItem;
@synthesize signedContact;

- (id)init
{
    self = [super init];
    if (self) {
        isFromKeyboard = NO;
        hasAddedContact = NO;
        hasAddedGesture = NO;
        signedContact = NO;
        isEditGesture = NO;
        Gesture *tmpGesture = [[Gesture alloc] initWithGesture:self.gestureKey];
        self.mGesture = tmpGesture;
        self.shouldClearGesture = YES;
        self.addView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _addView.backgroundColor =
        [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"GestureEditViewController_addcircle_normal_color"];
        _addView.contentMode = UIViewContentModeCenter;
        _addView.image = [TPDialerResourceManager getImage:@"gesture_dial_add_normal@2x.png"];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    NSString *flag = (NSString *) [[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"statusBar_isDefaultStyle"];
    if ([flag isEqualToString:@"1"]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (id)initWithGesturePic
{
    self = [self init];
    if (self) {
        isFromKeyboard = YES;
        self.shouldClearGesture = NO;
    }
    return self;
}

- (id) initWithGestureName:(NSString *)name
{
    self = [self init];
    if (self) {
        hasAddedContact = YES;
        self.gestureKey = name;
        Gesture *tmpGesture = [[Gesture alloc] initWithGesture:self.gestureKey];
        self.mGesture = tmpGesture;
        self.shouldClearGesture = YES;
        if ([PersonDBA getImageByRecordID :[GestureUtility getPersonID:tmpGesture.name withAction:actionKey]]) {
            self.iconImage =[PersonDBA getImageByRecordID :[GestureUtility getPersonID:tmpGesture.name withAction:actionKey]];
        } else {
            self.iconImage =[PersonDBA getDefaultImageWithoutNameByPersonID:[GestureUtility getPersonID:tmpGesture.name withAction:actionKey]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
  
    self.fd_interactivePopDisabled = YES;
    self.hasFinishedDemo = YES;
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    // HeaderBar
    HeaderBar* headBar = [[HeaderBar alloc] initHeaderBar] ;
    [headBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headBar];
    
    // HeaderBar - title
    UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-198)/2, TPHeaderBarHeightDiff(), 198, 45)];
    [headerTitle setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    headerTitle.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.text = NSLocalizedString(@"Add gesture",@"");
    if (isEditGesture) {
        headerTitle.text = NSLocalizedString(@"Edit gesture",@"");
    }
    
    [headBar addSubview:headerTitle];
 
    // HeaderBar - save
    TPHeaderButton *btn = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(TPScreenWidth()-50, 0, 50, 45)];
    [btn setTitle:NSLocalizedString(@"Save", @"") forState:UIControlStateNormal];
    UIColor *normalColor = [TPDialerResourceManager getColorForStyle:@"header_btn_color"];
    UIColor *disabledColor = [TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"];
    [btn setTitleColor:normalColor forState:UIControlStateNormal];
    [btn setTitleColor:disabledColor forState:UIControlStateDisabled];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    btn.enabled = NO;
    self.saveBtn = btn;
    [self.saveBtn addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [headBar addSubview:self.saveBtn];
    
    
    if(isVersionSix) {
        // back button
        UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backBtn setTitle:@"0" forState:UIControlStateNormal];
        [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
        [backBtn setTitleColor:tColor forState:UIControlStateNormal];
        backBtn.autoresizingMask = UIViewAutoresizingNone;
        [backBtn addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [headBar addSubview:backBtn];
        
        headerTitle.textColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
        
        normalColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        disabledColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_ht_color"];
        [self.saveBtn setTitleColor:normalColor forState:UIControlStateNormal];
        [self.saveBtn setTitleColor:disabledColor forState:UIControlStateDisabled];

    } else {
        // HeaderBar - cancel
        TPHeaderButton *cancelBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        [cancelBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
        [cancelBtn addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [headBar addSubview:cancelBtn];
        
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGesture:)
                                                 name:N_GESTURE_ITEM_SELECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPerson:)
                                                 name:N_GESTURE_PERSON_SELECTED object:nil];
    
    [self loadPersonView];
    [self loadGestureInputView];
    
    if ((![UserDefaultsManager boolValueForKey:IS_FIRST_DIFINE_GESTURE])&&!isFromKeyboard&&!signedContact) {
        [self demo];
    }
}

- (void) loadPersonView
{
    //detail area
    [_contentView removeFromSuperview];
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(),TPAppFrameHeight()-(TPKeypadHeight()+15)-TPHeaderBarHeight())];
    [_contentView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    [self.view addSubview:_contentView];
    
    //icon
    _gestureImageView = [[UIImageView alloc] init];
    _gestureImageView.frame = CGRectMake(TPScreenWidth()/2-36.5, _contentView.frame.size.height/2 - 69, 75, 75);

    if (TPScreenHeight() > 500) {
        _gestureImageView.frame = CGRectMake(TPScreenWidth()/2-50, _contentView.frame.size.height/2 - 100, 100, 100);
    }
    _gestureImageView.layer.cornerRadius=_gestureImageView.frame.size.width/2;
    _gestureImageView.tag  = 1000;
    _gestureImageView.layer.masksToBounds= YES;
    _gestureImageView.image = self.iconImage;
    if ([GestureUtility getPersonID:self.mGesture.name withAction:actionKey] == 0){
        _gestureImageView.hidden = YES;
    }else{
        _gestureImageView.hidden = NO;
    }
    [_contentView addSubview:_gestureImageView];
    
    UIButton *chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    chooseBtn.frame = CGRectMake(TPScreenWidth()/2-37.5, _contentView.frame.size.height/2 - 70, 75, 75);

    if (TPScreenHeight() > 500) {
        chooseBtn.frame = CGRectMake(TPScreenWidth()/2-50, _contentView.frame.size.height/2 - 95, 100, 100);
    }
    
    self.addContactBtn = chooseBtn;
    if (signedContact) {
        addContactBtn.hidden = YES;
    }
    [addContactBtn addTarget:self action:@selector(gestureActionPick) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_addView];
    [_contentView addSubview:addContactBtn];
    
    [addContactBtn setTitleEdgeInsets:UIEdgeInsetsMake(55, 0, 0, 0)];
    if (TPScreenHeight() > 500){
        [addContactBtn setTitleEdgeInsets:UIEdgeInsetsMake(67+5 , 0, 0, 0)];
    }
    addContactBtn.titleLabel.backgroundColor = [UIColor clearColor];
    addContactBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    addContactBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addContactBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"GestureChangePersonLabel_text_color"] forState:UIControlStateNormal];
    
    
    //descrption
    UILabel* descriptionLabel = [[UILabel alloc] initWithFrame:
                                 CGRectMake(0, _contentView.frame.size.height/2+12, TPScreenWidth(), 20)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    descriptionLabel.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"GestureEditViewController_addGestureButtonText_color" needCache:NO];
    
    descriptionLabel.font = [UIFont systemFontOfSize:CELL_FONT_LARGE];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    if ([GestureUtility getPersonID:self.mGesture.name withAction:actionKey] == 0){
        _addView.hidden = NO;
        UIImage *iameg =[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"] withFrame:chooseBtn.bounds];
        [chooseBtn setBackgroundImage:iameg  forState:UIControlStateHighlighted];
        
        descriptionLabel.text =NSLocalizedString(@"Choose a contact", @"");
    } else {
        _addView.hidden = YES;

        [chooseBtn setBackgroundImage:[[TPDialerResourceManager sharedManager]
                                       getImageByName:@"btn-gesture-chooseContact@2x.png"]
                             forState:UIControlStateNormal];
        [chooseBtn setBackgroundImage:[[TPDialerResourceManager sharedManager]
                                       getImageByName:@"btn-gesture-chooseContact-h@2x.png"]
                             forState:UIControlStateHighlighted];
        [addContactBtn setTitle:NSLocalizedString(@"Change contact", @"") forState:UIControlStateNormal];
        descriptionLabel.text = [GestureUtility getName:self.mGesture.name];
    }
    addContactBtn.layer.cornerRadius =addContactBtn.frame.size.height/2;
    addContactBtn.layer.masksToBounds = YES;
    _addView.frame = chooseBtn.frame;
    _addView.layer.cornerRadius =addContactBtn.frame.size.height/2;
    _addView.layer.masksToBounds = YES;

    _gestureImageView.center = chooseBtn.center;
    [_contentView addSubview:descriptionLabel];
    
    descriptionLabel = [[UILabel alloc] initWithFrame:
                        CGRectMake(0, _contentView.frame.size.height/2+30, TPScreenWidth(), 20)];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"GestureEditViewController_gestureNameButtonText_color" needCache:NO];
    descriptionLabel.font = [UIFont systemFontOfSize:CELL_FONT_SMALL];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.text = [GestureUtility getPhoneNumber:self.mGesture.name];
    [_contentView addSubview:descriptionLabel];
    
    UILabel *tmpValidateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,_contentView.frame.size.height-50, TPScreenWidth(), 30)];
    tmpValidateLabel.textAlignment = NSTextAlignmentCenter;
    tmpValidateLabel.textColor = [[TPDialerResourceManager sharedManager]
                                  getResourceByStyle:@"GestureEditViewValidateLabel_text_color" needCache:NO];
    tmpValidateLabel.font = [UIFont systemFontOfSize:CELL_FONT_SMALL];
    tmpValidateLabel.backgroundColor = [UIColor clearColor];
    tmpValidateLabel.text = self.validateLabel.text;
    self.validateLabel = tmpValidateLabel;
    [_contentView addSubview:self.validateLabel];
}

-(CGRect)getPhonePadFrame{
    NSDictionary *dict = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"KeyPadBgViewT9_style"];
    NSString *bgImageName = [dict objectForKey:BACK_GROUND_IMAGE];
    UIImage *bgImage = nil;
    if (bgImageName) {
        bgImage = [TPDialerResourceManager getImage:bgImageName];
    }
    CGFloat keyPadHeight = TPKeypadHeight();
    if (bgImage) {
        keyPadHeight = TPScreenWidth() / bgImage.size.width * bgImage.size.height;
    }
    CGFloat originY = TPAppFrameHeight()- keyPadHeight +TPHeaderBarHeightDiff();
    
    CGRect phonePadFrame =  CGRectMake(0, originY, TPScreenWidth(), keyPadHeight);
    return phonePadFrame;
}

- (void) loadGestureInputView
{


    _T9_phonePad = [[KeypadView alloc] initWithFrame:[self getPhonePadFrame] andKeyPadType:T9KeyBoardType
                                        andDelegate:nil];
    _T9_phonePad.userInteractionEnabled = NO;

    [self.view addSubview:_T9_phonePad];
    
    
    GestureInputView *tmpInput = [[GestureInputView alloc]
                                  initWithFrame:[self getPhonePadFrame]];
    self.mInputGestureView =tmpInput;
    self.mInputGestureView.delegate = self;
    
    if (_gestureImageView!=nil) {
        _T9_phonePad.hidden = YES;
        
        
    }
    mInputGestureView.pressView.hidden = NO;
    [self.view addSubview:mInputGestureView];
    
    self.gestureModel = [GestureModel getShareInstance];
    
    if (!shouldClearGesture){
        self.mInputGestureView.stroke.pointsArray =[NSMutableArray arrayWithArray:self.gestureModel.pointArray];
        [self.mInputGestureView  refreshDraw];
    }
    self.shouldClearGesture = NO;
}

- (void) demo
{
    hasFinishedDemo = NO;
    
    NSArray *tmpArray = [Person queryAllContacts];
    for (int i=0;i<[tmpArray count];i++) {
        contactItem = [tmpArray objectAtIndex:i];
        int count = [contactItem.phones count];
        if ( count > 0) {
            NSString *key = [GestureUtility serializerName:[[contactItem.phones objectAtIndex:0] number]
                                              withPersonID:contactItem.personID
                                                withAction:actionKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_PERSON_SELECTED object:key];
            break;
        }
    }
    
    CGFloat Y = _T9_phonePad.frame.origin.y;
    UILabel *tmpPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, Y-24 , TPScreenWidth()-5, 24)];
    tmpPromptLabel.textAlignment = NSTextAlignmentLeft;
    tmpPromptLabel.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"GestureEditViewController_gestureNameButtonText_color" needCache:NO];
    tmpPromptLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
    tmpPromptLabel.textAlignment = NSTextAlignmentLeft;
    tmpPromptLabel.backgroundColor = [UIColor clearColor];;
    tmpPromptLabel.text = NSLocalizedString(@"demo prompt1",@"画个图形代表Ta");
    tmpPromptLabel.adjustsFontSizeToFitWidth = YES;
    self.promptLabel = tmpPromptLabel;
    [self.view addSubview:self.promptLabel];
    
    [self drawCircle];
    
    [self drawHand];
}

- (void) drawCircle
{
    circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 10, 2.0*RADIUS, 2.0*RADIUS)
                                             cornerRadius:RADIUS].CGPath;
    NSInteger x = TPScreenWidth()/2-RADIUS;
    NSInteger y = TPHeightFit(244)+110-RADIUS + TPHeaderBarHeightDiff()-30;
    circle.position = CGPointMake(x, y);
    circle.fillColor = [UIColor clearColor].CGColor;
    UIColor *circleColor = [[TPDialerResourceManager sharedManager]getResourceByStyle:@"gestureDrawBoard_stroke_color"];
    circle.strokeColor = circleColor.CGColor;
    circle.lineWidth = 5.0;
    [self.view.layer addSublayer:circle];
    
    CAKeyframeAnimation *drawAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.values = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:1.0f], nil];
    drawAnimation.timingFunctions = [NSArray arrayWithObjects:
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], nil];
    drawAnimation.duration            = DURATION;
    drawAnimation.repeatCount         = 1.0;
    drawAnimation.removedOnCompletion = NO;
    drawAnimation.delegate = self;
    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
}

- (void)drawHand
{
    circleHandView = [[UIView alloc]
                      initWithFrame:CGRectMake(TPScreenWidth()/2.0-43, TPHeightFit(244)+110-RADIUS-38, 86, 76)];
    UIImageView *handImageView = [[UIImageView alloc] initWithFrame:CGRectMake(43, 33 + TPHeaderBarHeightDiff()-30, 43, 43)];
    handImageView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"gesture-hand@2x.png"];
    [circleHandView addSubview:handImageView];
    [self.view addSubview:circleHandView];
    
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, NULL, TPScreenWidth()/2.0, TPHeightFit(244)+110, RADIUS, -0.5*M_PI, 1.5*M_PI, 0);
    CGPathCloseSubpath(circlePath);
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    //duration和上面的circle时间成1.5比例，原因未知。。。
    [anim setDuration:DURATION * (IPHONE6 ? 1.25 : 1.5)];
    [anim setPath:circlePath];
    CFRelease(circlePath);
    circlePath = nil;
    [circleHandView.layer addAnimation:anim forKey:@"position"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        self.promptLabel.text = NSLocalizedString(@"demo prompt2",@"试着画个图形");
    }
    if (!hasFinishedDemo) {
        [circle removeFromSuperlayer];
        [circleHandView removeFromSuperview];
        hasFinishedDemo = YES;
    }
}

- (void)gestureActionPick
{
    if (signedContact) {
        return;
    }
    if (!hasFinishedDemo) {
        [circle removeFromSuperlayer];
        [circleHandView removeFromSuperview];
        hasFinishedDemo = YES;
    }
    GesturePersonPickerViewController *personGestureController = [[GesturePersonPickerViewController alloc]
                                                                  initWithPopToRoot:NO];
    [self.navigationController  pushViewController:personGestureController animated:YES];
}

- (void)reloadPerson:(NSNotification*)noti
{
    hasAddedContact = YES;
    self.gestureKey = noti.object;
    Gesture *tmpGesture = [[Gesture alloc] initWithGesture:self.gestureKey];
    self.mGesture = tmpGesture;
    self.shouldClearGesture = NO;
    if ([PersonDBA getImageByRecordID :[GestureUtility getPersonID:tmpGesture.name withAction:actionKey]]) {
        self.iconImage = [PersonDBA getImageByRecordID :[GestureUtility getPersonID:tmpGesture.name
                                                                         withAction:actionKey]];
    } else {
        self.iconImage = [PersonDBA getDefaultImageWithoutNameByPersonID:[GestureUtility getPersonID:tmpGesture.name withAction:actionKey]];
    }
    [self loadPersonView];
    if (hasAddedGesture) {
        self.saveBtn.enabled = YES;
    }
}

- (void)reloadGesture:(NSNotification*)noti
{
    NSArray *pointArray = noti.object;
    NSMutableArray *tmpPopints =[NSMutableArray arrayWithArray:pointArray];
    if (pointArray) {
        self.validateLabel.text = @"";
        self.mInputGestureView.stroke.pointsArray = [NSMutableArray arrayWithArray:tmpPopints];
        [self.mInputGestureView refreshDraw];
    }
}

- (void)saveButtonClicked
{
    cootek_log(@"mInputGestureView.stroke.pointsArray = %d",[self.mInputGestureView.stroke.pointsArray count]);
    [self.mGesture addStrokieToGesture:self.mInputGestureView.stroke];
    [self.gestureModel.mGestureRecognier addGesture:self.mGesture];
    [UserDefaultsManager setIntValue:[[self.gestureModel.mGestureRecognier getGestureList] count] forKey:HOW_MUCH_GESTURES];
    NSLog(@"gestures =    %d",[UserDefaultsManager intValueForKey:HOW_MUCH_GESTURES]);
    [self.mGesture removeAllStrokies];
    [self checkFirstGestureUsage];
}

- (void)checkFirstGestureUsage
{
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        if (![UserDefaultsManager boolValueForKey:IS_FIRST_DIFINE_GESTURE]) {
            [UserDefaultsManager setObject:[NSNumber numberWithBool:YES] forKey:IS_FIRST_DIFINE_GESTURE];
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"You can call your contact with the new gesture now.",@"")];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(msg,@"")
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Ok",@"" )
                                                  otherButtonTitles:NSLocalizedString(@"Try later",@"" ), nil];
            [alert show];
            alert.tag = VIEW_FISRTUSE_TAG;
        }
        else {
            [self goBack];
        }
    }else{
        if (![UserDefaultsManager boolValueForKey:IS_FIRST_DIFINE_GESTURE]) {
            [UserDefaultsManager setObject:[NSNumber numberWithBool:YES] forKey:IS_FIRST_DIFINE_GESTURE];
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"You can call your contact with the new gesture now.",@"")];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(msg,@"")
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Ok",@"" )
                                                  otherButtonTitles:NSLocalizedString(@"Try later",@"" ), nil];
            [alert show];
            alert.tag = VIEW_FISRTUSE_TAG;
        }
        else {
            [self goBack];
        }
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        switch (alertView.tag) {
            case VIEW_FISRTUSE_TAG:{
                if (buttonIndex == 0) {
                    //Confirm
                    
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"FIRST_GESTURE_USE" object:nil];
                    });
                    
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_SETTING_CLOSE object:nil];
                }else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_SETTING_CLOSE object:nil];
                    [self goBack];
                }
                break;
            }
            default:
                break;
        }
    }else{
        switch (alertView.tag) {
            case VIEW_FISRTUSE_TAG:{
                if (buttonIndex == 0) {
                    //Confirm
                    [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_WAIT];
                    [self goBackToRoot];
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_JUMP_TO_REGISTER_INDEX_PAGE object:@"1" userInfo:@{@"show":@"add_Dial_GUSTRE_View"}];
                    [[PhonePadModel getSharedPhonePadModel] setPhonePadShowingState:YES];
                }else {
                    [self goBack];
                }
                break;
            }
            default:
                break;
        }
    }
    
}

- (void)beginDraw
{
    _T9_phonePad.hidden = YES;
    self.validateLabel.text = @"";
    self.gestureLabel.text = @"";
    self.promptLabel.text = @"";
    if (!hasFinishedDemo) {
        [circle removeFromSuperlayer];
        [circleHandView removeFromSuperview];
        hasFinishedDemo = YES;
    }
}

- (void)didFinishDraw
{
    [self.validateLabel setFrame:CGRectMake(0,_contentView.frame.size.height-50, TPScreenWidth(), 30)];
    if ([self.mInputGestureView.stroke.pointsArray count] >= MIN_POINT_COUNT||[self getPointBeginAndEndLengthWithArray]>50) {
        [self.mGesture addStrokieToGesture:self.mInputGestureView.stroke];
        self.result = [self.gestureModel.mGestureRecognier recognizerGesture:self.mGesture];
        if (result.score <= GESTURE_RECOGNIZER_THREHOLD) {
            if (![result.name isEqualToString:mGesture.name]) {
                self.promptLabel.text = @"";
                self.validateLabel.text = NSLocalizedString(@"The gesture has been used.",@"");
                hasAddedGesture = NO;
                self.saveBtn.enabled = NO;
            }
        }else {
            hasAddedGesture = YES;
        }
        [self.mGesture removeAllStrokies];
    }else {
        self.saveBtn.enabled = NO;
        self.promptLabel.text = @"";
        self.validateLabel.text =  NSLocalizedString(@"Oops, too short. Please draw more.",@"");
        hasAddedGesture = NO;
    }
    if (hasAddedGesture) {
        if (!hasAddedContact) {
        } else {
            self.saveBtn.enabled = YES;
        }
    }
}

-(CGFloat)getPointBeginAndEndLengthWithArray{
    NSArray *array =self.mInputGestureView.stroke.pointsArray;
   if( array.count<2) {
        return 0;
    }
    CGPoint firstPoint = [array[0] CGPointValue];
    CGPoint endPoint = [array[array.count-1] CGPointValue];
    CGFloat length =fabs(firstPoint.x-endPoint.x)>fabs(firstPoint.y-endPoint.y)?fabs(firstPoint.x-endPoint.x):fabs(firstPoint.y-endPoint.y);
    return length;
}

- (void)cancelButtonClicked
{
    [self goBack];
}

- (void)goBackToRoot
{
    _gestureImageView = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goBack
{
    _gestureImageView = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_GESTURE_ITEM_SELECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_GESTURE_PERSON_SELECTED object:nil];
}

-(void)dealloc
{
    [SkinHandler removeRecursively:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
