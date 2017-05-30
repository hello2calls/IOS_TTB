//
//  FuwuhaoMessage.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import "PublicNumberMessage.h"
#import "PublicNumberProvider.h"
#import "NSDictionary+Default.h"

@implementation PublicNumberMessage

- (id)initWithMsg:(NSDictionary *)msgJson {
    NSString* description = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[msgJson objectForKey:@"description"] options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString* remark = @"";
    NSString* keynotes = @"";
    if ([msgJson objectForKey:@"remark"]) {
        remark = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[msgJson objectForKey:@"remark"] options:0 error:nil] encoding:NSUTF8StringEncoding];
    }
    if ([msgJson objectForKey:@"remark"]) {
        keynotes = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[msgJson objectForKey:@"keynotes"] options:0 error:nil] encoding:NSUTF8StringEncoding];
    }
    NSString* link = @"";
    if ([msgJson objectForKey:@"link"]) {
        link = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[msgJson objectForKey:@"link"] options:0 error:nil] encoding:NSUTF8StringEncoding];
    }
    NSString* nativeUrl = @"";
    NSDictionary* ntvDic = [msgJson objectForKey:@"native_url"];
    if (ntvDic) {
        
        if ([[ntvDic allKeys] containsObject:@"ios"]) {
            nativeUrl = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[ntvDic objectForKey:@"ios"] options:0 error:nil] encoding:NSUTF8StringEncoding];
        }
    }
    NSDictionary* filter = [msgJson objectForKey:@"filter"];
    
    PublicNumberMessage *msg = [[PublicNumberMessage alloc]init];
    msg.msgId = [msgJson objectForKey:@"msg_id"];
    msg.userPhone = [PublicNumberProvider userPhone];
    msg.type = [msgJson objectForKey:@"msg_type"];
    msg.notifyType = [msgJson objectForKey:@"notify"];
    msg.title = [msgJson objectForKey:@"title"];
    msg.desc = description;
    msg.notification = [msgJson objectForKey:@"notification"];
    msg.remark = remark;
    msg.keynotes = keynotes;
    msg.sendId = [msgJson objectForKey:@"service_id"];
    msg.createTime = [msgJson objectForKey:@"create_time"];
    msg.status = 1;
    msg.source = @"";
    msg.url = link;
    msg.iconLink = [msgJson objectForKey:@"icon_link"];
    msg.nativeUrl = nativeUrl;
    if (filter && [filter isKindOfClass:[NSDictionary class]] && filter.count > 0) {
        msg.filter = [[IndexFilter alloc]initWithJson:filter];
    }
    msg.statKey = [msgJson objectForKey:@"stat_key"];
    
    return msg;
}


-(BOOL)isValid{
    if (!_filter || [_filter isValid]) {
        return YES;
    }
    
    return NO;
}

-(BOOL)hasStatKey{
    if (self.statKey && [self.statKey length] > 0) {
        return YES;
    }
    return NO;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    PublicNumberMessage* ret = [[[self class] alloc] init];
    ret.msgId = [self.msgId copyWithZone:zone];
    ret.userPhone = [self.userPhone copyWithZone:zone];
    ret.type = [self.type copyWithZone:zone];
    ret.notifyType = [self.notifyType copyWithZone:zone];
    ret.title = [self.title copyWithZone:zone];
    ret.desc = [self.desc copyWithZone:zone];
    ret.notification = [self.notification copyWithZone:zone];
    ret.remark = [self.remark copyWithZone:zone];
    ret.keynotes = [self.keynotes copyWithZone:zone];
    ret.sendId = [self.sendId copyWithZone:zone];
    ret.createTime = [self.createTime copyWithZone:zone];
    ret.status = self.status ;
    ret.source = [self.source copyWithZone:zone];
    ret.url = [self.url copyWithZone:zone];
    ret.nativeUrl = [self.nativeUrl copyWithZone:zone];
    ret.statKey = [self.statKey copyWithZone:zone];
    ret.iconLink = [self.iconLink copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    PublicNumberMessage* ret = [[[self class] alloc] init];
    ret.msgId = [self.msgId mutableCopyWithZone:zone];
    ret.userPhone = [self.userPhone mutableCopyWithZone:zone];
    ret.type = [self.type mutableCopyWithZone:zone];
    ret.notifyType = [self.notifyType mutableCopyWithZone:zone];
    ret.title = [self.title mutableCopyWithZone:zone];
    ret.desc = [self.desc mutableCopyWithZone:zone];
    ret.notification = [self.notification mutableCopyWithZone:zone];
    ret.remark = [self.remark mutableCopyWithZone:zone];
    ret.keynotes = [self.keynotes mutableCopyWithZone:zone];
    ret.sendId = [self.sendId mutableCopyWithZone:zone];
    ret.createTime = [NSNumber numberWithInteger:[self.createTime intValue]];
    ret.status = self.status ;
    ret.source = [self.source mutableCopyWithZone:zone];
    ret.url = [self.url mutableCopyWithZone:zone];
    ret.nativeUrl = [self.url mutableCopyWithZone:zone];
    ret.statKey = [self.statKey mutableCopyWithZone:zone];
    ret.iconLink = [self.iconLink mutableCopyWithZone:zone];
    
    return ret;
}
@end
