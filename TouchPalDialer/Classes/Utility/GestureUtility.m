//
//  GestureUtility.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GestureUtility.h"
#import "ContactCacheDataManager.h"
#import "CallLog.h"
#import "NSString+PhoneNumber.h"

#define CALL_LENGTH 5
#define SMS_LENGTH  4

@implementation GestureUtility
+(NSString *)getNameContent:(NSString *)tmpname{
    NSString *name = [GestureUtility getDisplayName:tmpname];
    name = [NSString stringWithFormat:@"%@%@",[[name substringToIndex:3] lowercaseString],[name substringFromIndex:3]];
    return name;
}
+(BOOL)isValideGesture:(NSString *)key{
    ItemType itemType = [GestureUtility getGestureItemType:key];
    BOOL is_number = NO;
    if (itemType == FirstItemType) {
        is_number = YES;
    }else {
        GestureActionType type = [GestureUtility getActionType:key];
        NSInteger personID = [GestureUtility getPersonID:key withAction:type];
        NSString *number = [GestureUtility getNumber:key  withAction:type];
        is_number = [[ContactCacheDataManager instance] isCacheItemNumber:personID withNumber:number];
    }
    return is_number;
}
+(NSString *)getShortName:(NSString *)name{
    NSString *display = @"";
    if ([name hasPrefix:@"Call_"]) {
        if ([name isEqualToString:@"Call_First"]) {
            display = NSLocalizedString(@"Make a call to first number of list",@"打电话给列表第一个号码");
        }else{
            display = NSLocalizedString(@"Call",@"拨打");
            NSString *idNumber = [name substringFromIndex:CALL_LENGTH];
            NSRange   position = [idNumber rangeOfString:@"_"];
            NSString *number = [idNumber substringFromIndex:position.location+position.length];
            display = [NSString stringWithFormat:@"%@:%@",display,number];
        }
    }else if ([name hasPrefix:@"Sms_"]) {
        if ([name isEqualToString:@"Sms_First"]) {
            display =NSLocalizedString(@"Send a SMS to first number of list",@"发短信给列表第一个号码");
        }else{
            display =  NSLocalizedString(@"SMS",@"发短信");
            NSString *idNumber = [name substringFromIndex:SMS_LENGTH];
            NSRange   position = [idNumber rangeOfString:@"_"];
            NSString *number = [idNumber substringFromIndex:position.location+position.length];
            display = [NSString stringWithFormat:@"%@:%@",display,number];
        }
    }else {
        display = name;
    }
    return display;
}
+(NSString *)getDisplayName:(NSString *)name{
        NSString *display = @"";
        if ([name hasPrefix:@"Call_"]) {
            if ([name isEqualToString:@"Call_First"]) {
                display = NSLocalizedString(@"Make a call to first number of list",@"打电话给列表第一个号码");
            }else{
                display = NSLocalizedString(@"Call",@"拨打");
                NSString *idNumber = [name substringFromIndex:CALL_LENGTH];
                NSRange   position = [idNumber rangeOfString:@"_"];
                NSString *number = [idNumber substringFromIndex:position.location+position.length];
                NSInteger personID = [[idNumber substringToIndex:position.location] intValue];
                NSString *personName = [[ContactCacheDataManager instance] contactCacheItem:personID].fullName;
                display = [NSString stringWithFormat:@"%@ %@ %@",display,personName,number];
            }
        }else if ([name hasPrefix:@"Sms_"]) {
            if ([name isEqualToString:@"Sms_First"]) {
                display =NSLocalizedString(@"Send a SMS to first number of list",@"发短信给列表第一个号码");
            }else{
                display =  NSLocalizedString(@"SMS",@"发短信");
                NSString *idNumber = [name substringFromIndex:SMS_LENGTH];
                NSRange   position = [idNumber rangeOfString:@"_"];
                NSString *number = [idNumber substringFromIndex:position.location+position.length];
                NSInteger personID = [[idNumber substringToIndex:position.location] intValue];
                NSString *personName = [[ContactCacheDataManager instance] contactCacheItem:personID].fullName;
                display = [NSString stringWithFormat:@"%@ %@ %@",display,personName,number];
            }
        }else {
            display = name;
        }
        return display;
}

+(NSString *)getPhoneNumber:(NSString *)name{
    NSString *display = @"";
    if ([name hasPrefix:@"Call_"]) {
        if (![name isEqualToString:@"Call_First"]) {
            NSString *idNumber = [name substringFromIndex:CALL_LENGTH];
            NSRange   position = [idNumber rangeOfString:@"_"];
            NSString *number = [idNumber substringFromIndex:position.location+position.length];
            display = [NSString stringWithFormat:@"%@",[number formatPhoneNumber]];
        }
    }else {
        display = name;
    }
    return display;
}

+(NSString *)getName:(NSString *)name{
    NSString *display = @"";
    if ([name hasPrefix:@"Call_"]) {
        if (![name isEqualToString:@"Call_First"]) {
            NSString *idNumber = [name substringFromIndex:CALL_LENGTH];
            NSRange   position = [idNumber rangeOfString:@"_"];
            NSInteger personID = [[idNumber substringToIndex:position.location] intValue];
            NSString *personName = [[ContactCacheDataManager instance] contactCacheItem:personID].fullName;
            display = [NSString stringWithFormat:@"%@",personName];
        }
    }else {
        display = name;
    }
    return display;
}

+(NSString *)getSerializeName:(NSString *)name{
    NSString *display = @"";
    if ([name hasPrefix:@"Call_"]) {
        if (![name isEqualToString:@"Call_First"]) {
            NSString *idNumber = [name substringFromIndex:CALL_LENGTH];
            NSRange   position = [idNumber rangeOfString:@"_"];
            NSString *number = [idNumber substringFromIndex:position.location+position.length];
            NSInteger personID = [[idNumber substringToIndex:position.location] intValue];
            NSString *personName = [[ContactCacheDataManager instance] contactCacheItem:personID].fullName;
            display = [NSString stringWithFormat:@"%@ %@",personName,[number formatPhoneNumber]];
        }
    }else {
        display = name;
    }
    return display;
}
+(NSString *)serializerName:(NSString *)number withPersonID:(NSInteger)personID withAction:(GestureActionType)type{
    NSString *key = @"";
    switch (type) {
        case ActionCall:
            key = @"Call";
            break;
        case ActionSMS:
            key = @"Sms";
            break;  
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@_%d_%@",key,personID,number];
}
+(GestureActionType)getActionType:(NSString *)name{
    if ([name hasPrefix:@"Call_"]) {
        return ActionCall;
    }else if ([name hasPrefix:@"Sms_"]){
        return ActionSMS;
    }else {
        return ActionNone;
    }
}
+(ItemType)getGestureItemType:(NSString *)name{
    if ([name hasSuffix:@"First"]) {
        return FirstItemType;
    }else {
        return OtherItemType;
    }
}
+(NSInteger)getPersonID:(NSString *)name withAction:(GestureActionType)type{
    int length = 0;
    switch (type) {
        case ActionSMS:
            length =  SMS_LENGTH;
            break;
        case ActionCall:
            length =  CALL_LENGTH;
            break;    
        default:
            break;
    }
    NSString *idNumber = [name substringFromIndex:length];
    NSRange   position = [idNumber rangeOfString:@"_"];
    return  [[idNumber substringToIndex:position.location] intValue];
}

+(NSString *)getNumber:(NSString *)name withAction:(GestureActionType)type{
    int length = 0;
    switch (type) {
        case ActionSMS:
            length =  SMS_LENGTH;
            break;
        case ActionCall:
            length =  CALL_LENGTH;
            break;    
        default:
            break;
    }
    NSString *idNumber = [name substringFromIndex:length];
    NSRange   position = [idNumber rangeOfString:@"_"];
    NSString *number = [[idNumber substringFromIndex:position.location+position.length] digitNumber];
    return  number;
}

+(NSArray *)getOftenContactsList{
    WhereDataModel *condition = [[WhereDataModel alloc] init];
    condition.fieldKey = [DataBaseModel getKWhereKeyPersonID];
    condition.oper = [DataBaseModel getKWhereOperationLarger];
    condition.fieldValue = [NSString stringWithFormat:@"%d", 0];
    NSArray *condition_arr = [NSArray arrayWithObject:condition];
    //group by
    NSMutableArray* group_array=[[NSMutableArray alloc] init];
    [group_array addObject:[DataBaseModel getKGroupByKeyPersonId]];

    
    NSMutableArray *order_arr = [NSMutableArray arrayWithCapacity:1];
    LabelDataModel *order = [[LabelDataModel alloc] init];
    order.labelKey = [DataBaseModel getKOrderByKeyCallCount];
    order.labelValue = [DataBaseModel getKOrderByKeyValueDesc];
    [order_arr addObject:order];
    
    order = [[LabelDataModel alloc] init];
    order.labelKey = [DataBaseModel getKOrderByKeyCallTime];
    order.labelValue = [DataBaseModel getKOrderByKeyValueDesc];
    [order_arr addObject:order];

    NSArray *calllog_list=[CallLog calllogsByCondition:condition_arr
                                          GroupByCause:group_array
                                          OrderByCause:order_arr];
    return calllog_list;
}
@end
