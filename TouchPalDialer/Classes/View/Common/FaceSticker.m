//
//  FaceSticker.m
//  TouchPalDialer
//
//  Created by zhang Owen on 8/12/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "FaceSticker.h"
#import <QuartzCore/QuartzCore.h>
#import "FunctionUtility.h"
#import "PhoneNumber.h"
#import "NumberPersonMappingModel.h"
#import "Person.h"
#import "consts.h"
#import "CootekNotifications.h"
#import "ImageCacheModel.h"
#import "ImageViewUtility.h"
#import "TouchPalDialerAppDelegate.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "TPDialerResourceManager.h"
#import "CallerTypeSticker.h"
#import "TPDialerResourceManager.h"

@implementation FaceSticker
@synthesize headImageView;
@synthesize currentNumber;
@synthesize personID;
@synthesize typeLabel;
@synthesize typeImageView;
@synthesize borderImageView;

- (id)initFaceStickerForCell:(CGRect)frame
{
	if (self = [self initWithFrame:frame]) {		
		headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		headImageView.layer.cornerRadius = frame.size.width /2;
		headImageView.layer.masksToBounds = YES;
		headImageView.contentMode = UIViewContentModeScaleAspectFit;
        headImageView.layer.borderWidth = 0.5;
        headImageView.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_50"].CGColor;
        CallerTypeSticker *sticker = [[CallerTypeSticker alloc] initWithFrame:CGRectMake(5, frame.size.height -17, frame.size.width-8, 13)];
        typeLabel = sticker.typeLabel;
        typeImageView = sticker.typeImageView;
        [self addSubview:headImageView];
        [self addSubview:sticker];
        
    }
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
