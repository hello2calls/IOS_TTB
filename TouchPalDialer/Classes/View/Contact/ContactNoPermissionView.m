//
//  ContactNoPermissionView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/21.
//
//

#import "ContactNoPermissionView.h"
#import "TPDialerResourceManager.h"

@interface ContactNoPermissionView(){
    UILabel *secondLabel;
    UILabel *thirdLabel;
    UIImageView *imageView;
}

@end

@implementation ContactNoPermissionView

- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];

    if ( self ){
        self.backgroundColor = [UIColor whiteColor];
        
        float depth = 40;
        if ( TPScreenHeight() < 500 ){
            depth = 25;
        }
        float height = 270 + 2*depth;
        float globayY = (frame.size.height - height)/2;

        NSString *secondLabelText;
        NSString *thirdLabelText;
        NSString *imageName;

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
            secondLabelText = @"前往「设置-触宝电话」中";
            thirdLabelText = @"允许访问您的通讯录";
            imageName = @"contacts_authority_guide_ios8@2x.png";
        }else{
            secondLabelText = @"前往「设置-隐私-通讯录」中";
            thirdLabelText = @"允许「触宝电话」访问您的通讯录";
            imageName = @"contacts_authority_guide_ios7@2x.png";
        }

        UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globayY, TPScreenWidth(), 24)];
        firstLabel.text = @"无法显示联系人";
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:22];
        firstLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        [self addSubview:firstLabel];

        globayY += firstLabel.frame.size.height + 14;

        secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globayY, TPScreenWidth(), 16)];
        secondLabel.text = secondLabelText;
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
        secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"defaultCellDetailText_color"];
        [self addSubview:secondLabel];

        globayY += secondLabel.frame.size.height + 4;

        thirdLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globayY, TPScreenWidth(), 16)];
        thirdLabel.text = thirdLabelText;
        thirdLabel.backgroundColor = [UIColor clearColor];
        thirdLabel.textAlignment = NSTextAlignmentCenter;
        thirdLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
        thirdLabel.textColor = [TPDialerResourceManager getColorForStyle:@"defaultCellDetailText_color"];
        [self addSubview:thirdLabel];

        globayY += thirdLabel.frame.size.height + depth;

        UIImage *bgImage = [TPDialerResourceManager getImage:imageName];
        float imageWidth = bgImage.size.width/bgImage.size.height*150;

        imageView = [[UIImageView alloc]initWithFrame:CGRectMake((TPScreenWidth()-imageWidth)/2, globayY, imageWidth, 150)];
        imageView.image = bgImage;
        [self addSubview:imageView];

        globayY += imageView.frame.size.height + depth;

        UIButton *setButton = [[UIButton alloc]initWithFrame:CGRectMake((TPScreenWidth()-230)/2, globayY, 230, 46)];
        setButton.layer.masksToBounds = YES;
        setButton.layer.cornerRadius = 3.0f;
        setButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16];
        [setButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_normalCall_button_normal_bg_image"] forState:UIControlStateNormal];
        [setButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_normalCall_button_onClick_bg_image"] forState:UIControlStateHighlighted];
        [self addSubview:setButton];
        [setButton setTitle:@"立即设置" forState:UIControlStateNormal];
        [setButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [setButton addTarget:self action:@selector(onSetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;

}

- (void)onSetButtonPressed{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
    }
}

- (id)selfSkinChange:(NSString *)style{
    secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"defaultCellDetailText_color"];
    thirdLabel.textColor = [TPDialerResourceManager getColorForStyle:@"defaultCellDetailText_color"];

    NSString *imageName;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
        imageName = @"contacts_authority_guide_ios8@2x.png";
    }else{
        imageName = @"contacts_authority_guide_ios7@2x.png";
    }
    imageView.image = [TPDialerResourceManager getImage:imageName];
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}

@end
