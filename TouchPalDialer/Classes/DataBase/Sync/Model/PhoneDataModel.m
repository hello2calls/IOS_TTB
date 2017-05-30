//
//  PhoneDataModel.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-25.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "PhoneDataModel.h"
#import "NSString+PhoneNumber.h"
#import "PhoneNumber.h"

@implementation PhoneDataModel

@synthesize phoneID;
@synthesize number;
@synthesize displayNumber;
@synthesize digitNumber;
@synthesize normalizedNumber;
@synthesize isForGesture;

- (NSString *)displayNumber
{
    if (displayNumber) {
        return displayNumber;
    }else{
        self.displayNumber = [number formatPhoneNumberByDigitNumber:self.digitNumber];
        return displayNumber;
    }
}
- (NSString *)digitNumber
{
    if (digitNumber) {
        return digitNumber;
    }else{
        self.digitNumber = [number digitNumber];
        return digitNumber;
    }
}
- (NSString *)normalizedNumber
{
    if ([normalizedNumber length] == 0) {
        self.normalizedNumber = [[PhoneNumber sharedInstance] getNormalizedNumber:number];
    }
    return normalizedNumber;
}
- (BOOL)isForGesture
{
    NSRange range1 = [number rangeOfString:@";"];
    NSRange range2 = [number rangeOfString:@","];
    NSRange range3 = [number rangeOfString:@"；"];
    NSRange range4 = [number rangeOfString:@"，"];
    
    if ((range1.location != NSNotFound) || (range2.location != NSNotFound) ||
        (range3.location != NSNotFound) || (range4.location != NSNotFound)) {
        return NO;
    } else {
        return YES;
    }
}

@end
