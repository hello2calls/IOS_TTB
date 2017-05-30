//
//  AddressBookAccessUtility.h
//  TouchPalDialer
//
//  Created by Chen Lu on 9/21/12.
//
//

#import <Foundation/Foundation.h>

@interface AddressBookAccessUtility : NSObject

+(BOOL) isAccessible;

+(UIView *) accessHintImageView;

@end
