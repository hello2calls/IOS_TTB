//
//  TPDMySkinViewController.h
//  TouchPalDialer
//
//  Created by H L on 2017/1/19.
//
//

#import <UIKit/UIKit.h>
#import "SkinSettingViewController.h"

@interface TPDMySkinViewController : UIViewController <BaseTabBarDelegate, LocalSkinItemViewDelegate>

@property (nonatomic, assign)TabSkinIndex startPage;

@end
