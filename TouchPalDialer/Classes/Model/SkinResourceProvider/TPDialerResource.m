//
//  TPDialerResource.m
//  testPad
//
//  Created by gan lu on 11/30/11.
//  Copyright (c) 2011 CooTek. All rights reserved.
//

#import "TPDialerResource.h"
#define CONTEXT_INFO_FILE @"info.plist"
#define FONT_AND_COLOR_DIR @"styles"


@implementation TPDialerResource
@synthesize _styleDictionary;
@synthesize rootDir = _rootDir;

- (id)init{
    if (self = [super init]) {
        _font_and_color_dir =[NSString stringWithFormat:@"%@/%@",_rootDir,FONT_AND_COLOR_DIR];
        _imageDir = [[_rootDir stringByAppendingPathComponent:IMAGE_DIR] copy];
        _styleDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_font_and_color_dir ,@"style.plist"]];
    }
   return self;
}
- (id)initWithDirectory:(NSString*)dir{
    _rootDir = [dir copy];
    if(self = [self init]){
        
    }
    return self;
}

-(NSString*)imageResourceFullPath:(NSString*)filename{
     return [NSString stringWithFormat:@"%@/%@",_imageDir,filename];
}

- (UIImage*)imageForPath:(NSString*)filepath{
    return [UIImage imageWithContentsOfFile:filepath]; 
}

- (UIImage*)imageForFilename:(NSString*)filename{
    return [self imageForPath:[self imageResourceFullPath:filename]];
}

@end
