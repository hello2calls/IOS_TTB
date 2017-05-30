//
//  BigFaceSticker.m
//  TouchPalDialer
//
//  Created by zhang Owen on 11/22/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "BigFaceSticker.h"
#import "TPDialerResourceManager.h"

@implementation BigFaceSticker
@synthesize m_photo;
@synthesize typeLabel;
@synthesize typeImageView;


- (id)initBigFaceSticker:(CGRect)frame withPhoto:(UIImage *)photo {
	if (self = [self initWithFrame:frame]) {
		self.m_photo = photo;
        typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height -16, frame.size.width, 17)];
        typeImageView.backgroundColor = [UIColor clearColor];
		typeImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height -17, frame.size.width, 17)];
        typeLabel.backgroundColor = [UIColor clearColor];
        typeLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultText_color"];
        typeLabel.textAlignment = NSTextAlignmentCenter;
        typeLabel.adjustsFontSizeToFitWidth = YES;
        typeLabel.hidden = YES;
        [self addSubview:typeImageView];
        [self addSubview:typeLabel];
	}	
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// 头像
	[m_photo drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}



@end
