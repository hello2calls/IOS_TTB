//
//  CallADViewDisplay.m
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/7.
//
//

#import "CallADViewDisplay.h"
#import "AdMessageModel.h"
#import "HangupCommercialManager.h"
#import "VoipUtils.h"
@implementation CallADViewDisplay {
    __weak UIView *_holderView;
    UIView *_adBgView;
    UIView *_bottomCoverView;
    
    AdMessageModel *_ad;
}

- (id)initWithHostView:(UIView *)view andDisplayArea:(CGRect)frame
{
    self = [super init];
    if (self) {
        _holderView = view;
        _adBgView = [[UIView alloc] initWithFrame:frame];
        _adBgView.backgroundColor = [UIColor clearColor];
        [_holderView addSubview:_adBgView];
        
        _adView = [[UIImageView alloc] initWithFrame:frame];
        _adView.userInteractionEnabled = YES;
        _adView.alpha = 0.0;
        [_adBgView addSubview:_adView];

    }
    return self;
}

#pragma mark Action

- (void)clickAdButton:(id)sender
{
    if (_adView.image && _adView.alpha > 0.1) { // has AD  and AD did show
        [[HangupCommercialManager instance] didClickAD:_ad];
    }
}

#pragma mark Public

- (void)setAdAlpha:(CGFloat)adAlpha
{
    _adView.alpha = adAlpha;
}

- (void)loadAD:(AdMessageModel *)model image:(UIImage *)image
{
    _ad = model;
    _adView.image = image;
}

- (void)showADWithImage:(UIImage *)image
{
    if (image) {
        _adView.image = image;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            _adView.alpha = 1;
            _bottomCoverView.alpha = 1;
        } completion: nil];
    }
}

- (void)hideAD
{
    [UIView animateWithDuration:0.2 animations:^{
        _adView.alpha = 0;
    }];
}



#pragma mark Private
- (void)addLinearGradientToView:(UIView *)theView withColor:(UIColor *)theColor
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    //the gradient layer must be positioned at the origin of the view
    CGRect gradientFrame = theView.frame;
    gradientFrame.origin.x = 0;
    gradientFrame.origin.y = 0;
    gradient.frame = gradientFrame;
    
    //build the colors array for the gradient
    NSArray *colors = [NSArray arrayWithObjects:
                       (id)[[theColor colorWithAlphaComponent:0.0f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.3f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.5f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.7f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.9f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:1.0f] CGColor],
                       nil];
    //apply the colors and the gradient to the view
    gradient.colors = colors;
    [theView.layer insertSublayer:gradient atIndex:0];
}

@end
