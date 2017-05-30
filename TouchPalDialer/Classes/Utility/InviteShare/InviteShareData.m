//
//  InviteShareData.m
//  TouchPalDialer
//
//  Created by game3108 on 16/3/8.
//
//

#import "InviteShareData.h"

@interface InviteShareData()

@property (nonatomic,readwrite,copy) NSString *iosInviteIcon;
@property (nonatomic,readwrite,copy) NSString *iosInviteIconFont;
@property (nonatomic,readwrite,copy) NSString *inviteTitleText;
@property (nonatomic,readwrite,copy) NSString *inviteTitleContent;
@property (nonatomic,readwrite,copy) NSString *inviteFirstTitle;
@property (nonatomic,readwrite,copy) NSString *inviteSecondTitle;
@property (nonatomic,readwrite,copy) NSString *inviteLeftButtonText;
@property (nonatomic,readwrite,copy) NSString *inviteRightButtonText;
@property (nonatomic,readwrite,copy) NSString *shareHeaderTitle;
@property (nonatomic,readwrite,copy) NSString *shareTitle;
@property (nonatomic,readwrite,copy) NSString *shareMessage;
@property (nonatomic,readwrite,copy) NSString *shareUrl;
@property (nonatomic,readwrite,copy) NSString *shareImgUrl;
@property (nonatomic,readwrite,copy) NSArray *shareList;
@property (nonatomic,readwrite,copy) NSString *shareTargetPhone;
@end

@implementation InviteShareData



- (instancetype) initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.iosInviteIcon          = dictionary[@"ios_invite_icon"];
        self.iosInviteIconFont      = dictionary[@"ios_invite_icon_font"];
        self.inviteTitleText        = dictionary[@"invite_title_text"];
        self.inviteTitleContent     = dictionary[@"invite_title_content"];
        self.inviteFirstTitle       = dictionary[@"invite_first_title"];
        self.inviteSecondTitle      = dictionary[@"invite_second_title"];
        self.inviteLeftButtonText   = dictionary[@"invite_left_button_text"];
        self.inviteRightButtonText  = dictionary[@"invite_right_button_text"];
        self.shareHeaderTitle       = dictionary[@"share_header_title"];
        self.shareTitle             = dictionary[@"share_title"];
        self.shareMessage           = dictionary[@"share_message"];
        self.shareUrl               = dictionary[@"share_url"];
        self.shareImgUrl            = dictionary[@"share_img_url"];
        self.shareList              = dictionary[@"share_list"];
        self.shareTargetPhone       = dictionary[@"share_target_phone"];
    }
    return self;
}
@end
