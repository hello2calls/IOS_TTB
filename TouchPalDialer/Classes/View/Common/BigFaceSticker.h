//
//  BigFaceSticker.h
//  TouchPalDialer
//
//  Created by zhang Owen on 11/22/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BigFaceSticker : UIView {
	UIImage *m_photo;
}

@property(nonatomic, retain) UIImage *m_photo;
@property(nonatomic, retain) UILabel *typeLabel;
@property(nonatomic, retain) UIImageView *typeImageView;

- (id)initBigFaceSticker:(CGRect)frame withPhoto:(UIImage *)photo;

@end
