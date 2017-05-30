//
//  CallStatusFaceView.h
//  TouchPalDialer
//
//  Created by Sendor on 11-11-22.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "consts.h"

@interface CallStatusFaceView : UIView {
    
}

@property(nonatomic, retain) UIImageView* face_image_view;

- (void)setFaceImage:(UIImage*)faceImage;
- (void)setDefaultFaceImage;

@end
