//
//  ContactSort.m
//  TouchPalDialer
//
//  Created by Sendor on 11-11-1.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "ContactSort.h"
#import "ContactCacheDataModel.h"
#import "LangUtil.h"
#import "SelectCellView.h"

@implementation ContactSort

+ (NSArray*)sortContactByFirstLetter:(NSArray*)unsortedArray itemType:(ContactItemType)itemType {
    if (itemType == ContactItemTypeContactCacheDataModel) {
        return [unsortedArray sortedArrayUsingFunction:compareContactCacheDataModel context:nil];
    }
    return nil;
}

NSInteger compareContactCacheDataModel(id obj1, id obj2, void *context) {
	NSString *obj1_str = [(ContactCacheDataModel *)obj1 fullName];
	NSString *obj2_str = [(ContactCacheDataModel *)obj2 fullName];
	wchar_t char_1 = getFirstLetter(NSStringToFirstWchar(obj1_str));
	wchar_t char_2 = getFirstLetter(NSStringToFirstWchar(obj2_str));
	if (char_1 > char_2) {
		return NSOrderedDescending;
	} else if (char_1 == char_2) {
        return [obj1_str compare:obj2_str options:NSWidthInsensitiveSearch];
	} else {
		return NSOrderedAscending;
	}
}
@end
