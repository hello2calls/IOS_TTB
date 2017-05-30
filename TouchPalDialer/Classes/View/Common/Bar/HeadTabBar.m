//
//  HeadTabBar.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HeadTabBar.h"
#import "TPDialerResourceManager.h"
#import "TPUIButton.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
@implementation HeadTabBar {
}

@synthesize expandableHeadTabBar;

- (id)initWithFrame:(CGRect)frame buttonCount:(NSInteger)count
{
    self = [super initWithFrame:frame buttonCount:count];
    if (self) {
        expandableHeadTabBar = NO;
    }
    return self;
}


-(void)tabBarTitle:(NSArray *)titleList{
    for (int i = 0; i< [titleList count]; i++) {
        TPUIButton *tmpBtn = [self.buttonArray objectAtIndex:i];
        
        [tmpBtn setTitle:[titleList objectAtIndex:i] forState:UIControlStateNormal];
    }
}
-(void)clickItem:(TPUIButton *)button{
    [self clickTabIndex:button.tag];
}
-(void)clickTabIndex:(NSInteger)index{
    for (int i = 0; i< [self.buttonArray count]; i++) {
        TPUIButton *tmpBtn = [self.buttonArray objectAtIndex:i];
        if (index == i) {
            tmpBtn.enabled = NO;
            if (expandableHeadTabBar) {
                if (self.canChangeSkin) {
                    [tmpBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"selectedButtonColor"]] forState:UIControlStateNormal];
                } else {
                    [tmpBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"selectedButtonColor"]] forState:UIControlStateNormal];
                }
                
            }
            if (_changeSkinHeadTabBar) {
                if (self.canChangeSkin) {
                    [tmpBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"selectedButtonColor"]] forState:UIControlStateNormal];
                } else {
                    [tmpBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"selectedButtonColor"]] forState:UIControlStateNormal];
                }
                
            }
            
        }else {
            tmpBtn.enabled = YES;
            if (expandableHeadTabBar) {
                if (self.canChangeSkin) {
                    [tmpBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"unselectedButtonColor"]] forState:UIControlStateNormal];
                } else {
                    [tmpBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"unselectedButtonColor"]] forState:UIControlStateNormal];
                }
                
            }
            if (_changeSkinHeadTabBar) {
                if (self.canChangeSkin) {
                    [tmpBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"unselectedButtonColor"]] forState:UIControlStateNormal];
                } else {
                    [tmpBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"unselectedButtonColor"]] forState:UIControlStateNormal];
                }
                
            }
        }
    }
    [self.delegate onClickAtIndexBar:index];
}

- (id)selfSkinChange:(NSString *)style{
    self.canChangeSkin = YES;
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];

    operDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    UIImage *tmpImage = isVersionSix ? [FunctionUtility imageWithColor:[UIColor clearColor]] : [[TPDialerResourceManager sharedManager] getImageByName:[operDic objectForKey:@"fisrtTabButton_backgroundImage"]];
    UIImage *firstImageNormal = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    tmpImage = [[TPDialerResourceManager sharedManager] getImageByName:[operDic objectForKey:@"firstTabButton_backgroundImage_ht"]];
    UIImage *firstImagePress = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    
    tmpImage = [[TPDialerResourceManager sharedManager] getImageByName:[operDic objectForKey:@"tabButton_backgroundImage"]];
    UIImage *imageNormal = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    tmpImage = [[TPDialerResourceManager sharedManager] getImageByName:[operDic objectForKey:@"tabButton_backgroundImage_ht"]];
    UIImage *imagePress = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    
    tmpImage = [[TPDialerResourceManager sharedManager] getImageByName:[operDic objectForKey:@"lastTabButton_backgroundImage"]];
    UIImage *lastImageNormal = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    tmpImage = [[TPDialerResourceManager sharedManager] getImageByName:[operDic objectForKey:@"lastTabButton_backgroundImage_ht"]];
    UIImage *lastImagePress = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    
    NSString *colorString = [operDic objectForKey:@"backgroundColor"];
    if(colorString){
        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:colorString];
    }

    for (int i = 0; i<[self.buttonArray count]; i++ ) {
        TPUIButton *tmpButton = [self.buttonArray objectAtIndex:i];
        if (i == 0) {
            [tmpButton setBackgroundImage:firstImageNormal forState:UIControlStateNormal];
            [tmpButton setBackgroundImage:firstImageNormal forState:UIControlStateHighlighted];
            [tmpButton setBackgroundImage:firstImagePress forState:UIControlStateDisabled];
        }else if(i== ([self.buttonArray count]-1)){
            [tmpButton setBackgroundImage:lastImageNormal forState:UIControlStateNormal];
            [tmpButton setBackgroundImage:lastImageNormal forState:UIControlStateHighlighted];
            [tmpButton setBackgroundImage:lastImagePress forState:UIControlStateDisabled];
        }else {
            [tmpButton setBackgroundImage:imageNormal forState:UIControlStateNormal];
            [tmpButton setBackgroundImage:imageNormal forState:UIControlStateHighlighted];
            [tmpButton setBackgroundImage:imagePress forState:UIControlStateDisabled];
        }
        if (_changeSkinHeadTabBar){
            if ( i == 0){
                if(tmpButton.enabled)
                    [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"unselectedButtonColor"]] forState:UIControlStateNormal];
                else
                    [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"selectedButtonColor"]] forState:UIControlStateNormal];
            }else{
                if(tmpButton.enabled)
                    [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"unselectedButtonColor"]] forState:UIControlStateNormal];
                else
                    [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"selectedButtonColor"]] forState:UIControlStateNormal];
            }
        }else{
            if (!tmpButton.enabled)
                [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"textColor"]] forState:UIControlStateDisabled];
            [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"textColor"]] forState:UIControlStateNormal];
        }
        tmpButton.titleLabel.font = [UIFont systemFontOfSize:18];
    }
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawBottomLineAtButton:(TPUIButton *)btn Index:(NSInteger)index Color:(UIColor *)lineColor
{
    UIView *drawView = [[UIView alloc]initWithFrame: CGRectMake(btn.frame.size.width * index + 1, btn.frame.size.height - 1, btn.frame.size.width, 1)];
    drawView.backgroundColor = lineColor;
    [self addSubview:drawView];
}

- (BOOL) applyDefaultSkinWithStyle :(NSString *) style {
    self.canChangeSkin = NO;
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    
    operDic = [[TPDialerResourceManager sharedManager] getPropertyDicInDefaultPackageByStyle:style];
    UIImage *tmpImage = isVersionSix ? [FunctionUtility imageWithColor:[UIColor clearColor]] :[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:[operDic objectForKey:@"fisrtTabButton_backgroundImage"]];
    UIImage *firstImageNormal = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    tmpImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:[operDic objectForKey:@"firstTabButton_backgroundImage_ht"]];
    UIImage *firstImagePress = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    
    tmpImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:[operDic objectForKey:@"tabButton_backgroundImage"]];
    UIImage *imageNormal = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    tmpImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:[operDic objectForKey:@"tabButton_backgroundImage_ht"]];
    UIImage *imagePress = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    
    tmpImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:[operDic objectForKey:@"lastTabButton_backgroundImage"]];
    UIImage *lastImageNormal = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    tmpImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:[operDic objectForKey:@"lastTabButton_backgroundImage_ht"]];
    UIImage *lastImagePress = [tmpImage stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    
    NSString *colorString = [operDic objectForKey:@"backgroundColor"];
    if(colorString){
//        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:colorString];
    }
    
    for (int i = 0; i<[self.buttonArray count]; i++ ) {
        TPUIButton *tmpButton = [self.buttonArray objectAtIndex:i];
        if (i == 0) {
            [tmpButton setBackgroundImage:firstImageNormal forState:UIControlStateNormal];
            [tmpButton setBackgroundImage:firstImageNormal forState:UIControlStateHighlighted];
            [tmpButton setBackgroundImage:firstImagePress forState:UIControlStateDisabled];
        }else if(i== ([self.buttonArray count]-1)){
            [tmpButton setBackgroundImage:lastImageNormal forState:UIControlStateNormal];
            [tmpButton setBackgroundImage:lastImageNormal forState:UIControlStateHighlighted];
            [tmpButton setBackgroundImage:lastImagePress forState:UIControlStateDisabled];
        }else {
            [tmpButton setBackgroundImage:imageNormal forState:UIControlStateNormal];
            [tmpButton setBackgroundImage:imageNormal forState:UIControlStateHighlighted];
            [tmpButton setBackgroundImage:imagePress forState:UIControlStateDisabled];
        }
        if (_changeSkinHeadTabBar){
            if ( i == 0){
                if(tmpButton.enabled)
                    [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"unselectedButtonColor"]] forState:UIControlStateNormal];
                else
                    [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"selectedButtonColor"]] forState:UIControlStateNormal];
            }else{
                if(tmpButton.enabled)
                    [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"unselectedButtonColor"]] forState:UIControlStateNormal];
                else
                    [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"selectedButtonColor"]] forState:UIControlStateNormal];
            }
        }else{
            if (!tmpButton.enabled)
                [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"textColor"]] forState:UIControlStateDisabled];
            [tmpButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:[operDic objectForKey:@"textColor"]] forState:UIControlStateNormal];
        }
        tmpButton.titleLabel.font = [UIFont systemFontOfSize:18];
    }
    return YES;
}



@end
