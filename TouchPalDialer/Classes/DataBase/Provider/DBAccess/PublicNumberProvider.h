//
//  PublicNumberProvider.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import <Foundation/Foundation.h>
#import "PublicNumberMessage.h"


@interface PublicNumberProvider : NSObject

+ (BOOL)addPublicNumberInfos:(NSArray *)infos;

+ (BOOL)addPublicNumberMsgs:(NSArray *)msgs withTheBeforeMsgId:(PublicNumberMessage*)theBeforeMsg andIfNoah:(BOOL)ifNoah;

+ (BOOL)getPublicNumberInfos:(NSMutableArray *)infos;

+ (BOOL)getPublicNumberMsgs:(NSMutableArray *)array withNoahArray:(NSMutableArray *)noahArray withSendId:(NSString *)sendId count:(int)count fromMsgId:(NSString *)msgId;

+ (BOOL)clearNewCountForServiceId:(NSString *)serviceId;

+ (BOOL)getNeedDownloadLinks:(NSMutableArray *)links;

+ (BOOL)saveDownloadLinks:(NSDictionary *)linkPaths;

+ (BOOL)updatePublicInfoWithSendId:(NSString *)sendId newCount:(int)newCount content:(NSString *)newContent andCreateTime:(NSInteger)createTime;
+ (BOOL)updatePublicInfoDescriptionWithSendId:(NSString*)sendId;
+ (BOOL)deleteAllPublicNumberByServiceId:(NSString *)serviceId;
+ (BOOL)deletePublicNumberMsg:(PublicNumberMessage *)message;
+ (int)getNewMsgCount;

+ (NSString*) userPhone;

@end
