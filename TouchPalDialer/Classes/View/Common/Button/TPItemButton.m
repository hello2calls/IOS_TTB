//
//  TPMeHeaderButton.m
//  TouchPalDialer
//
//  Created by gan lu on 4/27/12.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#import "TPItemButton.h"
#import "TPDialerResourceManager.h"

@implementation TPItemButton

- (id)initWithFrame:(CGRect)frame withString:(NSString *)icon_str{
	if (self = [super initWithFrame:frame withString:icon_str]) {
	}
	return self;
}
- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    int cap = 100;
    if([propertyDic objectForKey:BACK_GROUND_IMAGE]!=nil){
        UIImage *tmpImage = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:BACK_GROUND_IMAGE]] ;
        UIImage *adapterImage = [tmpImage stretchableImageWithLeftCapWidth:cap topCapHeight:0];
        [self setBackgroundImage:adapterImage forState:UIControlStateNormal];
    }
    if([propertyDic objectForKey:BACK_GROUND_IMAGE_HT]!=nil){
        UIImage *tmpImage = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:BACK_GROUND_IMAGE_HT]];
        UIImage *adapterImage = [tmpImage stretchableImageWithLeftCapWidth:cap topCapHeight:0];
        [self setBackgroundImage:adapterImage forState:UIControlStateHighlighted];
    }
    if([propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]){
        [self setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]] forState:UIControlStateNormal];
    }
    if([propertyDic objectForKey:DISABLED_TEXT_COLOR_FOR_STYLE]!=nil){
        [self setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:DISABLED_TEXT_COLOR_FOR_STYLE]] forState:UIControlStateDisabled];
    }
    if([propertyDic objectForKey:IMAGE_FOR_DISABLED_STATE]){
        UIImage *tmpImage = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:IMAGE_FOR_DISABLED_STATE]] ;
        UIImage *adapterImage = [tmpImage stretchableImageWithLeftCapWidth:cap topCapHeight:0];
        [self setBackgroundImage:adapterImage forState:UIControlStateDisabled];
    }

    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}

@end
