//
//  FaceSticker.h
//  TouchPalDialer
//
//  Created by zhang Owen on 8/12/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "consts.h"


@interface FaceSticker : UIView {
	NSString *currentNumber;
	NSInteger personID;
	UIImageView *headImageView;
    UIImageView *borderImageView;
}
@property(nonatomic,assign)  NSInteger personID;
@property(nonatomic, retain) NSString *currentNumber;
@property(nonatomic, retain) UIImageView *headImageView;
@property(nonatomic, retain) UILabel *typeLabel;
@property(nonatomic, retain) UIImageView *typeImageView;
@property(nonatomic, retain) UIImageView *borderImageView;

- (id)initFaceStickerForCell:(CGRect)frame;

@end
