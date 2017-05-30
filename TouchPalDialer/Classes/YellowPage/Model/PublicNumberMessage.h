//
//  FuwuhaoMessage.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import <Foundation/Foundation.h>
#import "IndexFilter.h"

@interface PublicNumberMessageItem : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *colorString;
@end

@interface PublicNumberMessage : NSObject<NSCopying, NSMutableCopying>

@property (nonatomic, retain)NSString *msgId;
@property (nonatomic, retain)NSString *userPhone;
@property (nonatomic, retain)NSString *title;
@property (nonatomic, retain)NSString *type;
@property (nonatomic, retain)NSString *notifyType;
@property (nonatomic, retain)NSString *desc;
@property (nonatomic, retain)NSString *notification;
@property (nonatomic, retain)NSString *remark;
@property (nonatomic, retain)NSString *keynotes;
@property (nonatomic, retain)NSString *sendId;
@property (nonatomic, retain)NSNumber* createTime;
@property (nonatomic, retain)NSNumber* receiveTime;
@property (nonatomic, assign)int status;
@property (nonatomic, retain)NSString *source;
@property (nonatomic, retain)NSString *prevMsg;
@property (nonatomic, retain)NSString *url;
@property (nonatomic, retain)NSString *nativeUrl;
@property (nonatomic, retain)IndexFilter *filter;
@property (nonatomic, assign)NSInteger ifNoah;
@property (nonatomic, retain)NSString *statKey;
@property (nonatomic, retain)NSString *iconLink;

- (id)initWithMsg:(NSDictionary *)msgJson;
- (BOOL)isValid;
- (BOOL)hasStatKey;
@end
