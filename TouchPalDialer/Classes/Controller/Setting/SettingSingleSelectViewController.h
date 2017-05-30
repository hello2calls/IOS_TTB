//
//  SettingSingleSelectViewController.h
//  TouchPalDialer
//
//  Created by Stony Wang on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"

@interface SettingSingleSelectViewController : SettingViewController{
}

-(id)initWithTitles:(NSArray *)titles selectedIndex:(NSInteger)index andSelectBlock:(void(^)(NSInteger selectedIndex))selectBlock;
@end
