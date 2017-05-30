//
//  GestureUtility.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ActionCall,
    ActionSMS,
    ActionNone,
}GestureActionType;
typedef enum {
    FirstItemType,
    LastItemType,
    OtherItemType,
}ItemType;

@interface GestureUtility : NSObject
 +(BOOL)isValideGesture:(NSString *)key;
 +(NSString *)getNameContent:(NSString *)tmpname;
 +(NSString *)getShortName:(NSString *)name;
 +(NSString *)getDisplayName:(NSString *)name;
 +(NSString *)getPhoneNumber:(NSString *)name;
 +(NSString *)getName:(NSString *)name;
 +(NSString *)serializerName:(NSString *)number withPersonID:(NSInteger)personID withAction:(GestureActionType)type;
 +(GestureActionType)getActionType:(NSString *)name;
 +(ItemType)getGestureItemType:(NSString *)name;
 +(NSInteger)getPersonID:(NSString *)name withAction:(GestureActionType)type;
 +(NSString *)getNumber:(NSString *)name withAction:(GestureActionType)type;
 +(NSArray *)getOftenContactsList;
 +(NSString *)getSerializeName:(NSString *)name;
@end
