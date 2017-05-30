//
//  GroupImageView.h
//  TouchPalDialer
//
//  Created by Sendor on 11-8-19.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WithSkin.h"

@interface GroupImageView : UIView <SelfSkinChangeProtocol>{
    UIImageView *group_image_view;
    UILabel *group_name_label;
    BOOL is_ungrouped;
    BOOL is_selected;
     NSString *_style;
}

- (id)initWithFrame:(CGRect)frame isUngrouped:(BOOL)isUngrouped;
- (void)setSelected:(BOOL)selected;
- (void)setGropupName:(NSString*)groupName;
@end
