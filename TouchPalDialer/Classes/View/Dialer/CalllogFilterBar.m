//
//  CalllogFilterBar.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalllogFilterBar.h"
#import "consts.h"
#import "TPDialerResourceManager.h"
#import "TPUIButton.h"

@implementation CalllogFilterBar

-(void)barStyle:(NSArray *)imageList{
     _imageList = imageList;
    for (int i =0; i<[self.buttonArray count];i++) {
        TPUIButton *tmpBtn = [self.buttonArray objectAtIndex:i];
        tmpBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
       
        UIImage *imageNormal = [[TPDialerResourceManager sharedManager] getCachedImageByName:[imageList objectAtIndex:2*i]] ;
        UIImage *imagePress = [[TPDialerResourceManager sharedManager] getCachedImageByName:[imageList objectAtIndex:2*i+1]];
      
        [tmpBtn setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [tmpBtn setBackgroundImage:imagePress forState:UIControlStateHighlighted];
        [tmpBtn setBackgroundImage:imagePress forState:UIControlStateDisabled];
        
        [tmpBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"DialerFilterText_color"] forState:UIControlStateNormal];
        [tmpBtn.titleLabel setFont:[UIFont systemFontOfSize:CELL_FONT_SMALL]];
    }
}

- (id)selfSkinChange:(NSString *)style{
     [self barStyle:_imageList];
     
     return [NSNumber numberWithBool:YES];
}
@end
