//
//  FuwuhaoModel.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import <Foundation/Foundation.h>
#import "IndexFilter.h"

@interface PublicNumberModel : NSObject
@property (nonatomic, retain)NSString *userPhone;
@property (nonatomic, retain)NSString *sendId;
@property (nonatomic, retain)NSString *name;
@property (nonatomic, retain)NSString *data;
@property (nonatomic, retain)NSString *menus;
@property (nonatomic, retain)NSString *errorUrl;
@property (nonatomic, retain)NSString *iconPath;
@property (nonatomic, retain)NSString *iconLink;
@property (nonatomic, retain)NSString *logoPath;
@property (nonatomic, retain)NSString *logoLink;
@property (nonatomic, retain)NSString *compName;
@property (nonatomic, retain)NSString *desc;
@property (nonatomic, retain)NSString *msgContent;
@property (nonatomic, retain)IndexFilter *filter;
@property (nonatomic, assign)int available;
@property (nonatomic, assign)int newMsgCount;
@property (nonatomic, assign)NSInteger newMsgTime;
@property (nonatomic, assign)NSInteger ifNoah;
@property (nonatomic, retain)NSString* url;

- (id)initWithPhone:(NSString *)userPhone sendId:(NSString *)sendId name:(NSString *)name data:(NSString *)data menus:(NSString *)menus errorUrl:(NSString *)errorUrl icon:(NSString *)iconLink logo:(NSString *)logoLink compName:(NSString *)compName desc:(NSString *)desc andAvailible:(int)available andFilter:(NSDictionary*)filter andUrl:(NSString*)url;
- (BOOL)isValid;
@end
