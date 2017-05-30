//
//  BYBSearchBar.h
//  Patient
//
//  Created by weyl on 15/4/27.
//  Copyright (c) 2015年 GePingTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPDSearchBar : UIView
@property (nonatomic, strong)UITextField* searchEdit;

-(TPDSearchBar*)tpd_withPlaceholder:(NSString *)placeholder color:(UIColor*)color;
+(TPDSearchBar*)tpd_searchBarStyle1:(void (^)(NSString* keyword))workerBlock;

@end
