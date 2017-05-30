//
//  TPDPhoneCallViewController.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import <UIKit/UIKit.h>

@interface TPDPhoneCallViewController : UIViewController
-(void)showKeyPad:(BOOL)b;
-(void)makeCallWithNumber:(NSString*)number;
@end
