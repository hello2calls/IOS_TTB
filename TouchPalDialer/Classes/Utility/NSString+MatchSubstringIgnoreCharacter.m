//
//  NSString+MatchSubstringIgnoreCharacter.m
//  TouchPalDialer
//
//  Created by Sendor on 12-2-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+MatchSubstringIgnoreCharacter.h"

@implementation NSString (MatchSubstringIgnoreCharacter)

- (NSRange)rangeOfString:(NSString*)searched ignoreUTF8Character:(char)ignorance {
    return [self rangeOfString:searched ignoreCharacter:(unichar)ignorance];
}
-(NSString *)formatQueryContent:(NSString *)charS{
    if ([self length] == 1) {
        if ([self isEqualToString:@"+"]||[self isEqualToString:@"*"] ||[self isEqualToString:@"#"]) {
            return [@"\\" stringByAppendingString:self];
        }
    }
    NSString *target = [NSString stringWithFormat:@"%@?",charS];
    int length = [self length];
    NSRange position;
    position.length = 1;
    for (int i = 0; i<length; i++) {
        position.location  = i;
        NSString *currentStr = [self substringWithRange:position];
        if ([currentStr isEqualToString:charS]) {
            continue;
        }
        if ([currentStr isEqualToString:@"+"]||[currentStr isEqualToString:@"*"] ||[currentStr isEqualToString:@"#"]) {
            currentStr = [@"\\" stringByAppendingString:currentStr];
        }
        NSString *tmpString = [NSString stringWithFormat:@"%@%@?",currentStr,charS];
        if (tmpString) {
            target =[target stringByAppendingString:tmpString];
        }   
    }
    return target;
}
- (NSRange)rangeOfString:(NSString*)searched ignoreCharacter:(unichar)ignorance {
    // get ignorance position list in searchIn
    long *ignorancePositionList = calloc([self length], sizeof(long));
    for (int i=0; i<[self length]; i++) {
        ignorancePositionList[i] = [self length] + 1;
    }
    NSRange rangeFullSearchIn = NSMakeRange(0, [self length]);
    unichar *searchInChars = calloc(rangeFullSearchIn.length, sizeof(unichar));
    memset(searchInChars, 0, rangeFullSearchIn.length*sizeof(unichar));
    [self getCharacters:searchInChars range:rangeFullSearchIn];
    int positionIndex = 0;
    for (int i=0; i<rangeFullSearchIn.length; i++) {
        unichar item = searchInChars[i];
        if (ignorance == item) {
            ignorancePositionList[positionIndex] = i;
            positionIndex++;
        }
    }
    free(searchInChars);
    unichar ignorances[] = { ignorance };
    // clean ignorance in searched
    NSString* searchedNotIgnorance = [searched stringByReplacingOccurrencesOfString:[NSString stringWithCharacters:ignorances length:1] withString:@""];
    // clean ignorance in searchIn
    NSString* searchInNotIgnorance = [self stringByReplacingOccurrencesOfString:[NSString stringWithCharacters:ignorances length:1] withString:@""];
    // call range... method of NSString
    NSRange findRange = [searchInNotIgnorance rangeOfString:searchedNotIgnorance];
    // merge position list
    if (NSNotFound != findRange.location) {
        for (int i=0; i<self.length; i++) {
            int position = ignorancePositionList[i]; 
            if (position <= findRange.location) {
                findRange.location++;
            } else if (position <= (findRange.location + findRange.length)) {
                findRange.length++;
            } else {
                break;
            }
        }
    }
    free(ignorancePositionList);
    return findRange;
}

@end
