//
//  NSDictionary_Default.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Default)

- (id) objectForKey:(NSString*)key withDefaultValue: (id) defaultValue;

- (BOOL) objectForKey:(NSString*)key withDefaultBoolValue: (BOOL) defaultBoolValue;

- (NSString*) stringForKey:(NSString *)key;
@end
