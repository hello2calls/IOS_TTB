//
//  SmartEyeReminderView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 9/29/12.
//
//

#import "SmartEyeReminderView.h"
#import "TPDialerResourceManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPItemButton.h"

@implementation SmartEyeReminderView

- (id)initWithFrame:(CGRect)frame needGoToSmartEyeSettingView:(BOOL)go CallLogBeingParsedNum:(int)num andFirstRecognizedShopName:(NSString *)shopName
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *coverView = [[UIView alloc] initWithFrame:frame];
        coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self addSubview:coverView];
        [coverView release];
        
        UIImage *tipViewImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"SmartView_reminderTip_image@2x.png"];
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - tipViewImage.size.width)/2,70, tipViewImage.size.width,tipViewImage.size.height)];
        [self addSubview:tipView];
        [tipView release];
        
        UIImageView *tipViewBG = [[UIImageView alloc] initWithImage:tipViewImage];
        tipViewBG.frame = CGRectMake(0,0,tipView.frame.size.width,tipView.frame.size.height);
        [tipView addSubview:tipViewBG];
        [tipViewBG release];
        
        CGFloat textLeftGap = 25;
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,33,tipView.frame.size.width ,50)];
        headLabel.backgroundColor = [UIColor clearColor];
        headLabel.text = NSLocalizedString(@"TouchPal tips", @"");
        headLabel.font = [UIFont boldSystemFontOfSize:CELL_FONT_LARGER];
        headLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"common_popup_title_color"];
        headLabel.textAlignment = UITextAlignmentCenter;
        [tipView addSubview:headLabel];
        [headLabel release];
                
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLeftGap, 60, tipView.frame.size.width-2*textLeftGap, 100)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.numberOfLines = 3;
        textLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
        NSString *tipString;
        if(num==0){
            tipString = NSLocalizedString(@"CallerTell recognizes unknown numbers, displays the Caller ID and tells the telemarketers.",@"");
        }else{
            NSString *rawTipString = @"CallerTell has recognized %d unknown numbers from your call logs";
            NSString *localizedString = NSLocalizedString(rawTipString,@"");
            tipString = [NSString stringWithFormat:localizedString,num];
        }
        textLabel.text = tipString;
        textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"common_popup_text_color"];
        [tipView addSubview:textLabel];
        [textLabel release];
        //bottom label
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLeftGap, 175, tipView.frame.size.width-2*textLeftGap, 100)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.numberOfLines = 3;
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
        textLabel.text = NSLocalizedString(@"Download city package to find public numbers offline.",@"");
        textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"common_popup_text_color"];
        [tipView addSubview:textLabel];
        [textLabel release];

        
        
        TPItemButton *knownButton = [[TPItemButton alloc] initWithFrame:CGRectMake(53, 252, 212,40)];
        [knownButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_popup_button_normal@2x.png"] forState:UIControlStateNormal];
        [knownButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_popup_button_hg@2x.png"] forState:UIControlStateHighlighted];
        [knownButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_popup_button_text_color"] forState:UIControlStateNormal];
        if(!go){
          [knownButton addTarget:self action:@selector(removeTipView) forControlEvents:UIControlEventTouchUpInside];
          [knownButton setTitle:NSLocalizedString(@"OK",@"") forState:UIControlStateNormal];
        }else{
           [knownButton addTarget:self action:@selector(goToSmartSettingView) forControlEvents:UIControlEventTouchUpInside];
           [knownButton setTitle:NSLocalizedString(@"Go",@"") forState:UIControlStateNormal];
        }
        [tipView addSubview:knownButton];
        [knownButton release];

    }
    return self;
}
- (void)removeTipView{
    [self removeFromSuperview];
}
- (void)goToSmartSettingView{
    [self removeTipView];
    // TODO CallerTell city down
}
@end
