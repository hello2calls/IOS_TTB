//
//  InviteShareData.h
//  TouchPalDialer
//
//  Created by game3108 on 16/3/8.
//
//

#import <Foundation/Foundation.h>

@interface InviteShareData : NSObject
@property (nonatomic,readonly,copy) NSString *iosInviteIcon;
@property (nonatomic,readonly,copy) NSString *iosInviteIconFont;
@property (nonatomic,readonly,copy) NSString *inviteTitleText;
@property (nonatomic,readonly,copy) NSString *inviteTitleContent;
@property (nonatomic,readonly,copy) NSString *inviteFirstTitle;
@property (nonatomic,readonly,copy) NSString *inviteSecondTitle;
@property (nonatomic,readonly,copy) NSString *inviteLeftButtonText;
@property (nonatomic,readonly,copy) NSString *inviteRightButtonText;
@property (nonatomic,readonly,copy) NSString *shareHeaderTitle;
@property (nonatomic,readonly,copy) NSString *shareTitle;
@property (nonatomic,readonly,copy) NSString *shareMessage;
@property (nonatomic,readonly,copy) NSString *shareUrl;
@property (nonatomic,readonly,copy) NSString *shareImgUrl;
@property (nonatomic,readonly,copy) NSArray *shareList;
@property (nonatomic,readonly,copy) NSString *shareTargetPhone;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
@end
