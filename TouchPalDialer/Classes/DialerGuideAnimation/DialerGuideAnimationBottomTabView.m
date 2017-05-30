//
//  DialerGuideAnimationBottomTabView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/18.
//
//

#import "DialerGuideAnimationBottomTabView.h"
#import "TPUIButton.h"
#import "PhonePadModel.h"
#import "TPDialerResourceManager.h"
#import "TPUIButton.h"

@implementation DialerGuideAnimationBottomTabView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];

    if ( self ){
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.image = [TPDialerResourceManager getImage:@"dialer_guide_animation_tab_view_bg@2x.png"];
        [self addSubview:imageView];

        UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width/4, frame.size.height)];
        view1.backgroundColor = [UIColor clearColor];
        [self addSubview:view1];

        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, view1.frame.size.width, 12)];
        label1.font = [UIFont systemFontOfSize:12];
        label1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.backgroundColor = [UIColor clearColor];
        label1.text = NSLocalizedString(@"Contact_", @"");
        [view1 addSubview:label1];

        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake((view1.frame.size.width-25)/2, 5, 25, 25)];
        imageView1.image = [TPDialerResourceManager getImage:@"dialer_guide_tab_view_photo_1@2x.png"];
        [view1 addSubview:imageView1];

        UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width/4, 0, frame.size.width/2, frame.size.height)];
        view2.backgroundColor = [UIColor clearColor];
        [self addSubview:view2];

        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, view2.frame.size.width, 12)];
        label2.font = [UIFont systemFontOfSize:12];
        label2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.backgroundColor = [UIColor clearColor];
        label2.text = NSLocalizedString(@"Fold_Dialpad_", @"");
        [view2 addSubview:label2];

        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake((view2.frame.size.width-25)/2, 5, 25, 25)];
        imageView2.image = [TPDialerResourceManager getImage:@"dialer_guide_tab_view_photo_2@2x.png"];
        [view2 addSubview:imageView2];

        UIView *view3 = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width/4*3, 0, frame.size.width/4, frame.size.height)];
        view3.backgroundColor = [UIColor clearColor];
        [self addSubview:view3];

        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, view3.frame.size.width, 12)];
        label3.font = [UIFont systemFontOfSize:12];
        label3.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        label3.textAlignment = NSTextAlignmentCenter;
        label3.backgroundColor = [UIColor clearColor];
        label3.text = NSLocalizedString(@"YellowPage_", @"");
        [view3 addSubview:label3];

        UIImageView *imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake((view3.frame.size.width-25)/2, 5, 25, 25)];
        imageView3.image = [TPDialerResourceManager getImage:@"dialer_guide_tab_view_photo_3@2x.png"];
        [view3 addSubview:imageView3];
    }

    return self;
}


@end
