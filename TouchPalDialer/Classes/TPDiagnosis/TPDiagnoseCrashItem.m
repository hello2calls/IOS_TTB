//
//  TPDiagnoseCrashItem.m
//  TouchPalDialer
//
//  Created by siyi on 16/7/20.
//
//

#import "TPDiagnoseCrashItem.h"

#import "FileUtils.h"
#import "TPUncaughtExceptionHandler.h"

@implementation TPDiagnoseCrashItem

+ (NSString *) diagnoseCode {
    return @"27274";
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.alertTitle = @"Crash";
    }
    return self;
}

- (NSString *) alertMessage {
    return NSLocalizedString(@"user_hint_when_sending_crash", @"程序异常退出，请将错误信息发送给我们。谢谢。");
}

- (NSString *) getBody {
    NSString *crashFilePath = [TPUncaughtExceptionHandler lastCrashFileAbsolutePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *crashString = nil;
    if ( [fileManager fileExistsAtPath:crashFilePath]) {
        NSDictionary *crashDict = [NSDictionary dictionaryWithContentsOfFile:crashFilePath];
        if (crashDict != nil) {
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:crashDict options:NSJSONWritingPrettyPrinted error:&error];
            if (data != nil) {
                crashString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            cootek_log(@"%s\n, error= %@", __func__, error);
        }
    }
    return crashString;
}

@end
