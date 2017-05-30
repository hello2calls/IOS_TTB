//
//  ContactTransferItem.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/8.
//
//

#import <Foundation/Foundation.h>
#import "ContactTransferItem.h"

// common item
@implementation ContactTransferCommonItem
- (NSString *) toJSONString {
    if (dict) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
        if (!error && data) {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

- (instancetype) initWithJSONString:(NSString *)jsonString {
    if (jsonString) {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!dict) {
            return nil;
        }
    }
    return [super init];
}

- (void) setupDict {
    
}

@end
// --- end: common item --- //


// note item
@implementation ContactTransferNoteItem
- (instancetype) initWithDict:(NSDictionary *)info {
    if (!info) return nil;
    self = [super init];
    if (self){
        mimetype = MIME_TYPE_NOTE;
        _note = [info objectForKey:KEY_NOTE];
    }
    return self;
}

- (instancetype) initWithJSONString:(NSString *)jsonString {
    self = [super initWithJSONString:jsonString];
    if (dict) {
        mimetype = MIME_TYPE_NOTE;
        _note = [dict objectForKey:KEY_NOTE];
    }
    return self;
}

- (void) setupDict {
    if (!_note) {
        return;
    }
    dict = @{
             KEY_MIME_TYPE: mimetype,
             KEY_NOTE: _note
             };
}

@end
// --- end: note item  --- //


// website item
@implementation ContactTransferURLItem

@end
// --- end: website item  --- //

// nickname item
@implementation ContactTransferNicknameItem
- (instancetype) initWithLabelDataModel:(LabelDataModel *)model {
    return nil;
}

- (void) setupDict {
    if (!_nickname) {
       return;
    }
    dict = @{
             KEY_MIME_TYPE: mimetype,
             KEY_NOTE: _nickname
             };
}


@end
// --- end: nickname item  --- //

// email item
@implementation ContactTransferEmailItem
- (instancetype) initWithLabelDataModel:(LabelDataModel *)model {
    return nil;
}

- (void) setupDict {
}
@end
// --- end: email item  --- //


// address item
@implementation ContactTransferAddressItem
- (instancetype) initWithLabelDataModel:(LabelDataModel *)model {
    return nil;
}

- (void) setupDict {
}
@end
// --- end: address item  --- //


