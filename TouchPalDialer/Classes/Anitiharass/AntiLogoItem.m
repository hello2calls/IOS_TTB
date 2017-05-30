//
//  AntiLogoItem.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/10.
//
//

#import "AntiLogoItem.h"

@implementation AntiLogoItem

+ (instancetype)itemWithHandle:(HandleBlock)logoHandle height:(CGFloat)height{

    AntiLogoItem *item = [self itemWithTitle:nil subtitle:nil vcClass:nil clickHandle:nil];
    item.logoHandle = logoHandle;
    item.height = height;
    return item;
}

@end
