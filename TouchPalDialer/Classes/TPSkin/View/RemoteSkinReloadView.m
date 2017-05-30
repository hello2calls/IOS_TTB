//
//  RemoteSkinReloadView.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-20.
//
//

#import "RemoteSkinReloadView.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"

@interface RemoteSkinReloadView () {
    UIImageView *iconView_;
    UILabel *connectionFailLabel_;
    UILabel *connectionRetryLabel_;
}
@end

@implementation RemoteSkinReloadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *icon = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"remote_skin_reload_icon@2x.png"];
        iconView_ = [[UIImageView alloc] initWithImage:icon];
        iconView_.frame = CGRectMake((frame.size.width - iconView_.frame.size.width) / 2, 70, iconView_.frame.size.width, iconView_.frame.size.height);
        [self addSubview:iconView_];
        
        connectionFailLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, frame.size.width, 30)];
        connectionFailLabel_.text = NSLocalizedString(@"Failed to load", @"");
        connectionFailLabel_.font = [UIFont systemFontOfSize:16];
        connectionFailLabel_.textAlignment = NSTextAlignmentCenter;
        connectionFailLabel_.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"RankEmptyReminderView_reminderLabelText_color"];
        connectionFailLabel_.backgroundColor = [UIColor clearColor];
        [self addSubview:connectionFailLabel_];
        
        connectionRetryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 270, frame.size.width, 25)];
        connectionRetryLabel_.text = NSLocalizedString(@"remote_skin_list_retry", @"");
        connectionRetryLabel_.font = [UIFont systemFontOfSize:16];
        connectionRetryLabel_.textAlignment = NSTextAlignmentCenter;
        connectionRetryLabel_.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"RankEmptyReminderView_reminderLabelText_color"];
        connectionRetryLabel_.backgroundColor = [UIColor clearColor];
        [self addSubview:connectionRetryLabel_];
    
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
        [self addGestureRecognizer:tapRecognizer];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkin) name:N_SKIN_DID_CHANGE object:nil];
    }
    return self;
}

- (void)changeSkin
{
    UIImage *icon = [[TPDialerResourceManager sharedManager] getImageByName:@"remote_skin_reload_icon@2x.png"];
    iconView_.image = icon;
    connectionFailLabel_.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"RankEmptyReminderView_reminderLabelText_color"];
    connectionRetryLabel_.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"RankEmptyReminderView_reminderLabelText_color"];
}

- (void)viewTapped
{
    if (self.delegate) {
        [self.delegate remoteSkinReloadViewClicked:self];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SkinHandler removeRecursively:self];
}

@end
