//
//  RemoteSkinEmptyView.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-28.
//
//

#import "RemoteSkinEmptyView.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"

@interface RemoteSkinEmptyView () {
    UIImageView *iconView_;
    UILabel *label_;
}
@end

@implementation RemoteSkinEmptyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *icon = [[TPDialerResourceManager sharedManager] getImageByName:@"remote_skin_empty_icon@2x.png"];
        iconView_ = [[UIImageView alloc] initWithImage:icon];
        iconView_.frame = CGRectMake((frame.size.width - iconView_.frame.size.width) / 2, 70, iconView_.frame.size.width, iconView_.frame.size.height);
        [self addSubview:iconView_];
        
        label_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, frame.size.width, 40)];
        label_.text = NSLocalizedString(@"more_themes_are_coming_soon", @"");
        label_.font = [UIFont systemFontOfSize:16];
        label_.textAlignment = NSTextAlignmentCenter;
        label_.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"RankEmptyReminderView_reminderLabelText_color"];
        label_.backgroundColor = [UIColor clearColor];

        [self addSubview:label_];
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkin) name:N_SKIN_DID_CHANGE object:nil];
    }
    return self;
}

- (void)changeSkin
{
    UIImage *icon = [[TPDialerResourceManager sharedManager] getImageByName:@"remote_skin_empty_icon@2x.png"];
    iconView_.image = icon;
    label_.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"RankEmptyReminderView_reminderLabelText_color"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SkinHandler removeRecursively:self];
}

@end
