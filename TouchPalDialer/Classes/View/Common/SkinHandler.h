//
//  SkinHandler.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
@interface SkinHandler : NSObject
+(void) setSkinStyle:(NSString*)style forView:(UIView*) viewElement withHost:(id)host;
+(void) applySkinRecursivelyForView:(UIView*) rootView;
+(void) removeRecursively:(id)host;

@end