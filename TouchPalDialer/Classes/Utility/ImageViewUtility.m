//
//  ImageViewUtility.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-18.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "ImageViewUtility.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"

@implementation ImageViewUtility
@synthesize bg_img;
@synthesize _style;

- (id)initImageViewUtilityWithFrame:(CGRect)frame withImage:(UIImage *)img {
	if (self = [self initWithFrame:frame]) {
		bg_img = img;
	}
	return self;
}
- (id)initImageViewUtilityWithFrame:(CGRect)frame wityStyle:(NSString *)style{
     if (self = [self initWithFrame:frame]) {
		self._style = style;
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
     if(_style){
          NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:self._style];
          if([propertyDic objectForKey:BACK_GROUND_COLOR]){
               self.bg_img = [FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:BACK_GROUND_COLOR]] 
                                               withFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
          }
          if([propertyDic objectForKey:BACK_GROUND_IMAGE]){
              self.bg_img =[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:BACK_GROUND_IMAGE]];
          }
     }
    // Drawing code.
	if (bg_img != nil) {
		[bg_img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	}
}
@end
