//
//  DialResultModel.m
//  AddressBook_DB
//
//  Created by Alice on 11-8-1.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "DialResultModel.h"
#import "TouchPalDialerAppDelegate.h"

@implementation DialResultModel

@synthesize type;
@synthesize callerID = callerID_;

- (CallerIDInfoModel *)callerID{
      return callerID_;
}
@end
