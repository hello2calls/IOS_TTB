//
//  NSMutableString+TPHandleEmpty.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/12/12.
//
//

#import "NSMutableString+TPHandleEmpty.h"

@implementation NSMutableString (TPHandleEmpty)

-(void) appendIfNonEmptyString:(NSString *)aString
{
    if (aString && [aString length] != 0) {
        [self appendString:aString];
    }
}

-(void) appendWithReturnIfNonEmptyString:(NSString *)aString
{
    if (aString && [aString length] != 0) {
        [self appendFormat:@"%@\n",aString];
    }
}

@end
