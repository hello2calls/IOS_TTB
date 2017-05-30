//
//  YellowPageGuideView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 10/23/12.
//
//

#import "YellowPageGuideView.h"
#import "TPDialerResourceManager.h"

@implementation YellowPageGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [[TPDialerResourceManager sharedManager] getImageByName:NSLocalizedString(@"dialerView_yellowPageGuideImage_en@2x.png", @"")];
        UIImageView *guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        if(frame.size.height>image.size.height){
            UIView *patchView = [[UIView alloc] initWithFrame:CGRectMake(0, image.size.height, frame.size.width, frame.size.height-image.size.height)];
            patchView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"dialerView_yellowPageGuideImage_patch_color"];
            [self addSubview:patchView];
        }
        guideImageView.image = image;
        [self addSubview:guideImageView];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_YELLOWPAGE_DUIDEVIEW_REMOVED_FROM_SUPERVIEW object:nil];
}
@end
