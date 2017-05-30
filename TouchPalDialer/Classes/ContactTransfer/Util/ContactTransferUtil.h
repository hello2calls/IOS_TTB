//
//  ContactTransferUtil.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/9.
//
//

#ifndef ContactTransferUtil_h
#define ContactTransferUtil_h

#import <Foundation/Foundation.h>
#import "ContactTransferItem.h"

@interface ContactTransferUtil : NSObject

+ (NSString *) getMimeStringByItemType:(ContactTransferItemType)itemType;
+ (NSArray *) getItemsByCachedModel:(ContactCacheDataModel *)model;
+ (NSArray *) getItemsByRecordID:(NSInteger)recordID;

+ (NSString *) getRecordTypeString:(ContactTransferRecordType)recordType;
+ (NSString *) getRecordKeyByType:(ContactTransferRecordType)recordType recordID:(NSString *)recordID;

+ (ContactTransferRecordType) getRecordType:(NSInteger)recordID;
+ (ContactTransferRecordType) getRecordTypeByString:(NSString *)typeStr;

+ (void) resovleForRecord:(NSArray *)rawInfo recordRef:(ABRecordRef)recordRef;
+ (CNContact *) resovleForCNContact:(NSArray *)rawInfo;

+ (NSString *) getQRString;

@end

#endif /* ContactTransferUtil_h */
