//
//  CallbackWizardViewController.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/2/4.
//
//

#import <UIKit/UIKit.h>

@interface CallbackWizardViewController : UIViewController
+ (id)instanceWithNumberArr:(NSArray *)number;
+ (id)instanceWithNumber:(NSString *)number;
+ (id)instanceWithNumberArr:(NSArray *)number aduuid:(NSString *)uuid;
@end
