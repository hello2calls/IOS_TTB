//
//  TPButtonColorManager.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/14.
//
//

#import <Foundation/Foundation.h>
#import "TPButton.h"

@interface TPButtonColorManager : NSObject

@property (nonatomic, retain) UIColor *layerNormalColor;
@property (nonatomic, retain) UIColor *layerHightlightColor;
@property (nonatomic, retain) UIColor *layerDisabledColor;
@property (nonatomic, retain) UIColor *bodyNormalColor;
@property (nonatomic, retain) UIColor *bodyHightlightColor;
@property (nonatomic, retain) UIColor *bodyDisabledColor;
@property (nonatomic, retain) UIColor *titleNormalColor;
@property (nonatomic, retain) UIColor *titleHightlightColor;
@property (nonatomic, retain) UIColor *titleDisabledColor;
@property (nonatomic, retain) UIColor *subtitleNormalColor;
@property (nonatomic, retain) UIColor *subtitleHightlightColor;
@property (nonatomic, retain) UIColor *subtitleDisableColor;

- (instancetype)initWithType:(ButtonType)type;

@end
