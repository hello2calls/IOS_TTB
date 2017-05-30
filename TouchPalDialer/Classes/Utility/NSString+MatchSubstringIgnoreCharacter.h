//
//  NSString+MatchSubstringIgnoreCharacter.h
//  TouchPalDialer
//
//  Created by Sendor on 12-2-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MatchSubstringIgnoreCharacter)
- (NSRange)rangeOfString:(NSString*)searched ignoreUTF8Character:(char)ignorance;
- (NSRange)rangeOfString:(NSString*)searched ignoreCharacter:(unichar)ignorance;
- (NSString *)formatQueryContent:(NSString *)charS;
@end
