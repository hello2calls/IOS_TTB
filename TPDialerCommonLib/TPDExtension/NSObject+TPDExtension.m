//
//  NSObject+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/14.
//
//

#import "NSObject+TPDExtension.h"

@implementation NSObject (TPDExtension)
- (NSString *)tpd_JSONRepresentation
{
    if (![NSJSONSerialization isValidJSONObject:self]) {
        NSLog(@"[%@ is not a valid json object]", self);
        return nil;
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:nil error:&error];
    if (error) {
        return nil;
    }else
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
