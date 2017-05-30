//
//  DebugSupport.m
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestSupport.h"
#import "UserDefaultKeys.h"
#import "CallerDBA.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"
#import "SeattleExecutorHelper.h"
#import <AFNetworkOperation/AFHTTPRequestOperation.h>
#import <AFNetworkOperation/AFHTTPClient.h>
#import "DefaultUIAlertViewHandler.h"
#import "FunctionUtility.h"
#import "FileUtils.h"
#import "TPUncaughtExceptionHandler.h"
#import "CallLog.h"
#import "GroupModel.h"
#import "TouchpalMembersManager.h"
#import "TPDiagnose.h"
#import "PJCore.h"

@interface TestSupport () {
    BOOL _isUploading;
}

-(void) help:(id) param;
-(void) tips;
+(void) showMessage:(NSString*) message title:(NSString *)title;

@end

@implementation TestSupport

static NSString* testPrefix = nil;;
static NSString * testSuffix = nil;
static NSInteger prefixLength = 0;
static NSDictionary* __strong testCommands;
static TestSupport* instance;

+ (void) initialize {
    instance = [[TestSupport alloc] init];
    testPrefix = @"*#";
    testSuffix = @"#";
    prefixLength = [testPrefix length];
    testCommands = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"help:",                   @"4357",
                    @"tips",                    @"8477",
                    @"clear",                   @"25327",
                    @"swipe",                   @"79473",
                    @"caller",                  @"225537",
                    @"unregister",              @"86478",
                    @"uploadLog",               @"875623564",
                    @"collectLog",              @"2655328564",
                    @"voipCallLog",             @"86472255564",
                    @"noahTestService",         @"66248378",
                    @"showToken",               @"83536",
                    @"showCallLog",             @"74692255564",
                    @"noAdReason",              @"237469",
                    @"showMyGroupCount",        @"4768726868",
                    @"showTabBarDotReason",     @"368732766",
                    nil];
}

+(BOOL) isTestCommand:(NSString*) input {
    return [input hasPrefix:testPrefix]
            && [input hasSuffix:testSuffix];
}

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+(void) executeTestCommand:(NSString*) input {
    if([input length]< prefixLength) {
        return;
    }
    NSMutableCharacterSet *symbolSet = [[NSMutableCharacterSet alloc] init];
    [symbolSet addCharactersInString:@"#*"];
    NSString* commandKey = [input stringByTrimmingCharactersInSet:[symbolSet copy]];
    
    TPDiagnoseManager *diagnoseManager = [[TPDiagnoseManager alloc] init];
    BOOL isDiagnoseCode = [diagnoseManager isDiagnoseCode:commandKey];
    if (isDiagnoseCode) {
        [diagnoseManager showDiagnoseInfoByCode:commandKey];
    } else {
        NSString* command = nil;
        NSString* parameter = @"";
        NSRange range = [commandKey rangeOfString:@"#"];
        if(range.length>0) {
            if([commandKey length] > range.location + 1) {
                parameter = [commandKey substringFromIndex:range.location+1];
            }
            commandKey = [commandKey substringToIndex:range.location];
        }
        
        command = [testCommands objectForKey:commandKey];
        
        if(command == nil) {
            [instance help:commandKey];
        } else {
            SEL sel = NSSelectorFromString(command);
            if([instance respondsToSelector:sel]) {
                [instance performSelector:sel withObject:parameter];
            } else {
                [instance help:parameter];
            }
        }
    }
}

-(void) help:(id) param {
#ifdef DEBUG
    [TestSupport showMessage:[NSString stringWithFormat:@"syntax: ***[command]#[param].\n  The command %@ is invalid. \n Valid commands are: %@",
                              param, testCommands] title:@"testSupport"];
#endif
}

-(void) reset {
    [TestSupport showMessage:[NSString stringWithFormat:@"Reset"] title:@"testSupport"];
}

-(void) tips {
    [UserDefaultsManager removeObjectForKey:FIRST_LAUNCH_VERSION];
    [UserDefaultsManager removeObjectForKey:IS_LAUNCH_SKIN_SETTING_APP];
    [UserDefaultsManager removeObjectForKey:IS_LANCH_GESTURE_APP];
    [UserDefaultsManager removeObjectForKey:IS_CHECKING_SYSYTEM_CALLLOG_GETTING_APP];
    [UserDefaultsManager removeObjectForKey:IS_LAUNCH_SYSYTEM_CALLLOG_GETTING_APP];
    [UserDefaultsManager removeObjectForKey:IS_LAUNCH_SETTIN_FOR_VERSION];
    [UserDefaultsManager removeObjectForKey:IS_FIRST_LUNCH_SWIPE_IN_CELL];
    [UserDefaultsManager removeObjectForKey:IS_SMART_DIAL_TIP_VIEW_ALERADY_SHOWN];
    [UserDefaultsManager removeObjectForKey:SMARTEYE_TIPVIEW_HAVE_ALREADY_SHOWN];
    [UserDefaultsManager removeObjectForKey:YELLOWPAGE_GUIDE_VIEW_HAVE_ALREADY_SHOWN];
    [UserDefaultsManager removeObjectForKey:IS_INTERFACE_INVESTIGATE_VIEW_ALREADY_SHOWN];
    [UserDefaultsManager setObject:[NSDate date] forKey:DUE_DATE_TO_POP_INTERFACE_INVESTIGATE];
    [UserDefaultsManager removeObjectForKey:IS_PUT_APP_TO_BOTTOM_REMINDER_ALREADY_SHOWN];
    [UserDefaultsManager synchronize];
    [TestSupport showMessage:@"You will see tips when you launch TPDialer next time." title:@"testSupport"];
}

-(void)showToken{
    NSString *message = [SeattleFeatureExecutor getToken];
    if(message.length==0){
        return;
    }
    NSString *voippush = [UserDefaultsManager stringForKey:APPLE_VOIP_PUSH_TOKEN];
    NSString *content = [NSString stringWithFormat:@"toke:%@\npush:%@",message,voippush];
    [DefaultUIAlertViewHandler showAlertViewWithTitle:content message:nil];
}

- (void)unregister {
    [[PJCore instance] unregister];
}

- (void)noAdReason{
    NSDictionary *hangupNoAdReasonDic = [UserDefaultsManager dictionaryForKey:HANGUP_NO_AD_REASON];
    if (hangupNoAdReasonDic!=nil) {
            [TestSupport showMessage:[NSString stringWithFormat:@"%@",hangupNoAdReasonDic] title:@"testSupport"];
    }
}
-(void) swipe
{
    [UserDefaultsManager removeObjectForKey:IS_FIRST_LUNCH_SWIPE_IN_CELL];
}

-(void) clear {
    [CallerDBA deleteAllCache];
}
-(void)noahTestService{
    BOOL ifOpenNoahTestService = [UserDefaultsManager boolValueForKey:OPENNOAH_TESTSERVICE defaultValue:NO];
    [TestSupport showMessage:(!ifOpenNoahTestService?@"changeToTestNoahService":@"changeToStandarNoahService") title:@"NoahService"];
    [UserDefaultsManager setBoolValue:!ifOpenNoahTestService forKey:OPENNOAH_TESTSERVICE];
}

-(void) caller {
    NSArray *callers = @[@"96961",@"62580000", @"4008111111", @"+8613544744996", @"+8615129089234", @"+8613623348960", @"+8613106663097", @"+8613121360686", @"+8613675346917", @"+8613544744996", @"+8613544744996", @"+8615139601439", @"+8613912705090", @"+8615388733416", @"+8615521065698"];
    [SeattleExecutorHelper queryCallerIdInfo:callers];
    
    callers = @[@"+8615139601439"];
    [SeattleExecutorHelper queryCallerIdInfo:callers];
}

+(void) showMessage:(NSString*) message title:(NSString *)title{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok",@"")
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)collectLog {
    [UserDefaultsManager setBoolValue:YES forKey:COLLECT_AND_UPLOAD_LOG];
    [DefaultUIAlertViewHandler showAlertViewWithTitle:@"您重启一下触宝电话吧" message:nil];
}

- (void)uploadLog{
    if (_isUploading) {
        return;
    }
    _isUploading = YES;
    NSURL *url = [self domainURL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableData *uploadedData = [[NSMutableData alloc] initWithContentsOfFile:[TestSupport logFileAbsolutePath]];
    NSData *crashData = [self crashLogData];
    if (crashData) {
        [uploadedData appendData:crashData];
    }
    NSData *txtData = [uploadedData copy];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"PUT"
                                    path:[self uploadedUrlPath]
                                    parameters:nil
                                    constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                        [formData appendPartWithHeaders:nil body:txtData];
                                    }
        ];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *url = [self uploadedUrlString];
            [DefaultUIAlertViewHandler showAlertViewWithTitle:url message:nil okButtonActionBlock:^{
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
                [pasteboard setString:url];
                [UserDefaultsManager setBoolValue:NO forKey:COLLECT_AND_UPLOAD_LOG];
                [FunctionUtility removeDocumentFile:@"cootek_log.txt"];
                _isUploading = NO;
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            cootek_log(@"fail");
            _isUploading = NO;
        }];
    [operation start];
}

- (void)showCallLog{
    
        NSInteger rowsCount = [CallLog queryAllCalllogs].count;
        
        NSString *message = [NSString stringWithFormat:@"您已经产生了%d条通话记录",rowsCount];
        [DefaultUIAlertViewHandler showAlertViewWithTitle:message message:nil
                                      okButtonActionBlock:^(){
                                          
                                      }cancelActionBlock:^{
                                          
                                      }];
}

- (void)showTabBarDotReason{
    
    NSString *str = [NSString stringWithFormat:@"IS_VOIP_ON:%@\nVOIP_FIRST_VISIT_TOUCHPAL_PAGE_WITH_ALERT:%@\nTouchpalerCount:%d\nNewTouchpalerCount:%d",
                  [UserDefaultsManager boolValueForKey:IS_VOIP_ON] ? @"YES":@"NO",
                  ![UserDefaultsManager boolValueForKey:VOIP_FIRST_VISIT_TOUCHPAL_PAGE_WITH_ALERT defaultValue:NO] ? @"YES":@"NO",
                  [TouchpalMembersManager getTouchpalerArrayCount],
                  [TouchpalMembersManager getNewTouchpalerArraycount]
                  ];
    
    [DefaultUIAlertViewHandler showAlertViewWithTitle:@"LittleRedDot" message:str
                                  okButtonActionBlock:^(){
                                      
                                  }cancelActionBlock:^{
                                      
                                  }];
}

- (void)showMyGroupCount
{
    GroupModel *groupModel = [GroupModel pseudoSingletonInstance];
    NSArray *groups = groupModel.groups;
    NSString *message = [NSString stringWithFormat:@"您创建了%d个联系人分组",groups.count > 0 ? groups.count - 1 : 0 ];
    [DefaultUIAlertViewHandler showAlertViewWithTitle:message message:nil
                                  okButtonActionBlock:^(){
                                      
                                  }cancelActionBlock:^{
                                      
                                  }];
}
- (void)sendEmail{
    
        NSString *crashFilePath = [TPUncaughtExceptionHandler lastCrashFileAbsolutePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ( [fileManager fileExistsAtPath:crashFilePath]) {
            NSDictionary *crashDic = [NSDictionary dictionaryWithContentsOfFile:crashFilePath];
            NSString * ReportEmailAddress = @"tp.contacts.crash@cootek.cn";
            NSString * ReportEmailSubject = @"TouchPal Contacts crash report";
            NSString *urlStr = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@%@",ReportEmailAddress,ReportEmailSubject,NSLocalizedString(@"TouchPal has hit a critical error and is terminated. Please send us the crash report, to help us fix the problem. Thank you!",@"" ),crashDic];
            
            NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            [[UIApplication sharedApplication] openURL:url];
        }
}

- (void)voipCallLog {
    BOOL uploadVoipCalllog = [UserDefaultsManager boolValueForKey:VOIP_UPLOAD_CALLLOG defaultValue:NO];
    [UserDefaultsManager setBoolValue:!uploadVoipCalllog forKey:VOIP_UPLOAD_CALLLOG];
    NSString *string = [NSString stringWithFormat:@"免费电话通话状态上传状态:%@", !uploadVoipCalllog ? @"开": @"关" ];
    [DefaultUIAlertViewHandler showAlertViewWithTitle:string message:nil];
}

+ (NSString *) logFileAbsolutePath {
    return [FunctionUtility documentFile:@"cootek_log.txt"];
}

- (NSString *) uploadedUrlPath {
    NSString *path = @"test/feedback/ios/log";
    return [NSString stringWithFormat:@"%@/%@.txt", path, [FunctionUtility GetUUID]];
}

- (NSString *) uploadedUrlString {
    return [NSString stringWithFormat:@"http://%@/%@", [self domainName], [self uploadedUrlPath]];
}

- (NSString *) domainName {
    return @"cootek-dualsim.oss.aliyuncs.com";
}

- (NSURL *) domainURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [self domainName]]];
}

- (NSData *) crashLogData {
    NSData *crashData = nil;
    NSString *crashFilePath = [TPUncaughtExceptionHandler crashFileAbsolutePath];
    if ([FileUtils fileExistAtAbsolutePath:crashFilePath]) {
        crashData = [NSData dataWithContentsOfFile:crashFilePath];
    }
    return crashData;
}

@end
