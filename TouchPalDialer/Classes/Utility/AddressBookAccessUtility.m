//
//  AddressBookAccessUtility.m
//  TouchPalDialer
//
//  Created by Chen Lu on 9/21/12.
//
//

#import "AddressBookAccessUtility.h"
#import <AddressBook/AddressBook.h>
#import "TPDialerResourceManager.h"
#import "UIDevice+SystemVersion.h"

#define IPHONE4 TPScreenHeight() < 500

@interface AddressBookAccessUtility()
+(UILabel*) commonLabel;
@end

@implementation AddressBookAccessUtility

+(BOOL)isAccessible
{
    if ([UIDevice systemVersionLessThanMajor:6 minor:0]) {
        return true;
    }
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    return status == kABAuthorizationStatusAuthorized;
}

+(UIView *) accessHintImageView
{
//    TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
//    UIImage* bgImage = [manager getImageByName:@"ab_access_hint_bg@2x.png"];
//    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImage *image = [TPDialerResourceManager getImage:@"feature_guide_title@2x.png"];
    UIImageView *titleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(TPScreenWidth() / 2 - image.size.width / 2, TPScreenHeight() * (IPHONE4 ? 0.16 : 0.22), image.size.width, image.size.height)];
    titleImageView.image = image;
    titleImageView.hidden = YES;
    [view addSubview:titleImageView];
//
//    // image
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
//    CGRect frame = imageView.frame;
//    frame.origin.x = (TPScreenWidth() - 320)/2;
//    frame.origin.y = (TPAppFrameHeight() - bgImage.size.height) / 2;
//    imageView.frame = frame;
//    [view addSubview:imageView];
//    
//    // message
//    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(43, 87, 290, 40)];
//    msg.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackgroundWhite_color"];
//    msg.backgroundColor = [UIColor clearColor];
//    msg.font = [UIFont systemFontOfSize:15];
//    msg.text = NSLocalizedString(@"ab_access_hint_message", @"");
//    [imageView addSubview:msg];
//    
//    // settings
//    UILabel* settings = [self commonLabel];
//    settings.frame = CGRectMake(16, 242, 80, 30);
//    settings.text = NSLocalizedString(@"ab_access_hint_settings", @"");
//    [imageView addSubview:settings];
//    
//    // privacy
//    UILabel* privacy = [self commonLabel];
//    privacy.frame = CGRectMake(118, 242, 80, 30);
//    privacy.text = NSLocalizedString(@"ab_access_hint_privacy", @"");
//    [imageView addSubview:privacy];
//    
//    // contacts
//    UILabel* contacts = [self commonLabel];
//    contacts.frame = CGRectMake(220, 242, 80, 30);
//    contacts.text = NSLocalizedString(@"ab_access_hint_contacts", @"");
//    [imageView addSubview:contacts];
//    
//    // on/off
//    UILabel* onOff = [self commonLabel];
//    onOff.frame = CGRectMake(220, 365, 80, 30);
//    onOff.text = NSLocalizedString(@"ab_access_hint_on", @"");
//    [imageView addSubview:onOff];
//    
//    // appName
//    UILabel* appName = [[UILabel alloc] initWithFrame:CGRectMake(80, 320, 150, 50)];
//    appName.backgroundColor = [UIColor clearColor];
//    appName.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultTextBlack_color"];
//    appName.text = NSLocalizedString(@"ab_access_hint_appName", @"");
//    appName.font = [UIFont systemFontOfSize:20];
//    [imageView addSubview:appName];
    
    return view;
}

+(UILabel*) commonLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultTextBlack_color"];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    return  label;
}

@end
