//
//  ContactTransferRecord.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/8.
//
//

#ifndef ContactTransferRecord_h
#define ContactTransferRecord_h

#import <Foundation/Foundation.h>
#import "ContactTransferItem.h"

@interface ContactTransferRecord : NSObject
- (instancetype) initWithRecordID: (ABRecordID) recordID;
- (instancetype) initWithCachedModel: (ContactCacheDataModel *) model;
- (instancetype) initWithDictionary: (NSDictionary *) receivedDict;
- (NSString *) toJSONString;

- (BOOL) writeToContact;

@property (nonatomic) NSArray *items;
@property (nonatomic) NSDictionary *dict;
@property (nonatomic) ABRecordRef recordRef;;
@property (nonatomic) CNContact *contact;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) ContactTransferRecordType type;

@end

#endif /* ContactTransferRecord_h */
