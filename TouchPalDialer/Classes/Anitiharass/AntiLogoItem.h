//
//  AntiLogoItem.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/10.
//
//

#import "AntiNormalItem.h"

@interface AntiLogoItem : AntiNormalItem

@property (nonatomic,copy) HandleBlock logoHandle;

+ (instancetype)itemWithHandle:(HandleBlock)logoHandle height:(CGFloat)height;

@end
