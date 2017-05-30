//
//  InputNumberPasteUtility.m
//  TouchPalDialer
//
//  Created by Chen Lu on 2/6/13.
//
//

#import "InputNumberPasteUtility.h"
#import "PhonePadModel.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
#define T9_UN_EFFECTIVE_CHARACTERS @"[^0-9*#+,;]"
#define QWERTY_UN_EFFECTIVE_CHARACTERS @"[^0-9A-Za-z*#+,;]"

@implementation InputNumberPasteUtility

+ (NSString *)appendPasteboardString
{
    PhonePadModel *phonePadModel = [PhonePadModel getSharedPhonePadModel];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
    if (pasteboard.string && pasteboard.string.length != 0) {
        NSString *filterString;
        if (phonePadModel.currentKeyBoard == QWERTYBoardType) {
            filterString = QWERTY_UN_EFFECTIVE_CHARACTERS;
        } else {
            filterString = T9_UN_EFFECTIVE_CHARACTERS;
        }
        NSString *filtered = [self inputNumberString:pasteboard.string filteredBy:filterString];
        int length = filtered.length + phonePadModel.input_number.length;
        cootek_log(@"new number length: %d", length);
        if (filtered.length <= 0) {
            [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Ooops, no number in the clipboard.", @"")
                                                      message:nil];
        } else if (length <= SEARCH_INPUT_MAX_LENGTH){
            NSString *input = [NSString stringWithFormat:@"%@%@",phonePadModel.input_number,filtered];
            [phonePadModel setInputNumber:input];
        } else {
            // exceed number limit
            [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Ooops, the input is too long.", @"")
                                                      message:nil];
        }
    }
    return phonePadModel.input_number;
}
+ (NSString *)getPasteboardString
{
    PhonePadModel *phonePadModel = [PhonePadModel getSharedPhonePadModel];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
    if (pasteboard.string && pasteboard.string.length != 0) {
        NSString *filterString;
        if (phonePadModel.currentKeyBoard == QWERTYBoardType) {
            filterString = QWERTY_UN_EFFECTIVE_CHARACTERS;
        } else {
            filterString = T9_UN_EFFECTIVE_CHARACTERS;
        }
        NSString *filtered = [self inputNumberString:pasteboard.string filteredBy:filterString];
        int length = filtered.length + phonePadModel.input_number.length;
        cootek_log(@"new number length: %d", length);
        if (filtered.length <= 0) {
            [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Ooops, no number in the clipboard.", @"")
                                                      message:nil];
        } else if (length <= SEARCH_INPUT_MAX_LENGTH){
            NSString *input = [NSString stringWithFormat:@"%@",filtered];
            [phonePadModel setInputNumber:input];
        } else {
            // exceed number limit
            [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Ooops, the input is too long.", @"")
                                                      message:nil];
        }
    }
    return phonePadModel.input_number;
}

+ (NSString *)inputNumberString:(NSString *)sample filteredBy:(NSString *)filter
{
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:filter
                                                                           options:0
                                                                             error:nil];
    NSString *result = [regex stringByReplacingMatchesInString:sample
                                                       options:0
                                                         range:NSMakeRange(0, sample.length)
                                                  withTemplate:@""];
    return result;
}

@end
