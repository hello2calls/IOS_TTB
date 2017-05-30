//
//  TPDCallViewController.h
//  TouchPalDialer
//
//  Created by weyl on 16/11/30.
//
//

#import <UIKit/UIKit.h>
#import "CallViewController.h"

@interface TPDCallViewController : UIViewController
@property (nonatomic) CallMode callMode;
@property (nonatomic, strong) NSArray* numbers;
@end
