//
//  ContactEmptyGuideView.m
//  TouchPalDialer
//
//  Created by siyi on 16/5/4.
//
//


#import "ContactEmptyGuideView.h"
#import "TPDialerResourceManager.h"
#import "UILabel+TPHelper.h"
#import "FunctionUtility.h"
#import "ContactTransferGuideController.h"
#import "ContactTransferMainController.h"
#import "UserDefaultsManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "DialerUsageRecord.h"

@implementation ContactEmptyGuideView {
    
}

#pragma mark initializers
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat gY = 0;
        
        // image view
        if (isIPhone5Resolution()) {
            gY += 88;
        } else {
            gY += 40;
        }
        UIImage *guideImage = [TPDialerResourceManager getImage:@"contact_empty_guide_for_transfer@2x.png"];
        CGFloat imageViewHeight = guideImage.size.height;
        if (!isIPhone5Resolution()) {
            imageViewHeight = imageViewHeight * 0.8;
        }
        CGRect imageFrame = CGRectMake(0, gY, TPScreenWidth(), imageViewHeight);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = guideImage;
        gY += imageView.frame.size.height;
        
        UIFont *hintFont = [UIFont systemFontOfSize:15];
        UIColor *hintColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        // hint label: line one
        gY += 15;
        UILabel *hintLabelOne = [[UILabel alloc] initWithTitle:@"新手机没有联系人？试试通讯录迁移，" font:hintFont isFillContentSize:YES];
        hintLabelOne.frame = CGRectMake(0, gY, TPScreenWidth(), hintLabelOne.frame.size.height);
        hintLabelOne.textColor = hintColor;
        gY += hintLabelOne.frame.size.height;
        
        // hint label: line two
        gY += 10;
        UILabel *hintLabelTwo = [[UILabel alloc] initWithTitle:@"扫描二维码，轻松迁移联系人" font:hintFont isFillContentSize:YES];
        hintLabelTwo.frame = CGRectMake(0, gY, TPScreenWidth(), hintLabelTwo.frame.size.height);
        hintLabelTwo.textColor = hintColor;
        gY += hintLabelTwo.frame.size.height;
        
        // button
        gY += 18;
        CGSize btnSize = CGSizeMake(150, 46);
        CGRect buttonFrame = CGRectMake((TPScreenWidth() - btnSize.width ) / 2, gY, btnSize.width, btnSize.height);
        UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
        button.layer.cornerRadius = 4;
        button.clipsToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        button.titleLabel.textColor = [UIColor whiteColor];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:@"立即迁移" forState:UIControlStateNormal];
        
        CGRect bgFrame = CGRectMake(0, 0, buttonFrame.size.width, buttonFrame.size.height);
        UIImage *normalImage = [TPDialerResourceManager getImageByColorName:@"tp_color_light_blue_500" withFrame:bgFrame];
        UIImage *htImage = [TPDialerResourceManager getImageByColorName:@"tp_color_light_blue_700" withFrame:bgFrame];
        [button setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button setBackgroundImage:htImage forState:UIControlStateHighlighted];
        
        [button addTarget:self action:@selector(onClickContactTransferButton) forControlEvents:UIControlEventTouchUpInside];
        gY += button.frame.size.height;
        
        // view tree
        [self addSubview:imageView];
        [self addSubview:hintLabelOne];
        [self addSubview:hintLabelTwo];
        [self addSubview:button];
        
    }
    return self;
}

#pragma mark life circle

#pragma mark actions
- (void) onClickContactTransferButton {
    UIViewController *controller = nil;
    if ([UserDefaultsManager boolValueForKey:CONTACT_TRANSFER_GUIDE_CLICKED defaultValue:NO]) {
        controller = [[ContactTransferMainController alloc] init];
    } else {
        controller = [[ContactTransferGuideController alloc] init];
    }
    if (controller) {
        [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    }
    [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                              kvs:Pair(CONTACT_TRANSFER_ENTRANCE_CLICK, @(1)), nil];
}

#pragma mark helpers

@end