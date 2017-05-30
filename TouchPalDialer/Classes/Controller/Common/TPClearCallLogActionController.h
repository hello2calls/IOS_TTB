//
//  TPClearCallLogActionController.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/8/12.
//
//

#import <Foundation/Foundation.h>

@interface TPClearCallLogActionController : NSObject<UIAlertViewDelegate>

// convenience method
+(TPClearCallLogActionController *) controller;

-(void) clearCallLogOfKnownContactByPersonId:(NSInteger)personId;
-(void) clearCallLogOfUnknownContactByPhoneNumber:(NSString*)phoneNumber;

@end
