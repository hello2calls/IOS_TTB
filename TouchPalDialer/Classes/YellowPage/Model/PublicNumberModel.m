//
//  FuwuhaoModel.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import "PublicNumberModel.h"
@implementation PublicNumberModel
    
- (id)initWithPhone:(NSString *)userPhone sendId:(NSString *)sendId name:(NSString *)name data:(NSString *)data menus:(NSString *)menus errorUrl:(NSString *)errorUrl icon:(NSString *)iconLink logo:(NSString *)logoLink compName:(NSString *)compName desc:(NSString *)desc andAvailible:(int)available andFilter:(NSDictionary *)filter andUrl:(NSString *)url{
    PublicNumberModel * model = [PublicNumberModel new];
    model.userPhone = userPhone;
    model.sendId = sendId;
    model.name = name;
    model.data = data;
    model.menus = menus;
    model.errorUrl = errorUrl;
    model.iconLink = iconLink;
    model.logoLink = logoLink;
    model.compName = compName;
    model.desc = desc;
    model.available = available;
    model.url = url;
    if (filter && filter.count > 0) {
        model.filter = [[IndexFilter alloc]initWithJson:filter];
    }
    
    return model;
}

-(BOOL)isValid{
    if (!_filter || [_filter isValid]) {
        return YES;
    }
    
    return NO;
}
@end
