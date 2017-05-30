//
//  LCDUpdator.m
//  TPDialerAdvanced
//
//  Created by Xu Elfe on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <CoreTelephony/CoreTelephonyDefines.h>
#import <CoreTelephony/CTCall.h>

#import "XXUnknownSuperclass.h"
#import "Springboard-Structs.h"
//#import "Springboard.h"
#import "SBCallAlertDisplay.h"
#import "SBUIFullscreenAlertAdapter.h"
#import "PhoneCall.h"
#import "MPIncomingPhoneCallController.h"
#import "InCallLCDView.h"

#import "NumberUtil.h"
#import "OrlandoEngine.h"
#import "LCDUpdator.h"
#import "Util.h"
#import "NumberInfoModel.h"

@interface LCDUpdator() 
-(void) printInfo;
-(void) retrieveDataInBackground;
-(void) updateInMain:(NSString*)location;
-(void) updateOldFull;
-(void) updateFull;
-(void) updateMobilePhone;
-(NSString*) validPhoneNumber;
@end

@implementation LCDUpdator

@synthesize hookee;   
@synthesize text;
@synthesize label;
@synthesize number;
//@synthesize displayName;
@synthesize breakPoint;
@synthesize updatorType;

-(void) printInfo {
    cootek_log_function;
    cootek_log(@"type: %d", updatorType);
    cootek_log(@"text: %@", text);
    cootek_log(@"label: %@", label);
    cootek_log(@"number: %@", number);
}

-(void) update {
    cootek_log_function;
    [self performSelectorInBackground:@selector(retrieveDataInBackground) withObject:nil];
}

-(void) retrieveDataInBackground {
    cootek_log_function;
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    [self printInfo];
    
    [NSThread sleepForTimeInterval:1];
    
    NSString* validNumber = [self validPhoneNumber];
    if(!validNumber) {
        return;
    }
    
    bool checkCallerId = true;
    if (![validNumber isEqualToString:[NumberUtil removeFormatChars:text]]) {
        checkCallerId = false;
    }
    
    NumberInfoModel* info = [[NumberInfoModel alloc] initWithNumber:validNumber];
    [info loadLocation];
    if([self prepareUpdate:info]) {
        [self performSelectorOnMainThread:@selector(updateInMain:) withObject:info waitUntilDone:YES];
    }
    
    //TODO: remove the sleep
    [NSThread sleepForTimeInterval:2];
    
    if (checkCallerId) {
        BOOL isCallerId = [info loadCallerId];
        if(isCallerId) {
            if([self prepareUpdate:info]) {
                [self performSelectorOnMainThread:@selector(updateInMain:) withObject:info waitUntilDone:YES];
            }
        }
    }
    
    [pool release];
}

-(NSString*) validPhoneNumber {
    cootek_log_function;
    NSString* temp = [number length] > 0 ? number : text;
    temp = [NumberUtil removeFormatChars:temp];
    if(![NumberUtil isPhoneNumber:temp]) {
        cootek_log(@"No valid phone number");
        return nil;
    } else {
        cootek_log(@"The valid phone number is %@", temp);
        return temp;
    }
}

-(BOOL) prepareUpdate:(NumberInfoModel*) info {
    cootek_log_function;
    
    BOOL needUpdate = NO;
    if(updatorType == UTFull || updatorType == UTOldFull) {
        NSString* newText = [info textForNumber:info.normalizedNumber originalText:text originalLabel:label hasLocation:NO];
        
        if(info.location != nil && [info.location length] > 0 && ![label containsSubString:info.location]) {
            label = info.location;
            needUpdate = YES;
        }
        
        if(newText != nil && [newText length] > 0 && ![text isEqualToString:newText]) {
            text = newText;
            needUpdate = YES;
        }
    }
    
    if(updatorType == UTMobilePhone) {
        NSString* newText = [info textForNumber:info.normalizedNumber originalText:text originalLabel:label hasLocation:YES];
        
        if(newText != nil && [newText length] > 0 && ![text isEqualToString:newText]) {
            text = newText;
            needUpdate = YES;
        }
    }
    
    return needUpdate;
}

-(void) updateInMain:(NumberInfoModel*) info {
    cootek_log_function;
    switch (updatorType) {
        case UTUnknown:
            //Do nothing
            break;
        case UTOldFull:
            [self updateOldFull];
            break;
        case UTFull:
            [self updateFull];
            break;
        case UTMobilePhone:
            [self updateMobilePhone];
            break;
        default:
            break;
    }
}

-(void) updateOldFull{
    cootek_log_function;
    if([hookee respondsToSelector:@selector(updateLCDWithName:label:breakPoint:)])
    {
        SBCallAlertDisplay* d = (SBCallAlertDisplay*) hookee;
        
        cootek_log(@"updateOlfFull text=%@ label=%@", text, label);
        [d updateLCDWithName:text label:label breakPoint:breakPoint];
    } else {
        cootek_log(@"the hooked function is not supported");
    }
}

-(void) updateFull {
    cootek_log_function;
    if([hookee respondsToSelector:@selector(updateLCDWithName:label:breakPoint:)] &&
       [hookee respondsToSelector:@selector(callerNameBreakPoint)]) {
        MPIncomingPhoneCallController* c = (MPIncomingPhoneCallController*) hookee;
        
        cootek_log(@"updateFull text=%@ label=%@", text, label);
        [c updateLCDWithName:text label:label breakPoint:[c callerNameBreakPoint]];
    } else {
        cootek_log(@"the hooked function is not supported");
    }
}

-(void) updateMobilePhone {
    cootek_log_function;
    if([hookee respondsToSelector:@selector(setText:)] && [hookee respondsToSelector:@selector(label)]) {
        cootek_log(@"updateMobilePhone text=%@ label=%@", text, label);
        InCallLCDView* v = (InCallLCDView*) hookee;
        
        if(text != nil) {
            [v setText:text];
        }
    } else {
        cootek_log(@"the hooked function is not supported");
    }
}

@end
