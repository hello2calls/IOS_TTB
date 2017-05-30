//
//  NSMutableString+TPHandleEmpty.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/12/12.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableString (TPHandleEmpty)

-(void) appendIfNonEmptyString:(NSString *)aString;
-(void) appendWithReturnIfNonEmptyString:(NSString *)aString;

@end
