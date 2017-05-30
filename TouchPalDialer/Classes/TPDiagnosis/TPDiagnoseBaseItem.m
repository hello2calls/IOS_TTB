//
//  TPDiagnoseItem.m
//  TouchPalDialer
//
//  Created by siyi on 16/7/20.
//
//

#import "TPDiagnoseBaseItem.h"
#import "TouchPalVersionInfo.h"
#import "NSString+TPHandleNil.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import <objc/runtime.h>
#import "DefaultUIAlertViewHandler.h"
#import "FunctionUtility.h"
#import "TPDiagnose.h"
#import "TPShareController.h"

@implementation TPDiagnoseBaseItem

- (void) baseInit {
    _confirmBlock = nil;
    _cancelBlock = nil;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self baseInit];
        UIDevice *device = [[UIDevice alloc] init];
        _currentVersion = CURRENT_TOUCHPAL_VERSION;
        _firstInstalledVersion = [NSString nilToEmpty:[UserDefaultsManager stringForKey:FIRST_LAUNCH_VERSION]];
        _previousVersion = [NSString nilToEmpty:[UserDefaultsManager stringForKey:VERSION_JUST_BEFORE_UPGRADE]];
        _manufacturer = @"Apple";
        _phoneType = [FunctionUtility deviceName];
        _systemInfo = [NSString stringWithFormat:@"iOS %@", device.systemVersion];
        _isDualSim = NO;
        _visibleToUser = NO;
    }
    return self;
}

+ (NSString *) diagnoseCode {
    return nil;
}

- (NSString *) getHeader {
    NSDictionary *info = @{
                           NSLocalizedString(@"current_version", @"当前版本"): _currentVersion,
                           NSLocalizedString(@"version_just_before_upgrade", @"升级前的版本"): _previousVersion,
                           NSLocalizedString(@"first_launch_version", @"第一次安装的版本"): _firstInstalledVersion,
                           NSLocalizedString(@"manufacturer", @"厂商"): _manufacturer,
                           NSLocalizedString(@"phone_type", @"机型"): _phoneType,
                           NSLocalizedString(@"system_info", @"系统信息"): _systemInfo,
                           };
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    if (error != nil) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *) alertMessage {
    return [NSString stringWithFormat:@"%@", [self getBody]];
}

- (void (^)()) getConfirmBlock {
    return ^{
        NSString *dialogTitle = NSLocalizedString(@"TouchPal notification", @"触宝提示");
        NSString *cancelTitle = NSLocalizedString(@"send_by_wechat", @"微信发送");
        NSString *okTitle = NSLocalizedString(@"send_by_email", @"邮件发送");
        [DefaultUIAlertViewHandler showAlertViewWithTitle:dialogTitle
                                                  message:nil
                                              cancelTitle:cancelTitle
                                                  okTitle:okTitle
                                      okButtonActionBlock:^{
                                          // 邮件发送
                                          [FunctionUtility sendEmailToAddress:TP_DIAGNOSE_EMAIL_ADDRESS andSubject:self.alertTitle withHeader:[self getHeader] withBody:[self getBody]];
                                      }
                                        cancelActionBlock:^{
                                            // 微信发送，只有文字
                                            NSString *description = [NSString stringWithFormat:@"%@\n%@", [self getHeader], [self getBody]];
                                            [FunctionUtility shareTextByWeixin:description andThumbImage:nil andSuccesBlock:nil];
                                        }
         ]; // show alert
    };
}

- (void (^)()) getCancelBlock {
    return ^{};
    
}

@end
