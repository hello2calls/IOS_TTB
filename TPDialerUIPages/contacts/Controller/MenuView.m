//
//  MenuView.m
//  旋转动画(手机银行首页)
//
//  Created by H L on 2016/12/7.
//  Copyright © 2016年 LH. All rights reserved.
//

#import "MenuView.h"
#import "BtnModel.h"
#import <BlocksKit.h>
#import "UsageConst.h"
#import "DialerUsageRecord.h"
#import "UserDefaultsManager.h"
#import "UIButton+Block.h"
#define Radius         90
#define offSetRotation (2 * TPD_M_PI/5) // 起点角度
#define TPD_M_PI       M_PI
#define gapRotation    TPD_M_PI*55/180          // 间隔角度
#define KWith          [UIScreen mainScreen].bounds.size.width
#define KHigh          [UIScreen mainScreen].bounds.size.height
#define kBlueColor     [UIColor colorWithRed:3/255.f green:169/255.f blue:244/255.f alpha:1]

typedef void (^ChangStaus)(BOOL isChange)  ;

@interface MenuView ()
// 按钮数组
@property (nonatomic ,strong)NSMutableArray *btnArray;
@property (nonatomic ,strong)NSMutableArray *btnStatusArray;            //是否有需要点亮小红点状态数组 （0， 否 1， 是 ）
@property (nonatomic ,assign)CGFloat        rotationAngleInRadians;
// 是否展示
@property (nonatomic, assign)BOOL           isShow;
@property (nonatomic, strong)NSMutableArray *nameArray ;                //button 上的字体icon
@property (nonatomic, strong)NSMutableArray *imageArray ;               //button 上的icon图片
@property (nonatomic, strong)NSMutableArray *hImageArray ;              //带小红点icon
@property (nonatomic, strong)UIImageView    *imageView;
@property (nonatomic, strong)UIButton       *stepOneButton;
@property (nonatomic, strong)UIButton       *button;
@property (nonatomic, strong)NSMutableArray *array;                     //步骤1 正常图片组
@property (nonatomic, strong)NSMutableArray *array1;                    //步骤2 图片组
@property (nonatomic, strong)NSMutableArray *array2;                    //步骤3 图片组
@property (nonatomic, strong)NSMutableArray *hArray;                    //步骤1 运营图片组
@property (nonatomic, strong)NSTimer        *timer1;
@property (nonatomic, strong)NSTimer        *timer2;
@property (nonatomic, strong)NSTimer        *timer3;
@property (nonatomic, assign)int            step;
@property (nonatomic, copy  )ChangStaus     changeStatus;
@end

@implementation MenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //        self.frame = frame;
        //        self.layer.cornerRadius = self.frame.size.width / 2 ;
        self.Witch = self.frame.size.width;
        self.btnArray = [NSMutableArray new];
        self.nameArray = [NSMutableArray new];
        self.isShow = NO;
        
    }
    return self;
}




- (void)BtnType:(FTT_RoundviewType)type BtnWitch:(CGFloat)BtnWitch  adjustsFontSizesTowidth:(BOOL)sizeWith  msaksToBounds:(BOOL)msak conrenrRadius:(CGFloat)radius titileColor:(UIColor *)titleColor {
    [self checkButtonIsNew];
    
    self.array = [NSMutableArray new];
    self.Witch = 220;
    CGFloat r = Radius;
    CGFloat x = self.Witch  / 2 ;
    CGFloat y = self.Witch  / 2 ;
    for (int i = 0 ; i < self.nameArray.count ; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //        btn.frame = CGRectMake(0, 0, BtnWitch, BtnWitch);
        btn.layer.cornerRadius = BtnWitch/2;
        CGFloat  rotation = - gapRotation * i - offSetRotation;
        btn.layer.shadowColor = [UIColor blackColor].CGColor;
        btn.layer.shadowOffset = CGSizeMake(0, 10);
        btn.layer.shadowRadius = 5;
        btn.layer.shadowOpacity = .3;
        //        btn.center = CGPointMake(x + r * cos(rotation), y + r *sin(rotation));
        if (i < _nameArray.count) {
            [self addSubview:btn];
            [btn makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(BtnWitch);
                make.centerX.equalTo(self.left).offset(x + r * cos(rotation));
                make.centerY.equalTo(self.top).offset(y + r *sin(rotation));
            }];
            
        }
        
        self.BtnWitch = BtnWitch;
        if (type == FTT_RoundviewTypeCustom) {
            [btn setImage:[UIImage imageNamed:[self.btnStatusArray[i] isEqualToString:@"1"]?self.hImageArray[i]:self.imageArray[i]] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor clearColor];

        }else {
            [btn setTitle:[NSString stringWithFormat:@"%@",self.nameArray[i]] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon5" size:30];
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
        }
        
        [btn addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
           //替换本地按钮红点状态
            if ([self checkButtonIsNew]){
                if ([[self.btnStatusArray objectAtIndex:i] intValue] == 1) {
                    NSMutableArray *array = [[MenuView checkButtonNew] mutableCopy];
                    array[i] = @"0";
                    [UserDefaultsManager setObject:array forKey:WELCOME_ASSISTANT_BUTTON_STATUS];
                    self.btnStatusArray = [[MenuView checkButtonNew] mutableCopy];
                    [self reloadStatus];
                }
            }
            _isShow = YES ;
            NSString *name = _nameArray[i];
            self.back(i,name);
        }];
        [_btnArray addObject:btn];
        
    }
    
    
    self.button = [[UIButton alloc] init ];//WithFrame:CGRectMake(0, 0, 66, 66)];
    [self addSubview:self.button];
    
    [self.button makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.center);
        make.width.height.equalTo(66);
    }];
    
    //    self.button.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.button.backgroundColor = [UIColor clearColor];
    self.button.layer.cornerRadius = 33;
    [self.button addTarget:self action:@selector(showItems) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.array1 = [NSMutableArray new];
    self.array2 = [NSMutableArray new];
    self.hArray = [NSMutableArray new];
    for (int i =1 ; i < 8; i ++) {
        [self.array addObject:[UIImage imageNamed:[NSString stringWithFormat: @"1_%d",i]]];
    }
    for (int i =1 ; i < 8; i ++) {
        [self.array1 addObject:[UIImage imageNamed:[NSString stringWithFormat: @"2_%d",i]]];
    }
    for (int i =1 ; i < 8; i ++) {
        [self.array2 addObject:[UIImage imageNamed:[NSString stringWithFormat: @"3_%d",i]]];
    }
    for (int i =1 ; i < 10; i ++) {
        [self.hArray addObject:[UIImage imageNamed:[NSString stringWithFormat: @"h_%d",i]]];
    }

    
    self.imageView = [[UIImageView alloc] init ];//WithFrame:CGRectMake(self.frame.size.width/2.f - 44, self.frame.size.height/2.f - 51 , 140 ,92)];//(self.center.x - 43, self.center.y - 49, 105 , 88)];
    [self addSubview:self.imageView];
    
    [self.imageView makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.centerX).offset(-39);
        make.top.equalTo(self.centerY).offset(-45);
        make.height.equalTo(81);
        make.width.equalTo(115);
    }];
    
    
    
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.animationDuration = .5; //执行一次完整动画所需的时长
    self.imageView.animationRepeatCount = 1;  //动画重复次数 0表示无限次，默认为0
    
    self.stepOneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    self.stepOneButton.frame = CGRectMake(0, 0, 50, 60);
    [self.imageView addSubview:self.stepOneButton];
    
    [self.stepOneButton makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.imageView);
        make.top.equalTo(self.imageView);
        make.height.equalTo(90);
        make.width.equalTo(90);
    }];
    
    self.stepOneButton.center = CGPointMake(self.imageView.bounds.size.width - 25, self.imageView.bounds.size.height/2);
    
    
    
    [self.stepOneButton addTarget:self action:@selector(tapImage) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    self.maskView = [[UIView alloc]init ];//WithFrame:[MenuView tpd_topWindow].bounds];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stepThree)];
    //    tap.allowedTouchTypes = @[@1];
    [self.maskView addGestureRecognizer:tap];
    [self resetButton];
    [self.superview insertSubview:self.maskView belowSubview:self];
                     
     [self.maskView makeConstraints:^(MASConstraintMaker *make) {
         make.edges.equalTo(self.superview);
     }];
    self.maskView.hidden = YES;
    self.step = 0;
}
/**
 *  是否展示视图
 */
- (void)show {
    if (self.step == 2 && self.imageView.animating == YES && self.isShow == YES) {
        return;
    }
    if (_isShow) {
        [UIView animateWithDuration:0.2 animations:^{
            //            CGFloat corner = -M_PI * 2.0 / _btnArray.count;
            CGFloat r =  Radius ;
            CGFloat x = self.Witch  / 2 ;
            CGFloat y = self.Witch  / 2 ;
            for (int i = 0 ; i < _btnArray.count  ; i ++) {
                
                UIButton *btn = _btnArray[i];
                CGFloat  rotation = - gapRotation * i  - offSetRotation;
                btn.center = CGPointMake(x + r * cos(rotation), y + r *sin(rotation));
                btn.alpha = 1 ;
            }
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            for (int i = 0; i < _btnArray.count; i++ ) {
                UIButton *btn = _btnArray[i];
                btn.center = CGPointMake(self.Witch   / 2 ,self.Witch   /2);
                btn.alpha = 0 ;
            }
        }];
    }
    _isShow = !_isShow;
}

/**
 *  是否展示视图
 */
- (void)show:(BOOL)isShow {
    if (self.step == 2 && self.imageView.animating == YES && self.isShow == YES) {
        return;
    }
    if (isShow) {
        [UIView animateWithDuration:0.2 animations:^{
            //            CGFloat corner = -M_PI * 2.0 / _btnArray.count;
            CGFloat r =  Radius;
            CGFloat x = self.Witch  / 2 ;
            CGFloat y = self.Witch  / 2 ;
            for (int i = 0 ; i < _btnArray.count  ; i ++) {
                
                UIButton *btn = _btnArray[i];
                CGFloat  rotation = - gapRotation * i  - offSetRotation;
                btn.center = CGPointMake(x + r * cos(rotation), y + r *sin(rotation));
                btn.alpha = 1 ;
            }
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            for (int i = 0; i < _btnArray.count; i++ ) {
                UIButton *btn = _btnArray[i];
                btn.center = CGPointMake(self.Witch   / 2 ,self.Witch   /2);
                btn.alpha = 0 ;
            }
        }];
    }
    _isShow = !isShow;
}

/**
 *  按钮点击事件
 *
 *  @param btn
 */
- (void)btn: (UIButton *)btn {
    _isShow = YES ;
    NSInteger num1 = btn.tag;
    NSString *name = _nameArray[num1];
    //    [self show];
    self.back(num1,name);
    
}


- (void)showItems{
    if (self.imageView.isAnimating) {
        return;
    }
    [self stepThree];
}

- (void)tapImage {
    [self stepTwo];
    self.stepOneButton.userInteractionEnabled = NO;
}



- (void)stepOne {
    //是否还有新页面未浏览
    BOOL hasNew = [self checkButtonIsNew];
    self.imageView.animationImages = hasNew ? self.hArray : self.array;
    self.userInteractionEnabled = NO;
    self.imageView.animationDuration = hasNew ? 1.2 : .5; //执行一次完整动画所需的时长

    self.imageView.image = [hasNew ? self.hArray : self.array lastObject];
    self.timer1 = [NSTimer bk_scheduledTimerWithTimeInterval:1/1000 block:^(NSTimer *timer) {
        if ( ![self.imageView  isAnimating] ) {
            self.imageView.animationDuration =.5; //执行一次完整动画所需的时长
            [self.timer1 invalidate];
        }
        
    } repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer1 forMode:UITrackingRunLoopMode];
    
    [self.imageView startAnimating];
    self.imageView.userInteractionEnabled = YES;
    self.step = 0;
}

- (void)stepTwo {
    self.imageView.animationImages = self.array1;
    self.imageView.image = [self.array1 lastObject];
    self.imageView.animationDuration = .5;
    [self.imageView startAnimating];
    
    self.timer2 = [NSTimer bk_scheduledTimerWithTimeInterval:1/1000 block:^(NSTimer *timer) {
        if ( ![self.imageView  isAnimating] ) {
            // Animating done
            [self show:YES];
            self.button.userInteractionEnabled = YES;
            [self.timer2 invalidate];
            NSLog(@"self.timer2 invalidate2 %p",self.timer2);
            
            self.timer2 = nil;
            //add mask
            self.changeStatus(YES);
        }else{
            
            
            
        }
        
    } repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer2 forMode:UITrackingRunLoopMode];
    
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0;
    self.maskView.hidden = NO;
    
//    [UIView animateWithDuration:.1 delay:0 options:1 animations:^{
        self.maskView.alpha = .8;
//    } completion:^(BOOL finished) {
//        
//    }];

    self.imageView.userInteractionEnabled = NO;
    self.button.userInteractionEnabled = NO;
    self.step = 1;
    
}

- (void)stepThree {
    
    if (self.step == 2 || self.imageView.animating == YES) {
        return;
    }
    [DialerUsageRecord recordpath:PATH_ASSISTANT
                              kvs:Pair(PATH_ASSISTANT_end, @(1)), nil];

    
    self.imageView.animationImages = self.array2;
    self.imageView.image = [self.array lastObject];
    self.stepOneButton.userInteractionEnabled = YES;
    self.button.userInteractionEnabled = NO;
    
    [self.imageView startAnimating];
    [self show:NO];
    
    self.timer3 = [NSTimer bk_scheduledTimerWithTimeInterval:1/1000 block:^(NSTimer *timer) {
        if ( ![self.imageView  isAnimating] ) {
            self.imageView.userInteractionEnabled = YES;
            self.button.userInteractionEnabled = NO;
            
            
            self.maskView.alpha = 0;

            [UIView animateWithDuration:.1 delay:0 options:1 animations:^{
                self.maskView.alpha = 0;
            } completion:^(BOOL finished) {
            self.maskView.hidden = YES;
                        }];
            [self.timer3 invalidate];
            NSLog(@"self.timer3 invalidate3 %p",self.timer3);
            self.timer3 = nil;
            self.changeStatus(NO);

            [self stepOne];
        }else {
            self.button.userInteractionEnabled = NO;
            
            
        }
        
    } repeats:YES];    NSLog(@"step3 %p",self.timer3);
    [[NSRunLoop currentRunLoop] addTimer:self.timer3 forMode:UITrackingRunLoopMode];
    
    
    self.imageView.userInteractionEnabled = NO;
    self.userInteractionEnabled = NO;
    self.step = 2;
    
}

- (void)reloadStatus {
    //更新按钮小红点状态
    if (self.btnArray.count > 0) {
        for (int i = 0 ; i < self.btnArray.count; i++) {
            UIButton *btn = self.btnArray[i];
            [btn setImage:[UIImage imageNamed:[self.btnStatusArray[i] isEqualToString:@"1"]?self.hImageArray[i]:self.imageArray[i]] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor clearColor];

        }
    }
    //
    
    
}

- (void) resetButton {
    
    self.imageView.animationImages = self.array2;
    self.imageView.image = [self.array lastObject];
    self.imageView.userInteractionEnabled = NO;
    self.button.userInteractionEnabled = NO;
    self.stepOneButton.userInteractionEnabled = YES;
    
    for (int i = 0; i < self.btnArray.count; i++ ) {
        UIButton *btn = self.btnArray[i];
        btn.center = CGPointMake(self.Witch   / 2 ,self.Witch   /2);
        btn.alpha = 0 ;
    }
    _isShow = YES;
}
//查看是否有未点击新按钮
- (BOOL)checkButtonIsNew {
    self.btnStatusArray = [[MenuView checkButtonNew] mutableCopy];
    if (self.btnStatusArray.count == 0) {
        for ( int i = i ; i < self.nameArray.count; i ++) {
            [self.btnStatusArray addObject:@"0"];
            [UserDefaultsManager setObject:self.btnStatusArray forKey:WELCOME_ASSISTANT_BUTTON_STATUS];
        }
        return NO;
    }
    
    for (int i = 0; i < self.btnStatusArray.count; i ++) {
        if ([self.btnStatusArray[i] intValue] == 1) {
            return YES;
        }
    }
    return NO;
}

//准备小熊猫本地数据
+ (NSArray *)checkButtonNew {
    
    return  [UserDefaultsManager arrayForKey:WELCOME_ASSISTANT_BUTTON_STATUS defaultValue:@[]] ;
}


+ (MenuView *)MenuInitialWithArray:(NSArray *)array
                          Delegate:(id)viewDelegate
                        BlockArray:(NSArray *)blockArray
                 changeStatusBlock:(void (^)(BOOL isShow))statusChange {

    MenuView *romate = [[MenuView alloc]init ] ;//WithFrame:CGRectMake(0, 0, 220, 220)];

    NSArray *contentArray = array;
    NSMutableArray *_datasource = [NSMutableArray new];
    romate.btnStatusArray = [NSMutableArray new];
    for (int i = 0 ;i < contentArray.count ; i ++) {
        BtnModel *model = contentArray[i];
        [_datasource addObject:model];
    }
    romate.nameArray    = [NSMutableArray new];
    romate.imageArray   = [NSMutableArray new];
    romate.hImageArray  = [NSMutableArray new];
    for (BtnModel *model  in _datasource) {
        
        [romate.nameArray   addObject:model.title];
        [romate.imageArray  addObject:model.image1];
        [romate.hImageArray addObject:model.image2];
    }
    
    romate.changeStatus = statusChange;
    [romate makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(220);
    }];
    
    [((UIViewController *)viewDelegate).view addSubview: romate];
    [romate BtnType:FTT_RoundviewTypeCustom BtnWitch:91 adjustsFontSizesTowidth:YES msaksToBounds:YES conrenrRadius:0 titileColor:[UIColor whiteColor]];
    __weak MenuView* weakSelf = romate;
    romate.back = ^(NSInteger num ,NSString *name ) {
        NSLog(@"block btn click %ld",num);
        [weakSelf stepThree];
        void (^block)() = blockArray[num];
        block();
        //record
        switch (num) {
            case 0:
                [DialerUsageRecord recordpath:PATH_ASSISTANT
                                          kvs:Pair(PATH_ASSISTANT_INDEXONE, @(1)), nil];
                
                break;
            case 1:
                [DialerUsageRecord recordpath:PATH_ASSISTANT
                                          kvs:Pair(PATH_ASSISTANT_INDEXTWO, @(1)), nil];
                
                break;
            case 2:
                [DialerUsageRecord recordpath:PATH_ASSISTANT
                                          kvs:Pair(PATH_ASSISTANT_INDEXTHREE, @(1)), nil];
                
                break;
            case 3:
                [DialerUsageRecord recordpath:PATH_ASSISTANT
                                          kvs:Pair(PATH_ASSISTANT_INDEXFOUR, @(1)), nil];
                
                break;
            case 4:
                [DialerUsageRecord recordpath:PATH_ASSISTANT
                                          kvs:Pair(PATH_ASSISTANT_INDEXFIVE, @(1)), nil];
                
                break;
            case 5:
                [DialerUsageRecord recordpath:PATH_ASSISTANT
                                          kvs:Pair(PATH_ASSISTANT_INDEXSIX, @(1)), nil];
                
                break;
                
            default:
                break;
        }

        
    };
    [romate loadView];
    
    
    return romate;
}

- (void)loadView {
    [self stepOne];
    
}
- (void)hello {
    [self stepOne];
}
#pragma mark - 帮助方法
+ (UIWindow *)tpd_topWindow
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        
        if ([window isKindOfClass:[UIWindow class]] &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            
            return window;
    }
    return nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (self.hidden == YES) {
        return nil;
    }
    CGPoint redBtnPoint = [self convertPoint:point toView:self.stepOneButton];
    if ([self.stepOneButton pointInside:redBtnPoint withEvent:event] && self.step != 2 && self.step != 1) {
        return self.stepOneButton;
    }
    if (!self.isShow) {
        CGPoint BtnPoint = [self convertPoint:point toView:self];
        
        for (int i = 0; i < self.btnArray.count ; i ++) {
            
            UIButton *btn = _btnArray[i];
            if ([self pointInRect:btn.frame andPoint:BtnPoint]) {
                NSLog(@"%d",i);
                return btn;
            }
        }
    }
    if (self.userInteractionEnabled == NO) {
        return nil;
    }else {
        
        return [super hitTest:point withEvent:event];
    }
    
}

- (BOOL)pointInRect:(CGRect)rect andPoint:(CGPoint)point {
    
    if (point.x > rect.origin.x && point.x < rect.origin.x + rect.size.width && point.y > rect.origin.y && point.y < rect.origin.y + rect.size.height) {
        return  YES;
    }
    
    
    return NO;
}



@end
