//
//  TPDialerResource.h
//  testPad
//
//  Created by gan lu on 11/30/11.
//  Copyright (c) 2011 CooTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPDialerColor.h"

#define IMAGE_DIR    @"images"

@class TPDialerColor;

@interface TPDialerResource : NSObject {
    NSString* _rootDir;
    NSString* _font_and_color_dir;
    NSString* _imageDir;
    NSDictionary* _styleDictionary;
}
- (UIImage*)imageForPath:(NSString*)filepath;
- (UIImage*)imageForFilename:(NSString*)filename;
- (id)initWithDirectory:(NSString*)rootDir;

@property(readonly) NSDictionary *_styleDictionary;
@property(nonatomic, readonly, retain) NSString* rootDir;
@end