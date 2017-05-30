//
//  ImageViewUtility.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-18.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageViewUtility : UIView {
	UIImage *bg_img;
     NSString *_style;
}

- (id)initImageViewUtilityWithFrame:(CGRect)frame withImage:(UIImage *)img;
- (id)initImageViewUtilityWithFrame:(CGRect)frame wityStyle:(NSString *)style;
@property(nonatomic,retain)	UIImage *bg_img;
@property(nonatomic,copy)   NSString *_style;
@end
