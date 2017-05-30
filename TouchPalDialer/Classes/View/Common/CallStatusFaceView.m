//
//  CallStatusFaceView.m
//  TouchPalDialer
//
//  Created by Sendor on 11-11-22.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "CallStatusFaceView.h"
#import "FunctionUtility.h"
#import "ImageCacheModel.h"
#import "TouchPalDialerAppDelegate.h"
#import "PersonDBA.h"

@implementation CallStatusFaceView
@synthesize face_image_view = _face_image_view;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        CGRect contentFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        UIImage* defaultFacePhoto = [PersonDBA getDefaultColorImageWithoutPersonID];
        UIImageView* face = [[UIImageView alloc] initWithImage:defaultFacePhoto];
        face.frame = contentFrame;
        face.layer.masksToBounds = YES;
        face.layer.cornerRadius = frame.size.width /2;
        self.face_image_view = face;
        [self addSubview:face];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/


- (void)setFaceImage:(UIImage*)faceImage {
    if (faceImage && !_face_image_view.hidden) {
        _face_image_view.image = faceImage;
        [self setNeedsDisplay];
    }
}

- (void)setDefaultFaceImage {
    UIImage* defaultFaceImage =  [PersonDBA getDefaultColorImageWithoutPersonID];
    _face_image_view.image = defaultFaceImage;
    [self setNeedsDisplay];
}
@end
