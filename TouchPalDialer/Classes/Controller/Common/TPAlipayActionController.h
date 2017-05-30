//
//  TPAlipayActionController.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/19/12.
//
//

#import <Foundation/Foundation.h>
#import "CooTekPopUpSheet.h"

@interface TPAlipayActionController : NSObject<CooTekPopUpSheetDelegate>

+(TPAlipayActionController *) controller;

+(BOOL) canDoAlipayActionByPersonId:(NSInteger)personId;

-(void) doAlipayActionByPersonId:(NSInteger)personId;

@end
