//
//  TPHeaderLabel.h
//  TouchPalDialer
//
//  Created by siyi on 16/5/12.
//
//

#ifndef TPHeaderLabel_h
#define TPHeaderLabel_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+WithSkin.h"

@interface TPHeaderLabel : UILabel <SelfSkinChangeProtocol>

@property (nonatomic, assign, readonly) BOOL usingDefaultSkin;


- (instancetype) initWithFrame:(CGRect)frame headerTitle:(NSString *)headerTitle usingDefaultSkin:(BOOL)useDefaultSkin;
- (instancetype) initWithFrame:(CGRect)frame headerTitle:(NSString *)headerTitle;
- (instancetype) initWithHeaderTitle:(NSString *)title;
- (instancetype) initWithDefaultSkin;

@end

#endif /* TPHeaderLabel_h */
