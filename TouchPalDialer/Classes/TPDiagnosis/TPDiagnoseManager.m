//
//  TPDiagnoseManager.m
//  TouchPalDialer
//
//  Created by siyi on 16/7/20.
//
//
#import "TPDiagnoseManager.h"
#import "TPDiagnose.h"
#import "NSString+TPHandleNil.h"
#import "DefaultUIAlertViewHandler.h"
#import "HangupCommercialManager.h"

@implementation TPDiagnoseManager

- (BOOL) isDiagnoseCode:(NSString *)codeString {
    NSArray *diagnoseItems = [self diagnoseItems];
    BOOL matched = NO;
    for(Class item in diagnoseItems) {
        NSString *dignoseCode = [item performSelector:@selector(diagnoseCode)];
        if ([dignoseCode isEqualToString:codeString]) {
            matched = YES;
            break;
        }
    }
    return matched;
}

- (void) showDiagnoseInfoByCode:(NSString *)codeString {
    NSString *diagnoseClassName = [self diagnoseClassNameByCode:codeString];
    if (diagnoseClassName == nil) {
        return;
    }
    TPDiagnoseBaseItem *diagnoseItem = [[NSClassFromString(diagnoseClassName) alloc] init];
    NSString *alertTitle = diagnoseItem.alertTitle;
    NSString *alertMessage = diagnoseItem.alertMessage;
    NSString *cancelTitle = NSLocalizedString(@"Cancel",@"取消");
    NSString *okTitle = NSLocalizedString(@"Send",@"发送");
    
    [DefaultUIAlertViewHandler showAlertViewWithTitle:alertTitle
                                              message:alertMessage
                                          cancelTitle:cancelTitle
                                              okTitle:okTitle
                                  okButtonActionBlock:[diagnoseItem getConfirmBlock]
                                    cancelActionBlock:[diagnoseItem getCancelBlock]
     ];
}

- (NSString *) diagnoseClassNameByCode:(NSString *)codeString {
    NSArray *diagnoseItems = [self diagnoseItems];
    Class matchedClass = nil;
    for(Class item in diagnoseItems) {
        NSString *dignoseCode = [item performSelector:@selector(diagnoseCode)];
        if ([dignoseCode isEqualToString:codeString]) {
            matchedClass = item;
            break;
        }
    }
    if (matchedClass == nil) {
        return nil;
    }
    return NSStringFromClass(matchedClass);
}


- (NSArray *) diagnoseItems {
    return @[
             [TPDiagnoseCrashItem class],
             [TPDiagnoseLastAdItem class],
             [TPDiagnoseLastCallItem class],
             ];
}

#pragma mark --- Helpers ---
+ (NSString *) getCallTypeDescription:(NSString *)callType {
    if ([callType isEqualToString:CALL_TYPE_BACK_CALL]) {
        return NSLocalizedString(@"call_type_back_call", @"回拨");
    } else if ([callType isEqualToString:CALL_TYPE_C2P]) {
        return NSLocalizedString(@"call_type_c2p", @"直播C2P");
    } else if ([callType isEqualToString:CALL_TYPE_C2C]) {
        return NSLocalizedString(@"call_type_c2c", @"直播C2C");
    } else if ([callType isEqualToString:CALL_TYPE_P2P]) {
        return NSLocalizedString(@"call_type_p2p", @"普通电话");
    } else {
        return @"";
    }
}

+ (NSString *) getVoipPriviledgeDescription:(BOOL)isVip {
    if (isVip) {
        return NSLocalizedString(@"is_vip", @"VIP");
    } else {
        return NSLocalizedString(@"not_vip", @"非VIP");
    }
}

+ (NSString *) getForcedOfflineDescription:(BOOL)isForcedOffline {
    if (isForcedOffline) {
        return NSLocalizedString(@"free_call_forced_offline", @"被掐断");
    } else {
        return NSLocalizedString(@"free_call_not_forced_offline", @"未被掐断");
    }
}

+ (NSString *) getAdPageTypeDescription:(NSString *)adPageType {
    return NSLocalizedString(adPageType, @"");
}

+ (NSString *) getDefaultAdReasonDescription:(AdDefaultReason)reason {
    NSString *reasonString = @"";
    switch (reason) {
        case kAdDefaultReasonRequestFailed: {
            reasonString = @"广告数据未返回";
            break;
        }
        case kAdDefaultReasonRequestDownloading: {
            reasonString = @"广告资源未拉取到";
            break;
        }
        case kAdDefaultReasonRequestResourceEmpty: {
            reasonString = @"广告数据已返回但数据为空";
            break;
        }
        default:
            break;
    }
    return reasonString;
}

@end
