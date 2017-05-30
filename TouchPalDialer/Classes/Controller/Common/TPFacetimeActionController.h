//
//  TPFacetimeActionController.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/8/12.
//
//

#import <Foundation/Foundation.h>

@interface TPFacetimeActionController : NSObject<UIActionSheetDelegate>

// convenience method
+(TPFacetimeActionController*) controller;

-(void)chooseFacetimeActionWithNumbersAndEmails:(NSArray*)numbersAndEmails
                                    presentedBy:(UIViewController*)aViewController;

-(void)chooseFacetimeActionByPersonId:(NSInteger)personId
                          presentedBy:(UIViewController *)aViewController;

@end
