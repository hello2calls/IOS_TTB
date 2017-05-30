//
//  CallKey.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "CallKey.h"
#import "PhonePadModel.h"
#import "CallLogDataModel.h"
#import "PhoneNumber.h"
#import "FunctionUtility.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "CootekNotifications.h"
#import "TPCallActionController.h"
#import "DialerGuideAnimationUtil.h"
#import "CootekSystemService.h"
#import "TouchPalVersionInfo.h"
@implementation CallKey

@synthesize local_str;
@synthesize callIcon;
@synthesize callkeyTextColor;

- (id)initCallKeyWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.local_str = [NSString stringWithFormat:@""];
	}
	return self;
}
- (void)doWhenPress {
	[super doWhenPress];
	NSString *tel_num = [PhonePadModel getSharedPhonePadModel].input_number;
    NSString *changeNum = [PhonePadModel ABC2Num:tel_num];
	if (tel_num != nil && ![tel_num isEqualToString:@""]) {
        [DialerGuideAnimationUtil waitGuideAnimation];
		CallLogDataModel *call_model = [[CallLogDataModel alloc] init];
		call_model.number = changeNum;
        [TPCallActionController logCallFromSource:@"CallKey"];
		[[TPCallActionController controller] makeCall:call_model];
        if ([AppSettingsModel appSettings].dial_tone){
            [self performSelector:@selector(delayPlay) withObject:nil afterDelay:0.8];
        }
    }
}

-(void)delayPlay{
    [CootekSystemService playCustomKeySound:100];

}
- (void)drawRect:(CGRect)rect {
    // do not call [super drawRect:], which will scale the image to fill the rect
    
    if (img_bg != nil) {
        float widthHeight = img_bg.size.width/img_bg.size.height;
        float rectWidth = rect.size.height * widthHeight;
        [img_bg drawInRect:CGRectMake((rect.size.width - rectWidth)/2, 0, rectWidth ,rect.size.height)];
    }
	if (![FunctionUtility isNilOrEmptyString:local_str]){
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context,[callkeyTextColor CGColor]);
		float paddingTop = 7;
        float paddingLeft = 4;
		int fontsize = 16;
        
		CGSize str_size = [local_str sizeWithFont:[UIFont systemFontOfSize:fontsize]];
		if (str_size.width < self.frame.size.width) {
			paddingTop = (self.frame.size.height - str_size.height )/2;
		}else {
            paddingTop = 7;
        }
		
		[local_str drawInRect:CGRectMake(paddingLeft, paddingTop, self.frame.size.width - paddingLeft * 2, self.frame.size.height - paddingTop * 2)
					 withFont:[UIFont systemFontOfSize:fontsize] 
				lineBreakMode:NSLineBreakByTruncatingMiddle
					alignment:NSTextAlignmentCenter];
	}else{
        if ([FunctionUtility isNilOrEmptyString:local_str] && callIcon) {
            [FunctionUtility image:callIcon drawInRect:rect];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    self.img_bg_normal = [[TPDialerResourceManager sharedManager] getCachedImageByName:
                          [propertyDic objectForKey:CALL_KEY_BACK]];
    self.img_bg_selected = [[TPDialerResourceManager sharedManager] getCachedImageByName:
                            [propertyDic objectForKey:CALL_KEY_BACK_H]];
    self.img_bg = img_bg_normal;
    if([propertyDic objectForKey:CALL_KEY_ICON]){
        self.callIcon = [[TPDialerResourceManager sharedManager] getCachedImageByName:
                         [propertyDic objectForKey:CALL_KEY_ICON]];
    }
    self.callkeyTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"textColor"]];
    [self setNeedsDisplay];
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return  toTop;
}

@end
