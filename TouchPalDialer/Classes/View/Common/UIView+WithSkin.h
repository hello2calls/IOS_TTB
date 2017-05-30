//
//  UIView+WithSkin.h
//
//  Created by Liangxiu on 6/29/12.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#define   NO_STYLE @"NO_STYLE"
#define   SELF_RESPONDS_STYLE @"SELF_RESPONDS_STYLE"
#define   DRAW_RECT_STYLE @"DRAW_RECT_STYLE"

@protocol SelfSkinChangeProtocol
-(id) selfSkinChange:(NSString *)style;
@end

@interface UIView (WithSkin)
-(BOOL) setSkinStyleWithHost:(id)host forStyle:(NSString*) style;
-(BOOL) applySkinWithStyle:(NSString*) style;
-(BOOL) applyDefaultSkinWithStyle:(NSString*) style;
@end
