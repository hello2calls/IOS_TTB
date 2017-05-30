//
//  TPDiagnoseBaseItem.h
//  TouchPalDialer
//
//  Created by siyi on 16/7/20.
//
//

#ifndef TPDiagnoseBaseItem_h
#define TPDiagnoseBaseItem_h

#define TP_DIAGNOSE_EMAIL_ADDRESS @"tp.contacts.crash@cootek.cn"
#define TP_DIAGNOSE_EMAIL_SUBJECT @"Crash Report"

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface TPDiagnoseBaseItem : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSString *currentVersion;
@property (nonatomic, strong) NSString *firstInstalledVersion;
@property (nonatomic, strong) NSString *previousVersion;
@property (nonatomic, strong) NSString *manufacturer;
@property (nonatomic, strong) NSString *phoneType;
@property (nonatomic, strong) NSString *systemInfo;
@property (nonatomic, assign) BOOL isDualSim;

@property (nonatomic, assign) BOOL visibleToUser;

@property (nonatomic, strong) NSString *alertMessage;
@property (nonatomic, strong) NSString *alertTitle;

- (NSString *) getBody;
- (NSString *) getHeader;

@property (nonatomic, strong, getter=getConfirmBlock) void (^confirmBlock)();
@property (nonatomic, strong, getter=getCancelBlock) void (^cancelBlock)();

+ (NSString *) diagnoseCode;

@end


#endif /* TPDiagnoseBaseItem_h */
