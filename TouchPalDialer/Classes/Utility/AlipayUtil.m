//
//  AlipayUtil.m
//  TouchPalDialer
//
//  Created by Chen Lu on 8/7/12.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#import "AlipayUtil.h"
#import "AlipayPopupView.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"

//#define TEST_ALIPAY

@interface AlipayUtil ()

+(NSString *) strip:(NSString*)phoneNumber;

@end

@implementation AlipayUtil


+(BOOL) isAlipayNeedInstall
{
    return ![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipays://"]];
}

+(NSString *)extractAlipayPhoneNumber:(NSString *)rawNumber
{
    if (rawNumber == nil || [rawNumber isEqualToString:@""] ) {
        return nil;
    }
    
    NSString *strippedNumber = [self strip:rawNumber];
    
    if ([strippedNumber hasPrefix:@"+"]) {
        if ([strippedNumber hasPrefix:@"+86"]) {
            strippedNumber = [strippedNumber substringFromIndex:3];
        } else {
            return nil;
        }
    } else if([strippedNumber hasPrefix:@"0"]) {
        if ([strippedNumber hasPrefix:@"0086"]) {
            strippedNumber = [strippedNumber substringFromIndex:4];
        } else {
            return nil;
        }
    }
    
    if ([strippedNumber length] != 11) {
        return nil;
    }
    
    if ([strippedNumber isEqualToString:@"13800138000"]) {
        return nil;
    }
    
    if ([strippedNumber hasPrefix:@"13"] ||
        [strippedNumber hasPrefix:@"14"] ||
        [strippedNumber hasPrefix:@"15"] ||
        [strippedNumber hasPrefix:@"18"]) {
        return strippedNumber;
    }
    
    return nil;
}

+(NSString *)extractAlipayPhoneNumber:(NSString *)rawNumber matchesOneOf:(NSArray *)storedNumbers
{
    if (rawNumber == nil || [rawNumber isEqualToString:@""]) {
        return nil;
    }
    
    NSString *strippedNumber = [self strip:rawNumber];
    if ([strippedNumber length] < 11 ) {
        return nil;
    }
    
    NSString *suffixWith11Char = [strippedNumber substringFromIndex:[strippedNumber length] - 11];
        
    for (NSString * num in storedNumbers) {
        NSString* alipayNumber = [self extractAlipayPhoneNumber:num];
        if (alipayNumber == nil) {
            continue;
        }
        if ([alipayNumber isEqualToString:suffixWith11Char]) {
            return suffixWith11Char;
        }
    }
    return nil;
}

+(NSString *) strip:(NSString*)phoneNumber
{
    NSMutableString *res = [NSMutableString stringWithCapacity:[phoneNumber length]];
    for (int i = 0; i < [phoneNumber length]; i++) {
        unichar c = [phoneNumber characterAtIndex:i];
        if ( (c == '+' && i == 0) || (c >= '0' && c <='9')) {
            [res appendFormat:@"%c", c];
        } else if (c >= 65296 && c <= 65305){ // full-width [０,９]
            [res appendFormat:@"%c", c - 65296 + '0'];
        }
    }
    return res;
}

+(NSURL *) urlWithAlipayPhoneNumber:(NSString*) number name:(NSString*) name
{
    NSString *urlString = [NSString stringWithFormat:
        @"alipays://platformapi/startapp?appId=09999988&viewId=form&sourceId=touchpal&version=[3.9.0.0830-]&mobileNo=%@", number];

    name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *utf8EncodedName = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    
    if (utf8EncodedName == nil || [utf8EncodedName isEqualToString:@""]) {
        return [NSURL URLWithString:urlString];
    }
    else {
        utf8EncodedName = [utf8EncodedName stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        utf8EncodedName = [utf8EncodedName stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        utf8EncodedName = [utf8EncodedName stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        urlString = [urlString stringByAppendingFormat:@"&userName=%@", utf8EncodedName];
        return [NSURL URLWithString:urlString];
    }
}

+(BOOL)checkAndInstallAlipayWithName:(NSString *)name
{
#ifndef TEST_ALIPAY
    BOOL needInstall = [self isAlipayNeedInstall];
    if (needInstall) {
        NSString* title = [NSString stringWithFormat:NSLocalizedString(@"Pay %@", @""), name];
        NSString* msg = NSLocalizedString(@"Please download or update Alipay app to pay.", @"");
        void(^actionBlock)(BOOL checked) = ^(BOOL checked) {
            // alipay app store link
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/id333206289"]];
        };
        void(^cancelBlock)(BOOL checked) = ^(BOOL checked) {

        };
        
        AlipayPopupView *popUp = [[AlipayPopupView alloc] initWithTitle:title
                                                                 message:msg 
                                                        cancelButtonText:NSLocalizedString(@"Cancel", @"")
                                                        actionButtonText:NSLocalizedString(@"Download", @"")
                                                            checkBoxText:nil
                                                             actionBlock:actionBlock
                                                             cancelBlock:cancelBlock
                                   ];
        UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [uiWindow addSubview:popUp];
        [uiWindow bringSubviewToFront:popUp];
    }
    return needInstall;
#else
    return NO;
#endif
}

+ (void)jumpToAlipayWithAlipayPhoneNumber:(NSString *)number name:(NSString *)name
{
    if (![UserDefaultsManager boolValueForKey:NO_PAY_CONFIRM_PROMPT]) {
        NSString* title = [NSString stringWithFormat:NSLocalizedString(@"Pay %@", @""), name];
        NSString* msg = NSLocalizedString(@"You will be guided to Alipay to complete the payment, continue?", @"");
        void(^actionBlock)(BOOL checked) = ^(BOOL checked) {
            [UserDefaultsManager setBoolValue:checked forKey:NO_PAY_CONFIRM_PROMPT];
            [[UIApplication sharedApplication] openURL:[self urlWithAlipayPhoneNumber:number name:name]];
            
#ifdef TEST_ALIPAY
            [DefaultUIAlertViewHandler showAlertViewWithTitle:name 
                                                      message:[[self urlWithAlipayPhoneNumber:number name:name] description]
                                          okButtonActionBlock:nil];
#endif
        };
        AlipayPopupView *popUp = [[AlipayPopupView alloc] initWithTitle:title
                                                                 message:msg 
                                                        cancelButtonText:NSLocalizedString(@"Cancel", @"")
                                                        actionButtonText:NSLocalizedString(@"Ok", @"")
                                                            checkBoxText:NSLocalizedString(@"Don't prompt me again", @"")
                                                             actionBlock:actionBlock
                                                             cancelBlock:nil
                                   ];
        UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [uiWindow addSubview:popUp];
        [uiWindow bringSubviewToFront:popUp];
    }
    else {
        [[UIApplication sharedApplication] openURL:[self urlWithAlipayPhoneNumber:number name:name]];

#ifdef TEST_ALIPAY
        [DefaultUIAlertViewHandler showAlertViewWithTitle:name 
                                                  message:[[self urlWithAlipayPhoneNumber:number name:name] description]
                                      okButtonActionBlock:nil];
#endif
    }
}

@end
