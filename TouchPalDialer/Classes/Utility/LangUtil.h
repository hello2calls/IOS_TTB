//
//  LangUtil.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/28/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASIC_MAX 1871
#define JAPANESE_MIN 12353
#define JAPANESE_MAX 12435
#define CHINESE_MIN 19968
#define CHINESE_MAX 40868
#define FULL_WIDTH_DIGIT_MIN 65296
#define FULL_WIDTH_DIGIT_MAX 65305
#define FULL_WIDTH_UPPER_LETTER_MIN 65313
#define FULL_WIDTH_UPPER_LETTER_MAX 65338
#define FULL_WIDTH_LOWER_LETTER_MIN 65345
#define FULL_WIDTH_LOWER_LETTER_MAX 65370

#define SPACE ' '
#define DIGITAL '#'
#define UPPER_A 'A'
#define tabledivider1 25000
#define tabledivider2 33000

wchar_t getFirstLetter(wchar_t c);
wchar_t getFirstLetterFromLanguage(wchar_t c);
NSString *wcharToNSString(wchar_t c);
wchar_t NSStringToFirstWchar(NSString *mstr);
BOOL isDigital(char c);
BOOL isNotDigitOrLetter(wchar_t c);
BOOL binarySearchInNotDigitLetter(wchar_t c);

int compareName(NSString* object1, NSString *object2);
int compareNameCStr(const wchar_t* object1, int offset1, const wchar_t* object2, int offset2);
