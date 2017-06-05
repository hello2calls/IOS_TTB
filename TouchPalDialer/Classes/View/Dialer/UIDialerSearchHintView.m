//
//  UIDialerSearchHintView.m
//  TouchPalDialer
//
//  Created by Stony Wang on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIDialerSearchHintView.h"
#import "UIView+WithSkin.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "AntiharassmentViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"
#import "AddressBookAccessUtility.h"
#import "PhonePadModel.h"
#import "FunctionUtility.h"
#import "UILabel+TPHelper.h"
#import "UILabel+DynamicHeight.h"
#import "UILayoutUtility.h"
#import "SkinSettingViewController.h"
#import "SkinSettingViewController.h"
#import "HandlerWebViewController.h"
#import "NoahToolBarView.h"
#import "DialerUsageRecord.h"

@implementation UIDialerSearchHintView {
    
}

@synthesize line1;
@synthesize line2;
@synthesize imageView;

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // compatible with iphone 4 and 4s
        BOOL isPhone4 = !isIPhone5Resolution();
        
        CGFloat gY = 0;
        // image
        if (isPhone4) {
            gY += CALLLOG_CLEAR_HINT_VIEW_Y_SMALL;
        } else {
            gY += CALLLOG_CLEAR_HINT_VIEW_Y;
        }
        // ---
        
        UIImage *hintImage = nil;
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            hintImage = [UIImage imageNamed:@"no-call-records_03"];
        }else{
            hintImage = [TPDialerResourceManager getImage:@"calllog_clear_hint@2x.png"];
        }
        
        
        CGSize imageSize = hintImage.size;
        if (isPhone4) {
            imageSize = CGSizeMake(imageSize.width * 0.8, imageSize.height * 0.8);
        }
        
        UIImageView *hintImageView = [[UIImageView alloc] init];
        hintImageView.backgroundColor = [UIColor clearColor];
        hintImageView.image = hintImage;
        hintImageView.frame = CGRectMake((self.frame.size.width - imageSize.width)/2, gY,
                                         imageSize.width, imageSize.height);
        // ---
        gY += hintImageView.frame.size.height;
        
        CGRect oldFrame = CGRectNull;
        UIColor *labelTextColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_750"];
        
        // label 1
        gY = isPhone4 ? (gY + 12) : (gY + 32);
        // ---
        line1 = [[UILabel alloc] initWithTitle:NSLocalizedString(@"No_log_hint_1", @"暂时没有通话记录") fontSize:17];
        line1.textColor = labelTextColor;
        oldFrame = line1.frame;
        line1.frame = CGRectMake(oldFrame.origin.x, gY, oldFrame.size.width, oldFrame.size.height);
        // ---
        gY += line1.frame.size.height;
        
        // label 2
        gY = isPhone4 ? (gY + 10): (gY + 10);
        // ---
        line2 = [[UILabel alloc] initWithTitle:NSLocalizedString(@"No_log_hint_2", @"由于系统限制，无法获取未接来电、已接来电") fontSize:13];
        line2.textColor = labelTextColor;
        oldFrame = line2.frame;
        line2.frame = CGRectMake(oldFrame.origin.x, gY, oldFrame.size.width, oldFrame.size.height);
        // ---
        gY += line2.frame.size.height;
        
        // hint holder view
        _hintHolderView = [[UIView alloc]initWithFrame:self.bounds];
        _hintHolderView.backgroundColor = [UIColor clearColor];
        [_hintHolderView addSubview:hintImageView];
        [_hintHolderView addSubview:line1];
        [_hintHolderView addSubview:line2];
        
        // view settings
        [FunctionUtility horizontallyCenterViewArray:@[line1, line2] inParentWidth:self.frame.size.width];
        
        // view tree
        [self addSubview:_hintHolderView];
    }
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

-(void)dealloc{
    [SkinHandler removeRecursively:self];
}

#pragma mark logics
- (void) hideAllView {
    line1.hidden = YES;
    line2.hidden = YES;
    imageView.hidden = YES;
}

- (void) showAllView {
    line1.hidden = NO;
    line2.hidden = NO;
    imageView.hidden = NO;
}


#pragma mark actions
- (void) toSkinController {
    UIViewController *controller = [[SkinSettingViewController alloc] init];
    [TouchPalDialerAppDelegate pushViewController:controller animated:YES];
}

- (void) toLearnVOIPController {
    UIViewController *controller = [[SkinSettingViewController alloc] init];
    [TouchPalDialerAppDelegate pushViewController:controller animated:YES];
}

#pragma mark delegate SelfSkinChangeProtocol
- (id)selfSkinChange:(NSString *)style{
    NSDictionary *dic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];    
    [self setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[dic objectForKey:BACK_GROUND_COLOR]]];
    UIColor *textColor = [TPDialerResourceManager getColorForStyle:[dic objectForKey:@"textColor"]];
    if (textColor) {
        line1.textColor = textColor;
        line2.textColor = textColor;
    }
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}


- (instancetype) initWhenNewInstallWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageTopMargin = 25;
        CGFloat hintTitleTopMargin = 19;
        CGFloat buttonLearnTopMargin = 10;
        CGFloat buttonSkinTopMargin = 10;
        
        if (isIPhone5Resolution()) {
            imageTopMargin = 0.08 * TPScreenHeight(); // 64
            hintTitleTopMargin = 0.07 * TPScreenHeight(); // 60
            buttonLearnTopMargin = 18;
            buttonSkinTopMargin = 18;
        }
        
        CGFloat gY = 0.0;
        CGFloat gX = 0.0;
        
        // img
        gY += imageTopMargin;
        UIImage *img = [TPDialerResourceManager getImage:@"calllog_empty_when_upgrade@2x.png"];
        CGFloat imgHeight = img.size.height;
        if (!isIPhone5Resolution()) {
            imgHeight = imgHeight * 0.8;
        }
        CGRect imageFrame = CGRectMake(gX, gY, TPScreenWidth(), imgHeight);
        UIImageView *hintImageView = [[UIImageView alloc] initWithFrame:imageFrame];
        hintImageView.image = img;
        hintImageView.contentMode = UIViewContentModeScaleAspectFit;
        gY += hintImageView.frame.size.height;
        
        // hint label
        gY += hintTitleTopMargin;
        UIFont *hintFont = [UIFont systemFontOfSize:15];
        UILabel *hintLabel = [[UILabel alloc] initWithTitle:NSLocalizedString(@"calllog_empty_hint_welcome", "") font:hintFont isFillContentSize:YES];
        hintLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_550"];
        hintLabel.textAlignment = NSTextAlignmentCenter;
        CGRect oldHintFrame = hintLabel.frame;
        hintLabel.frame = CGRectMake(gX, gY, TPScreenWidth(), oldHintFrame.size.height);
        gY += hintLabel.frame.size.height;
        
        // buttons
        CGSize buttonSize = CGSizeMake(230, 46);
        CGRect colorFrame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
        UIColor *textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        UIFont *font = [UIFont systemFontOfSize:17];
        gX = (TPScreenWidth() - buttonSize.width ) / 2;
        
        // learn button
        gY += buttonLearnTopMargin;
        UIButton *learnButton = [[UIButton alloc] initWithFrame:CGRectMake(gX, gY, buttonSize.width, buttonSize.height)];
        [learnButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"0x03a9f4" withFrame:colorFrame] forState:UIControlStateNormal];
        [learnButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"0x029ce1" withFrame:colorFrame] forState:UIControlStateHighlighted];
        learnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        learnButton.titleLabel.textColor = textColor;
        learnButton.titleLabel.font = font;
        learnButton.clipsToBounds = YES;
        learnButton.layer.cornerRadius = 4;
        [learnButton setTitle:NSLocalizedString(@"calllog_empty_btn_learn_voip", "") forState:UIControlStateNormal];
        gY += learnButton.frame.size.height;
        
        // skin button
        gY += buttonSkinTopMargin;
//        UIButton *skinButton = [[UIButton alloc] initWithFrame:CGRectMake(gX, gY, buttonSize.width, buttonSize.height)];
//        [skinButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"0x03a9f4" withFrame:colorFrame] forState:UIControlStateNormal];
//        [skinButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"0x029ce1" withFrame:colorFrame] forState:UIControlStateHighlighted];
//        skinButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        skinButton.titleLabel.textColor = textColor;
//        skinButton.titleLabel.font = font;
//        skinButton.clipsToBounds = YES;
//        skinButton.layer.cornerRadius = 4;
//        [skinButton setTitle:NSLocalizedString(@"calllog_empty_btn_use_skin", "") forState:UIControlStateNormal];
//        gY += skinButton.frame.size.height;
        
        // view settings
        [learnButton addTarget:self action:@selector(onClickLearnButton) forControlEvents:UIControlEventTouchUpInside];
//        [skinButton addTarget:self action:@selector(onClickSkinButton) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundColor = [UIColor whiteColor];
        
        // view tree
        [self addSubview:hintImageView];
        [self addSubview:hintLabel];
        [self addSubview:learnButton];
//        [self addSubview:skinButton];
        
//        [FunctionUtility setBorderForViewArray:@[hintImageView, hintLabel, learnButton, skinButton]];
    }
    return self;
}


#pragma mark actions
- (void) onClickLearnButton {
    [DialerUsageRecord recordpath:PATH_CALLLOG_EMPTY kvs:Pair(CALLLOG_EMPTY_CLICK_LEARN, @(1)), nil];
    HandlerWebViewController *controller = [[HandlerWebViewController alloc] init];
    controller.url_string = [NSString stringWithFormat:@"http://%@", VOIP_GUIDE_URL_PATH];
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
}

- (void) onClickSkinButton {
    [DialerUsageRecord recordpath:PATH_CALLLOG_EMPTY kvs:Pair(CALLLOG_EMPTY_CLICK_SKIN, @(1)), nil];
    UIViewController *controller = [[SkinSettingViewController alloc] init];
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
}

@end
