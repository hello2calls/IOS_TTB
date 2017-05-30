//
//  ContactTransferGuidePageView.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/15.
//
//

#import "ContactTransferGuidePageView.h"
#import "UILayoutUtility.h"
#import "UILabel+TPHelper.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"

@implementation ContactTransferGuidePageView {
    BOOL _isIPhone5;
}

- (instancetype) initWithFrame:(CGRect)frame PageInfo:(ContactTransferPageInfo *)pageInfo {
    self = [super init];
    if (self) {
        _isIPhone5 = isIPhone5Resolution();
        _pageInfo = pageInfo;
        self.frame = frame;

        CGFloat gY = 0;

        UIView *titleContainer = [self getTitleView];
        [self addSubview:titleContainer];
        gY = titleContainer.frame.origin.y;
        gY += titleContainer.bounds.size.height;

        UIImageView *guideImageView = [self getGuideImageView];
        CGRect prevFrame = guideImageView.frame;
        guideImageView.frame = CGRectMake(prevFrame.origin.x, gY + prevFrame.origin.y,
                                          prevFrame.size.width, prevFrame.size.height);
        [self addSubview:guideImageView];

        _button = [self getButtonView];
        if (_button) {
            [self addSubview:_button];
        }
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype) initWithPageInfo:(ContactTransferPageInfo *) pageInfo {
    _isIPhone5 = isIPhone5Resolution();
    CGFloat marginBottomPercent = PAGE_MARGIN_BOTTOM_SMALL;
    if (_isIPhone5) {
        marginBottomPercent = PAGE_MARGIN_BOTTOM; // for iphone 5 and higher,
    }
    CGFloat height = (1 - marginBottomPercent) * TPScreenHeight();
    CGRect frame = CGRectMake(0, 0, TPScreenWidth(),  height);
    return [self initWithFrame:frame PageInfo:pageInfo];
}

- (UIImageView *) getGuideImageView {
    if (!_pageInfo.imageName) {
        return nil;
    }

    UIImage *image = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:_pageInfo.imageName];
    if (!image) {
        return nil;
    }
    CGSize percentSize = CGSizeMake(0.48, 0.48);
    if (_isIPhone5) {
        percentSize = CGSizeMake(0.4, 0.4);
    }
    // repsect the height, NOT width
    CGSize imageViewSize = CGSizeMake(TPScreenHeight() * percentSize.width,
                                      TPScreenHeight() * percentSize.height);

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat marginTop = 0.07 * TPScreenHeight();
    if (_isIPhone5) {
        marginTop = 0.05 * TPScreenHeight();
    }
    imageView.frame = CGRectMake((TPScreenWidth() - imageViewSize.width ) / 2, marginTop,
                                 imageViewSize.width, imageViewSize.height);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    return imageView;
}

- (UIView *) getTitleView {
    UIView *container = nil;
    UILabel *mainLabel = nil;
    UILabel *altLabel = nil;

    CGFloat gY = 0;

    if (_pageInfo.mainTitle) {
        mainLabel = [[UILabel alloc] initWithTitle:_pageInfo.mainTitle fontSize:28];
        if (mainLabel) {
            CGFloat marginTopPercent = PAGE_MARGIN_TOP_SMALL;
            if (_isIPhone5) {
                marginTopPercent = PAGE_MARGIN_TOP;
            }

            gY = TPScreenHeight() * marginTopPercent;

            mainLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];

            CGSize mainSize = mainLabel.bounds.size;
            mainLabel.frame = CGRectMake((TPScreenWidth() - mainSize.width) / 2, gY,
                                         mainSize.width, mainSize.height);
            gY += mainSize.height;
        }

    }
    if (_pageInfo.altTitle) {
        altLabel = [[UILabel alloc] initWithTitle:_pageInfo.altTitle fontSize:18];
        if (altLabel) {
            altLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_600"];
            gY += (TPScreenHeight() * 0.025);
            CGSize altSize = altLabel.bounds.size;
            altLabel.frame = CGRectMake((TPScreenWidth() - altSize.width) / 2, gY,
                                        altSize.width, altSize.height);
            gY += altSize.height;
        }
    }

    // set up view tree
    if (mainLabel) {
        if (!container) {
            container = [[UIView alloc] init];
        }
        [container addSubview:mainLabel];
    }
    if (altLabel) {
        if (!altLabel) {
            container = [[UIView alloc] init];
        }
        [container addSubview:altLabel];
    }
    if (container) {
        container.frame = CGRectMake(0, 0, TPScreenWidth(), gY);
    }
    return container;
}

- (UIButton *) getButtonView {
    if (!_pageInfo.buttonTittle) {
        return nil;
    }
    CGSize buttonSize = CGSizeMake(220, 50);
    CGFloat pageHeight = self.bounds.size.height;
    CGFloat originY = pageHeight- buttonSize.height;

    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(
                    (TPScreenWidth() - buttonSize.width) / 2, originY,
                    buttonSize.width, buttonSize.height)];

    [buttonView setTitle:_pageInfo.buttonTittle forState:UIControlStateNormal];
    UIColor *normalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    [buttonView setTitleColor:normalColor forState:UIControlStateNormal];

    buttonView.titleLabel.font = [UIFont systemFontOfSize:17];
    buttonView.titleLabel.textAlignment = NSTextAlignmentCenter;

    UIImage *normalBgImage = [TPDialerResourceManager getImageByColorName:@"tp_color_white" withFrame:buttonView.bounds];
    UIImage *hlBgImage = [TPDialerResourceManager getImageByColorName:@"tp_color_white_transparency_600" withFrame:buttonView.bounds];
    buttonView.clipsToBounds = YES;
    buttonView.layer.cornerRadius = 4;

    [buttonView setBackgroundImage:normalBgImage forState:UIControlStateNormal];
    [buttonView setBackgroundImage:hlBgImage forState:UIControlStateHighlighted];

    if (_pageInfo.buttonAction) {
        [buttonView addTarget:self action:@selector(onButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return buttonView;
}

- (void) onButtonClick {
    if (self.pageInfo.buttonAction) {
        self.pageInfo.buttonAction();
    }
}
@end
