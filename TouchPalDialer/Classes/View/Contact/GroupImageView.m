//
//  GroupImageView.m
//  TouchPalDialer
//
//  Created by Sendor on 11-8-19.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "GroupImageView.h"
#import "TPDialerResourceManager.h"

@implementation GroupImageView


- (id)initWithFrame:(CGRect)frame isUngrouped:(BOOL)isUngrouped {

    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    group_image_view = [[UIImageView alloc]
                        initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    group_name_label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, frame.size.height-20)];
    if (self) {
        /* 
        is_ungrouped = isUngrouped;
        if (is_ungrouped) {
            group_image_view.image = [UIImage imageNamed:@"contact_groupitem_normal@2x.png"];
        } else {
            group_image_view.image = [UIImage imageNamed:@"contact_groupitem_normal@2x.png"];
        }*/
    }
    [self addSubview:group_image_view];
    [self addSubview:group_name_label];

    group_name_label.font = [UIFont systemFontOfSize:CELL_FONT_SMALL];
    group_name_label.lineBreakMode = NSLineBreakByTruncatingTail;
    group_name_label.numberOfLines = 0;
    group_name_label.backgroundColor = [UIColor clearColor];
    group_name_label.textAlignment = NSTextAlignmentCenter;
  
    [self addSubview:group_image_view];
    [self addSubview:group_name_label];
    return self;
}


- (void)setSelected:(BOOL)selected {
    if (is_selected != selected) {
        is_selected = selected;
         [self selfSkinChange:_style];
     }
}


- (void)setGropupName:(NSString*)groupName {
    group_name_label.text = groupName;
}

- (id)selfSkinChange:(NSString *)style{
     _style = style;
     NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
     
     if (is_selected) {
          group_image_view.image = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"backgoundImagePressed"]];
          group_name_label.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"textColor_pressed"]];
     } else {
          group_name_label.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"textColor"]];
          group_image_view.image = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"backgoundImage"]];
     }
      [self setNeedsDisplay];
     NSNumber *toTop = [NSNumber numberWithBool:YES];
     return toTop;
 }

@end
