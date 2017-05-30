//
//  TPAddressBookWrapper.m
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TPAddressBookWrapper.h"
#import "FunctionUtility.h"
#import "NSString+UUID.h"

@interface TPAddressBook ()  {
    ABAddressBookRef _abref;
}
@end

@implementation TPAddressBook
+ (TPAddressBook*) TPAddressBook
{
    TPAddressBook* result = [[TPAddressBook alloc] init];
    return result;
}

- (TPAddressBook*) init
{
    _abref = ABAddressBookCreateWithOptions(NULL, NULL);
    return self;
}

- (ABAddressBookRef) RetrieveABAddressBookRef
{
    return _abref;
}

- (BOOL) ReleaseABAddressBookRef
{
    if (_abref != NULL) {
        CFRelease(_abref);
        _abref = NULL;
    }
    return YES;
}
@end

@interface TPAddressBookWrapper()

+ (NSString*) RetrieveThreadIdForCurrentThread:(BOOL)createIfMissing;

@end

@implementation TPAddressBookWrapper

static NSMutableDictionary* addressbookes;
static NSString* threadId = @"THREAD_ID_FOR_ADDRESSBOOK";

+ (NSString*) RetrieveThreadIdForCurrentThread:(BOOL)createIfMissing
{
    NSThread* thread = [NSThread currentThread];
    NSString* value = (NSString*)[[thread threadDictionary] objectForKey:threadId];
    if([value length] == 0 && createIfMissing) {
        value = [NSString stringWithNewUUID];
        [[thread threadDictionary] setObject:value forKey:threadId];
    }
    
    return value;
}

+ (void) initialize
{
    // need if (...) to make sure the static initialize only been executed once
    // http://www.friday.com/bbum/2009/09/06/iniailize-can-be-executed-multiple-times-load-not-so-much/
    if (self == [TPAddressBookWrapper class]) {
        addressbookes = [[NSMutableDictionary alloc] init];
    }
}

+ (ABAddressBookRef) CreateAddressBookRefForCurrentThread
{
    @synchronized([TPAddressBookWrapper class]) {
        NSString* key = [TPAddressBookWrapper RetrieveThreadIdForCurrentThread:YES];
        cootek_log(@"thread name: %@", key);
        
        id value = [addressbookes objectForKey:key];
        if(value != nil) {
            cootek_log(@"Error: the addressbook is not nil for thread %@", key);
        } else {
            value = [TPAddressBook TPAddressBook];
            [addressbookes setObject:value forKey:key];
            cootek_log(@"New addressbook ref created. Total count %i", [[addressbookes allKeys] count]);
        }
        
        return  [(TPAddressBook*)value RetrieveABAddressBookRef];
    }
}

+ (ABAddressBookRef) RetrieveAddressBookRefForCurrentThread
{
    @synchronized([TPAddressBookWrapper class]) {
        
        // TODO Elfe-06-28: theoritically, createIfMissing should be NO here,
        // and should return nil if the addressbook ref is not created yet.
        // However, as the code before this refactoring is messy, 
        // and I'm not sure if there is any corner cases that this function will be called before the create is called,
        // I use the workaround here to create the object if missing.
        // It might cause memory leak that the addressbook ref created here will not get released
        // We can improve this later, by profiler, and also by check the Error log below.
        
        NSString* key = [TPAddressBookWrapper RetrieveThreadIdForCurrentThread:YES];
        //NSString* key = [TPAddressBookWrapper RetrieveThreadIdForCurrentThread:NO];
        
        id value = [addressbookes objectForKey:key];
        if(value == nil) {
            cootek_log(@"Error: the addressbook is nil for thread %@", key);
            value = [TPAddressBook TPAddressBook];
            [addressbookes setObject:value forKey:key];
        } 
        
        return [value RetrieveABAddressBookRef];
    }
}

+ (void) ReleaseAddressBookForCurrentThread
{
    @synchronized([TPAddressBookWrapper class]) {
        
        //TODO Elfe-06-28: the current code mainly use main thread to do small addressbook data retrieve.
        // There must be some bugs, if this Release funciton is called from main thread.
        // Use the following check, to avoid crash application.
        // We need more careful check on current code. 
        // We also need to pay attention on the following error message.
        // Once we are sure the other code don't have such bug, we should remove the following line.
        // In the future, we should consider change to use work thread to access address book data.
        if([NSThread isMainThread]) {
            cootek_log(@"Error: the addressbook ref for main thread should not be released now.");
            return;
        }
        
        NSString* key = [TPAddressBookWrapper RetrieveThreadIdForCurrentThread:NO];
        
        if([key length] == 0) {
            cootek_log(@"Error: the addressbookref is already created for thread");
            return;
        }
        
        id ab = [addressbookes objectForKey:key];
        if(ab != nil) {
            BOOL needRemove = [(TPAddressBook*) ab  ReleaseABAddressBookRef];          
            if(needRemove) {
                [addressbookes removeObjectForKey:key];
            }
        } else {
            cootek_log(@"Error: the addressbookref is already created for thread %@.", key);
        }
    }
}
@end
