//
//  ContactSpecialManager.m
//  TouchPalDialer
//
//  Created by game3108 on 15/4/21.
//
//

#import "ContactSpecialManager.h"
#import "ContactSpecialInfo.h"
#import "TouchpalMembersManager.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import "CootekNotifications.h"
static ContactSpecialManager *instance;
@implementation ContactSpecialManager

//TTB修改
+ (void)initialize{
    instance = [[ContactSpecialManager alloc]init];
    instance.specialArray = [NSMutableArray array];
//    [instance generateSpecial:NODE_MY_FAMILY];
    [instance generateSpecial:NODE_TOUCHPALER];
//    [instance generateSpecial:NODE_CONTACT_INVITE];
    [instance generateSpecial:NODE_CONTACT_SMART_GROUP];
//    if ([FunctionUtility systemVersionFloat] >= 7.0) {
        // qr scaning is not natively available until ios 7.0
        // we need AVFoundation
//        [instance generateSpecial:NODE_CONTACT_TRANSFER];
//    }
}

+ (instancetype) instance{
    return instance;
}

//TTB修改
- (void) generateSpecial:(SpecialNodeType)type{
    ContactSpecialInfo *info = [self getContactType:type];
    
    switch (type) {
        case NODE_MY_FAMILY: {
                info = [[ContactSpecialInfo alloc]init];
                info.type = NODE_MY_FAMILY;
                info.mainTitle = @"我的亲情号";
                info.text = @"s";
                info.number = [self getTouchpalerFamilyArrayCount];
                info.textColorStyle = @"tp_color_white";
                info.fontName = @"iPhoneIcon1";
                info.bgColorStyle = @"tp_color_light_blue_500";
                [self.specialArray insertObject:info atIndex:0];
            break;
        }
    
            
        case NODE_TOUCHPALER: {
            if (info) {
                if ( [UserDefaultsManager boolValueForKey:IS_VOIP_ON] ){
                    info.number = [self getTouchpalerNumber];
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
                }else{
                    [self.specialArray removeObject:info];
                }

            } else {
                // info == nil
                if ( [UserDefaultsManager boolValueForKey:IS_VOIP_ON]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
                    info = [[ContactSpecialInfo alloc]init];
                    info.type = NODE_TOUCHPALER;
                    info.mainTitle = @"触宝好友";
                    info.fontName = @"iPhoneIcon3";
                    info.text = @"I";
                    info.textColorStyle = @"tp_color_white";
                    info.bgColorStyle = @"tp_color_light_blue_500";
                    info.number = [self getTouchpalerNumber];
//                    [self.specialArray insertObject:info atIndex:1];
                    [self.specialArray insertObject:info atIndex:0];

                }
            }
            break;
        }
        case NODE_CONTACT_TRANSFER: {
            info = [[ContactSpecialInfo alloc]init];
            info.type = NODE_CONTACT_TRANSFER;
            info.mainTitle = @"通讯录迁移";
            info.text = @"6";
            info.textColorStyle = @"tp_color_white";
            info.fontName = @"iPhoneIcon2";
            info.bgColorStyle = @"tp_color_light_blue_500";
            [self.specialArray addObject:info];
            break;
        }
        case NODE_CONTACT_SMART_GROUP: {
            info = [[ContactSpecialInfo alloc]init];
            info.type = NODE_CONTACT_SMART_GROUP;
            info.mainTitle = NSLocalizedString(@"Smart group", @"智能分组");
            info.text = @"n";
            info.textColorStyle = @"tp_color_white";
            info.fontName = @"iPhoneIcon1";
            info.bgColorStyle = @"tp_color_light_blue_500";
            [self.specialArray addObject:info];
            break;
        }
        case NODE_CONTACT_INVITE: {
            if (info) {
                if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] != nil){
                    
                }else{
                    [self.specialArray removeObject:info];
                }
                
            }else if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] != nil){
                    info = [[ContactSpecialInfo alloc]init];
                    info.type = NODE_CONTACT_INVITE;
                    info.mainTitle = NSLocalizedString(@"invite_friends", @"邀请有奖");
                    info.text = @"h";
                    info.textColorStyle = @"tp_color_white";
                    info.fontName = @"iPhoneIcon2";
                    info.bgColorStyle = @"tp_color_light_blue_500";
                    if ( [UserDefaultsManager boolValueForKey:IS_VOIP_ON]){
                        [self.specialArray insertObject:info atIndex:2];
                    }else{
                        [self.specialArray insertObject:info atIndex:1];
                    }
            }else{
                [self.specialArray removeObject:info];
            }
            break;
        }
        case NODE_UNKOWN:
        default: {
            break;
        }
    }
}

- (NSInteger) getTouchpalerNumber{
    if ( ![UserDefaultsManager boolValueForKey:VOIP_FIRST_VISIT_TOUCHPAL_PAGE_WITH_ALERT defaultValue:NO] ){
        cootek_log(@"%d",[TouchpalMembersManager getTouchpalerArrayCount]);
        return [TouchpalMembersManager getTouchpalerArrayCount];
    }else{
        cootek_log(@"%d",[TouchpalMembersManager getNewTouchpalerArraycount]);
        return [TouchpalMembersManager getNewTouchpalerArraycount];
    }
}

- (NSInteger) getTouchpalerFamilyArrayCount {
    return [TouchpalMembersManager getTouchpalerFamilyArrayCount];
}

- (ContactSpecialInfo *) getContactType:(SpecialNodeType)type{
    for ( ContactSpecialInfo *info in self.specialArray ){
        if ( info.type == type ){
            return info;
        }
    }
    return nil;
}

//TTB修改
- (NSArray *)getSpecialArray{
    [self generateSpecial:NODE_TOUCHPALER];
//    [self generateSpecial:NODE_CONTACT_INVITE];
    return self.specialArray;
}

@end
