//
//  TPDiagnoseEmailItem.m
//  TouchPalDialer
//
//  Created by siyi on 16/7/22.
//
//

#import "TPDiagnoseEmailItem.h"
#import "FileUtils.h"
#import "TPUncaughtExceptionHandler.h"
#import "FunctionUtility.h"

@implementation TPDiagnoseEmailItem

- (void (^)()) getConfirmBlock {
    return ^{
        NSString *lastCrashFilePath = [TPUncaughtExceptionHandler lastCrashFileAbsolutePath];
        if (![FileUtils fileExistAtAbsolutePath:lastCrashFilePath]) {
            return;
        }
        
        NSDictionary *crashDic = [NSDictionary dictionaryWithContentsOfFile:lastCrashFilePath];
        if (crashDic == nil) {
            return;
        }
        
        NSString *body = [self getBody];
        if (body == nil) {
            return;
        }
        body = [NSString stringWithFormat:@"%@\n%@", [self getHeader], body];
        NSString *userHint = NSLocalizedString(@"TouchPal has hit a critical error and is terminated. Please send us the crash report, to help us fix the problem. Thank you!",@"" );
        
        [FunctionUtility sendEmailToAddress:TP_DIAGNOSE_EMAIL_ADDRESS andSubject:TP_DIAGNOSE_EMAIL_SUBJECT withHeader:userHint withBody:body];
    };
}


@end
