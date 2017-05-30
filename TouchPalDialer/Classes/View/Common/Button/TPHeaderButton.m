//
//  TPHeaderButton.m
//  TouchPalDialer
//
//  Created by zhang Owen on 10/13/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "TPHeaderButton.h"
#import "TPDialerResourceManager.h"
#define PADDING 10

@implementation TPHeaderButton
- (id)initWithFrame:(CGRect)frame{
    frame = CGRectMake(frame.origin.x,frame.origin.y+TPHeaderBarHeightDiff(),frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        [self.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_3_5]];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addTarget:self action:@selector(touchBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (id)initLeftBtnWithFrame:(CGRect)frame{
    self = [self initWithFrame:CGRectMake(frame.origin.x,frame.origin.y,frame.size.width, frame.size.height)];
    //deprecate the adjust for images
//    if (self) {
//        [self setContentEdgeInsets:UIEdgeInsetsMake(0, PADDING, 0, 0)];
//        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    }
    return self;
}

- (id)initRightBtnWithFrame:(CGRect)frame{
    self = [self initWithFrame:CGRectMake(frame.origin.x,frame.origin.y,frame.size.width, frame.size.height)];
    return self;
}

- (void)touchBtn
{
    self.titleLabel.alpha = 0;
    self.imageView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{ self.titleLabel.alpha = 1; }
                     completion:^(BOOL finished){ }];    
    [UIView animateWithDuration:0.5 animations:^{ self.imageView.alpha = 1; }
                     completion:^(BOOL finished){ }];
}

- (void)showBtn
{
    self.titleLabel.alpha = 0;
    self.imageView.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{ self.titleLabel.alpha = 1; }
                     completion:^(BOOL finished){ }];
    [UIView animateWithDuration:0.5 animations:^{ self.imageView.alpha = 1; }
                     completion:^(BOOL finished){ }];
}

- (void)hideBtn
{
    self.hidden = YES;
}

- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    if([propertyDic objectForKey:FONT]!=nil){
        self.titleLabel.font = [TPDialerResourceManager getFontFromNumberString:[propertyDic objectForKey:FONT]];
    }
    if([propertyDic objectForKey:IMAGE_FOR_NORMAL_STATE]!=nil){
        [self setImage:[[TPDialerResourceManager sharedManager] getImageByName:
                        [propertyDic objectForKey:IMAGE_FOR_NORMAL_STATE]] forState:UIControlStateNormal];
        [self setImage:[[TPDialerResourceManager sharedManager] getImageByName:
                        [propertyDic objectForKey:IMAGE_FOR_NORMAL_STATE]] forState:UIControlStateHighlighted];
    }
    if([propertyDic objectForKey:IMAGE_FOR_SELECTED_STATE]!=nil){
        [self setImage:[[TPDialerResourceManager sharedManager] getImageByName:
                        [propertyDic objectForKey:IMAGE_FOR_SELECTED_STATE]] forState:UIControlStateSelected];
    }
    [self setTitleColor:[[TPDialerResourceManager sharedManager]
                         getUIColorFromNumberString:@"header_btn_color"] forState:UIControlStateNormal];
    [self setTitleColor:[[TPDialerResourceManager sharedManager]
                         getUIColorFromNumberString:@"header_btn_disabled_color"] forState:UIControlStateDisabled];
    if ( _ifHighlight )
        [self setTitleColor:[TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"] forState:UIControlStateHighlighted];
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}

- (BOOL) applyDefaultSkinWithStyle :(NSString *) style {
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicInDefaultPackageByStyle:style];
    if([propertyDic objectForKey:FONT]!=nil){
        self.titleLabel.font = [TPDialerResourceManager getFontFromNumberString:[propertyDic objectForKey:FONT]];
    }
    if([propertyDic objectForKey:IMAGE_FOR_NORMAL_STATE]!=nil){
        [self setImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:
                        [propertyDic objectForKey:IMAGE_FOR_NORMAL_STATE]] forState:UIControlStateNormal];
        [self setImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:
                        [propertyDic objectForKey:IMAGE_FOR_NORMAL_STATE]] forState:UIControlStateHighlighted];
    }
    if([propertyDic objectForKey:IMAGE_FOR_SELECTED_STATE]!=nil){
        [self setImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:
                        [propertyDic objectForKey:IMAGE_FOR_SELECTED_STATE]] forState:UIControlStateSelected];
    }
    [self setTitleColor:[[TPDialerResourceManager sharedManager]
                         getUIColorInDefaultPackageByNumberString:@"header_btn_color"] forState:UIControlStateNormal];
    [self setTitleColor:[[TPDialerResourceManager sharedManager]
                         getUIColorInDefaultPackageByNumberString:@"header_btn_disabled_color"] forState:UIControlStateDisabled];
    if ( _ifHighlight )
        [self setTitleColor:[TPDialerResourceManager getColorInDefaultPackageForStyle:@"header_btn_disabled_color"] forState:UIControlStateHighlighted];
    return YES;
}

@end
