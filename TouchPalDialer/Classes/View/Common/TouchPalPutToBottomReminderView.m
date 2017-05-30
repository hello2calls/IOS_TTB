//
//  TouchPalProReminderView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 1/11/13.
//
//

#import "TouchPalPutToBottomReminderView.h"
#import "HeaderBar.h"
#import "SkinHandler.h"
#import "TPDialerResourceManager.h"
#import "TPItemButton.h"

@implementation TouchPalPutToBottomReminderView

+ (TouchPalPutToBottomReminderView *)view{
  [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_WAIT];
  return [[TouchPalPutToBottomReminderView alloc] initWithFrame:CGRectMake(0, 0,TPScreenWidth(), TPScreenHeight())];
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake((TPScreenWidth()-280)/2, (TPScreenHeight() - 310)/2 - 20, 280, 310)];
        tipView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"popup_bg_color"];
        [self addSubview:tipView];
        
        UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tipView.frame.size.width, 45)];
        headView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_dialog_title_bg@2x.png"];
        headView.backgroundColor = [UIColor clearColor];
        [tipView addSubview:headView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 , 0, 270, 45)];
        titleLabel.text = NSLocalizedString(@"TouchPal tips",@"");
        titleLabel.font = [UIFont systemFontOfSize:20];
        titleLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [tipView addSubview:titleLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 55, 260, 170)];
        imageView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"put_touchpal_to_bottom_reminder@2x.png"];
        [tipView addSubview:imageView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 230, 280, 30)];
        textLabel.text = NSLocalizedString(@"Move icon to quick launch tip", @"");
        textLabel.textColor = [[TPDialerResourceManager sharedManager]
                               getUIColorFromNumberString:@"defaultCellMainText_color"];
        
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont systemFontOfSize:15];
        textLabel.textAlignment = NSTextAlignmentCenter;
        [tipView addSubview:textLabel];
        
        UIButton *knownButton = [[TPItemButton alloc] initWithFrame:CGRectMake(0, 265, 280, 45)];
        [knownButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:
                                  @"common_popup_button_right_normal@2x.png"] forState:UIControlStateNormal];
        [knownButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:
                                  @"common_popup_button_ht@2x.png"] forState:UIControlStateHighlighted];
        [knownButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"] forState:UIControlStateNormal];
        [knownButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        [knownButton setTitle:NSLocalizedString(@"OK",@"") forState:UIControlStateNormal];
        [tipView addSubview:knownButton];
    }
    return self;
}

- (void)dismissSelf{    
    [self removeFromSuperview];
}

- (void)dealloc{
    [SkinHandler removeRecursively:self];
}
@end
