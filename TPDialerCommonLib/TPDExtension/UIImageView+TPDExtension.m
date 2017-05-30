//
//  UIImageView+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/26.
//
//

#import "UIImageView+TPDExtension.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "TPDExtension.h"
#import "TPDialerResourceManager.h"

@implementation UIImageView (TPDExtension)


+(UIView*)tpd_imageView:(NSString*)link{
    
    
    if ([link hasPrefix:@"http"]) {
        UIImageView *ret = [[UIImageView alloc] init];
        ret.clipsToBounds = YES;
        [ret sd_setImageWithURL:[NSURL URLWithString:link]];
        return ret;
    }else if([link hasPrefix:@"iphone-ttf"    ]){
        // 对于ttf图标定义如下：
        // @"iphone-ttf:ttf文件名:字符:字号:颜色"
        // etc, @"iphone-ttf:iphoneicon:F:14:tp_color_red_300"
        UILabel *iconLabel = [UILabel tpd_commonLabel];
        NSArray* arr = [link componentsSeparatedByString:@":"];
        iconLabel.text = arr[2];
        iconLabel.backgroundColor = [UIColor clearColor];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.font = [UIFont fontWithName:arr[1] size:[arr[3] integerValue]];
        iconLabel.textColor = [TPDialerResourceManager getColorForStyle:arr[4]];
        return iconLabel;
    }else{
        UIImageView *ret = [[UIImageView alloc] init];
        ret.clipsToBounds = YES;
        [ret setImage:[TPDialerResourceManager getImage:link]];
        return ret;
    }
    
}
@end
