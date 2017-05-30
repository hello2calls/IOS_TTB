//
//  VoipTopSectionHeaderBar.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-5.
//
//

#import "VoipTopSectionHeaderBar.h"
#import "TPHeaderButton.h"
#import "HeaderBar.h"
#import "TPDialerResourceManager.h"

@interface VoipTopSectionHeaderBar()
@end

@implementation VoipTopSectionHeaderBar

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.backgroundColor = [UIColor clearColor];
        
        // Label
        _headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, TPHeaderBarHeightDiff(), frame.size.width - 120, 45)];
        _headerTitle.textColor = [UIColor whiteColor];
        _headerTitle.font = [UIFont systemFontOfSize:FONT_HEADER_TAB_TITLE];
        _headerTitle.textAlignment = NSTextAlignmentCenter;
        _headerTitle.backgroundColor = [UIColor clearColor];
        _headerTitle.text = NSLocalizedString(@"voip_free_phone", @"");
        [self addSubview:_headerTitle];

        // BackButton
        TPHeaderButton *cancel_but = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(5, 0, 45, 45)];
        cancel_but.backgroundColor = [UIColor clearColor];
        cancel_but.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [cancel_but setTitle:@"0" forState:UIControlStateNormal];
        [cancel_but addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [cancel_but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancel_but setTitleColor:[TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"] forState:UIControlStateHighlighted];
        [self addSubview:cancel_but];

        //
        UIButton *headerButton = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 50, TPHeaderBarHeightDiff(), 50, 45)];
        headerButton.hidden = YES;
        [headerButton setTitle:@"J" forState:UIControlStateNormal];
        headerButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
        [headerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:headerButton];
        _headerButton = headerButton;
        [headerButton addTarget:self action:@selector(headerButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *headerButton2 = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 100, TPHeaderBarHeightDiff(), 50, 45)];
        headerButton2.hidden = YES;
        [headerButton2 setTitle:@"a" forState:UIControlStateNormal];
        headerButton2.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
        [headerButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:headerButton2];
        _headerButton2 = headerButton2;
        [headerButton2 addTarget:self action:@selector(headerButtonAction2) forControlEvents:UIControlEventTouchUpInside];}
    
    return self;
    
}

- (void) gotoBack{
    [_delegate gotoBack];
}

- (void) headerButtonAction{
    [_delegate headerButtonAction];
}

- (void) headerButtonAction2{
    [_delegate headerButtonAction2];
}

- (void) setButtonText:(NSString*)text{
    _headerButton.hidden = NO;
    [_headerButton setTitle:text forState:UIControlStateNormal];
}

- (void) setButton2Text:(NSString*)text{
    _headerButton2.hidden = NO;
    [_headerButton2 setTitle:text forState:UIControlStateNormal];
}

@end
