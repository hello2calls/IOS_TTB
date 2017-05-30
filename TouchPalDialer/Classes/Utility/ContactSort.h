//
//  ContactSort.h
//  TouchPalDialer
//
//  Created by Sendor on 11-11-1.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _tagContactItemType {
    ContactItemTypeContactCacheDataModel,
} ContactItemType;

@interface ContactSort : NSObject {

}

+ (NSArray*)sortContactByFirstLetter:(NSArray*)unsortedArray itemType:(ContactItemType)itemType;
NSInteger compareContactCacheDataModel(id num1, id num2, void *context);
NSInteger compareGestureItemModel(id obj1, id obj2, void *context);
@end
