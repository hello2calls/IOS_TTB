//
//  WebLoadingView.m
//  TouchPalDialer
//
//  Created by siyi on 15/10/29.
//
//

#import <Foundation/Foundation.h>
#import "TPLoadingView.h"

@implementation TPLoadingView

- (instancetype) initWithImage:(UIImage *)image mainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle {
    if (self = [super init]) {
        if (image) {
            _loadingImageView = [[UIImageView alloc] initWithImage:image];
            [self addSubview:_loadingImageView];
        }
        if (mainTitle) {
            _mainTitleLabel = [[UILabel alloc] init];
            _mainTitleLabel.font = [UIFont systemFontOfSize:14];
            _mainTitleLabel.text = mainTitle;
            _mainTitleLabel.textAlignment = NSTextAlignmentCenter;
            _mainTitleLabel.textColor = [UIColor blackColor];
            
            [self addSubview:_mainTitleLabel];
        }
        if (subTitle) {
            _subTitleLabel = [[UILabel alloc] init];
            _subTitleLabel.font = [UIFont systemFontOfSize:14];
            _subTitleLabel.text = subTitle;
            _subTitleLabel.textAlignment = NSTextAlignmentCenter;
            _subTitleLabel.textColor = [UIColor blackColor];
            [self addSubview:_subTitleLabel];
        }
        CGSize loadingImageSize = _loadingImageView.frame.size;
        CGSize mainTitleSize = _mainTitleLabel.frame.size;
        CGSize subTitleSize = _subTitleLabel.frame.size;
        
        CGFloat containerHeight = loadingImageSize.height + mainTitleSize.height + subTitleSize.height;
        CGFloat containerWidth = (mainTitleSize.width > subTitleSize.width) ? mainTitleSize.width : subTitleSize.width;
        containerWidth = (containerWidth > loadingImageSize.width) ? containerWidth : loadingImageSize.width;
        
        self.frame = CGRectMake(0, 0, containerWidth, containerHeight);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype) initWithImagePath:(NSString *)imagePath mainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle {
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    return [self initWithImage:image mainTitle:mainTitle subTitle:subTitle];
}

- (instancetype) initWithImage:(UIImage *)image mainTitle:(NSString *)mainTitle {
    return [self initWithImage:image mainTitle:mainTitle subTitle:nil];
}

- (instancetype) initWithImagePath:(NSString *)imagePath mainTitle:(NSString *)mainTitle {
    return [self initWithImagePath:imagePath mainTitle:mainTitle subTitle:nil];
}

- (void) startAnimation {
    
}

- (void) stopAnimation {
    
}

@end


