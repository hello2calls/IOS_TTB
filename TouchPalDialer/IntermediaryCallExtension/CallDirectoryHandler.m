//
//  CallDirectoryHandler.m
//  IntermediaryCallExtension
//
//  Created by ALEX on 16/9/14.
//
//

#import "CallDirectoryHandler.h"
#import "FMDatabase.h"
static NSString * const kGroupKey = @"group.com.cootek.intermediary";

@interface CallDirectoryHandler () <CXCallDirectoryExtensionContextDelegate>
@end

@implementation CallDirectoryHandler

- (void)beginRequestWithExtensionContext:(CXCallDirectoryExtensionContext *)context {
    context.delegate = self;
    
    if (![self addIdentificationPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add identification phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:2 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    [context completeRequestWithCompletionHandler:nil];
}

- (BOOL)addIdentificationPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    // Retrieve phone numbers to identify and their identification labels from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    //
    // Numbers must be provided in numerically ascending order.
    NSURL *pathUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupKey];
    NSString *fileName = [[pathUrl path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",kGroupKey]];
    FMDatabase *database = [FMDatabase databaseWithPath:fileName];
    if (![database open]) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", @"t_text"];
    FMResultSet *result = [database executeQuery:sql];
    if (result) {
        while ([result next]){
            @autoreleasepool {
                //NSMutableDictionary *info = [NSMutableDictionary dictionary];
                NSString *numberString = [result stringForColumn:@"number"];
                NSString *label = [result stringForColumn:@"tag"];
                CXCallDirectoryPhoneNumber phoneNumber = numberString.longLongValue;
                //NSString *label = info[@"tag"];
                [context addIdentificationEntryWithNextSequentialPhoneNumber:phoneNumber label:label];
            }
        }
    }
    [database close];
    return YES;
}

#pragma mark - CXCallDirectoryExtensionContextDelegate

- (void)requestFailedForExtensionContext:(CXCallDirectoryExtensionContext *)extensionContext withError:(NSError *)error {
    // An error occurred while adding blocking or identification entries, check the NSError for details.
    // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
    //
    // This may be used to store the error details in a location accessible by the extension's containing app, so that the
    // app may be notified about errors which occured while loading data even if the request to load data was initiated by
    // the user in Settings instead of via the app itself.
}

@end
