//
//  ContactTransferItem.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/8.
//
//

#ifndef ContactTransferItem_h
#define ContactTransferItem_h

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import "ContactTransferConst.h"
#import "PersonDBA.h"
#import "LabelDataModel.h"

// commonItem
@interface ContactTransferCommonItem : NSObject {
    NSDictionary *dict;
    NSString *mimetype;
    ContactTransferItemType itemtype;
}
- (instancetype) initWithJSONString: (NSString *) jsonString;
- (void) setupDict;

- (NSString *) toJSONString;

@end


// note item
@interface ContactTransferNoteItem : ContactTransferCommonItem
@property (nonatomic, readonly) NSString *note;
@end

@interface ContactTransferURLItem : ContactTransferCommonItem

@end

// nickname item
@interface ContactTransferNicknameItem : ContactTransferCommonItem
@property (nonatomic, readonly) NSString *nickname;
@end

// email
@interface ContactTransferEmailItem : ContactTransferCommonItem
@end


//  number item
@interface ContactTransferNumberItem: ContactTransferCommonItem
@end

// address item
@interface ContactTransferAddressItem: ContactTransferCommonItem
@end

// displayName item 
@interface ContactTransferDisplayNameItem: ContactTransferCommonItem
@end


#endif /* ContactTransferItem_h */
