//
//  ContactTransferMainController.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/18.
//
//

#import "ContactTransferMainController.h"
#import "TPDialerResourceManager.h"
#import "UILabel+DynamicHeight.h"
#import "UILabel+TPHelper.h"
#import "ContactTransferSendController.h"
#import "ContactTransferReceiveController.h"
#import "Reachability.h"
#import "DefaultUIAlertViewHandler.h"
#import "DialerUsageRecord.h"
#import "SyncContactWhenAppEnterForground.h"
#import "UserDefaultsManager.h"

@implementation ContactTransferMainController

- (void) viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    UIColor *commonBgColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    UIView *headerView = [self getHeaderView];

    self.view.backgroundColor = commonBgColor;
    headerView.backgroundColor = commonBgColor;

    UIView *topPartView = [self getTopPartView];
    UIView *bottomPartView = [self getBottomPartView];
    UIView *avatarHolderView = [self getAvatarHolderView];
    // set up view tree
    [self.view addSubview:topPartView];
    [self.view addSubview:bottomPartView];
    [self.view addSubview:avatarHolderView];

    //make sure the header is added at the last to receive the back press.
    
    [self.view addSubview:headerView];
}

#pragma mark private functions
- (UIView *) getHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeaderBarHeight())];
    headerView.backgroundColor = [UIColor clearColor];

    // back button
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(5, TPHeaderBarHeightDiff(),50, 45)];
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
    [cancelButton setTitle:@"0" forState:UIControlStateNormal];

    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];

    CGSize titleButtonSize = CGSizeMake(120, 45);
    CGRect titleFrame = CGRectMake((TPScreenWidth() - titleButtonSize.width)/2, TPHeaderBarHeightDiff(),
                                   titleButtonSize.width, titleButtonSize.height);
    UIButton *titleButton = [[UIButton alloc] initWithFrame:titleFrame];
    titleButton.backgroundColor = [UIColor clearColor];
    titleButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [titleButton setTitle:@"通讯录迁移" forState:UIControlStateNormal];

    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    //set up view tree
    [headerView addSubview:cancelButton];
    [headerView addSubview:titleButton];

    return headerView;
}

- (void) goToBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onDirectionIconClick:(UITapGestureRecognizer *)recognizer {
    if (!recognizer || !recognizer.view) {
        return;
    }
    UIView *imageButton = (UIView *)recognizer.view;
    TransferDirectionView *itemView = (TransferDirectionView *)imageButton.superview;
    if (!imageButton || !itemView) {
        return;
    }
    if ([[Reachability shareReachability] networkStatus] == network_none) {
        NSString *mainTitle = @"没有连接到网络，无法迁移联系人哦~";
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                  message:mainTitle
                                                 ];
        return;
    }
    switch (itemView.info.direction) {
        case DIRECTION_SEND: {
            ContactTransferSendController *controller = [[ContactTransferSendController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                                      kvs:Pair(CONTACT_TRANSFER_SEND_CLICK, @(1)), nil];
            break;
        }
        case DIRECTION_RECEIVE: {
            ContactTransferReceiveController *controller = [[ContactTransferReceiveController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                                      kvs:Pair(CONTACT_TRANSFER_RECEIVE_CLICK, @(1)), nil];
            break;
        }
        case DIRECTION_UNKNOWN:
        default: {
            break;
        }
    }
}

#pragma mark get views
- (UIView *) getTopPartView {
    CGFloat partHeight = [self getTopPartHeight];

    CGRect frame = CGRectMake(0, 0, TPScreenWidth(), partHeight);
    UIView *partView = [[UIView alloc] initWithFrame:frame];
    partView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    return partView;
}

- (UIView *) getBottomPartView {
    CGFloat partHeight = [self getHeightByPercent:(1- TOP_PART_HEIGHT_PERCENT)
                                percentForIphone4:(1 - TOP_PART_HEIGHT_PERCENT_SMALL)];
    CGRect frame = CGRectMake(0, (TPScreenHeight() - partHeight), TPScreenWidth(), partHeight);

    UIView *partView = [[UIView alloc] initWithFrame:frame];
    partView.backgroundColor = [UIColor whiteColor];

    NSArray *infos = [self getDirectionInfos];
    if (infos) {
        NSInteger infoCount = infos.count;
        CGFloat gX = 0;
        CGFloat gY = 0;
        gY = ICON_TOP_MARGIN_PERCENT_SAMLL;
        if (isIPhone5Resolution()) {
            gY = ICON_TOP_MARGIN_PERCENT;
        }
        gY = gY * TPScreenHeight();
        CGFloat itemWidth = 0, itemHeight = 0;
        for(NSInteger index = 0; index < infoCount; index++) {
            TransferDirectionView *itemView = [[TransferDirectionView alloc] initWithDirectionInfo:infos[index]];
            CGRect oldFrame = itemView.frame;

            if (!itemView) {
                continue;
            }
            UITapGestureRecognizer *clickRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDirectionIconClick:)];
            [itemView.imageButton addGestureRecognizer:clickRecognizer];
            //
            if (itemWidth == 0) {
                itemWidth = oldFrame.size.width;
                itemHeight = oldFrame.size.height;
            }
            if (gX == 0) {
                 gX = (TPScreenWidth() - infoCount * itemWidth - 60) / 2;
                 gY = (partHeight - itemHeight) / 2;
            }
            if (index != 0) {
                gX += 60;
            }

            CGRect newFrame = CGRectMake(gX, gY, oldFrame.size.width, oldFrame.size.height);
            itemView.frame = newFrame;
            [partView addSubview:itemView];
            gX += oldFrame.origin.x + oldFrame.size.width;
        }
    }

    return partView;
}

- (UIView *) getAvatarHolderView {
    CGFloat diameter = AVATAR_DIAMETER_PERCENT_SMALL;
    if (isIPhone5Resolution()) {
        diameter = AVATAR_DIAMETER_PERCENT;
    }
    diameter = diameter * TPScreenHeight();

    CGFloat marginBottom = [self getHeightByPercent:AVATAR_MARGIN_BOTTOM_PERCENT
                                  percentForIphone4:AVATAR_MARGIN_BOTTOM_PERCENT_SAMLL];
    CGFloat gY = [self getTopPartHeight] - marginBottom - diameter;

    CGRect frame = CGRectMake((TPScreenWidth() - diameter)/2, gY, diameter, diameter);
    UIImage *transferIcon = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"contact_transfer_top_image@2x.png"];
    UIImageView *transferIconView = [[UIImageView alloc] initWithImage:transferIcon];
    transferIconView.frame = frame;
    transferIconView.contentMode = UIViewContentModeCenter;

    return transferIconView;
}

- (CGFloat) getTopPartHeight {
    return [self getHeightByPercent:TOP_PART_HEIGHT_PERCENT
           percentForIphone4:TOP_PART_HEIGHT_PERCENT_SMALL];
}

- (CGFloat) getBottomPartHeight {
    return TPScreenHeight() - [self getTopPartHeight];
}

- (CGFloat) getHeightByPercent: (CGFloat) heightPercent percentForIphone4: (CGFloat) percentSmall {
    CGFloat partHeight = percentSmall;
    if (isIPhone5Resolution()) {
        partHeight = heightPercent;
    }
    partHeight = partHeight * TPScreenHeight();
    return partHeight;
}

#pragma mark models
- (NSArray *) getDirectionInfos {
    TransferDirectionInfo *sendInfo = [[TransferDirectionInfo alloc] init];
    sendInfo.imageName = @"contact_transfer_icon_send@2x.png";
    sendInfo.mainTitle = @"发送";
    sendInfo.altTitle = @"我是旧手机";
    sendInfo.direction = DIRECTION_SEND;

    TransferDirectionInfo *receiveInfo = [[TransferDirectionInfo alloc] init];
    receiveInfo.imageName = @"contact_transfer_icon_receive@2x.png";
    receiveInfo.mainTitle = @"接收";
    receiveInfo.altTitle = @"我是新手机";
    receiveInfo.direction = DIRECTION_RECEIVE;

    return @[sendInfo, receiveInfo];
}

@end


//----------------------------TransferDirectionInfo--------------------------------------
@implementation TransferDirectionInfo

@end

//----------------------------TransferDirectionView--------------------------------------
@implementation TransferDirectionView

- (instancetype) initWithDirectionInfo:(TransferDirectionInfo *)info {
    if (!info) {
        return nil;
    }
    self = [super init];
    if (self) {
        _info = info;
        CGFloat commonWidth = 80;
        CGFloat gY = 0;

        // circle button
        _imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, gY, commonWidth, commonWidth)];
        _imageButton.adjustsImageWhenHighlighted = NO; // avoid to grey the image
        CGRect imageBounds = _imageButton.bounds;
        UIImage *normalBgImage = nil;
        UIImage *hlBgImage = [TPDialerResourceManager getImageByColorName:@"tp_color_grey_50" withFrame:imageBounds];
        _imageButton.layer.cornerRadius = (commonWidth) / 2;
        _imageButton.clipsToBounds = YES;
        _imageButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
        _imageButton.layer.borderWidth = 0.5;
        [_imageButton setBackgroundImage:normalBgImage forState:UIControlStateNormal];
        [_imageButton setBackgroundImage:hlBgImage forState:UIControlStateHighlighted];

        UIImage *image = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:info.imageName];
        _imageButton.contentMode = UIViewContentModeCenter;
        [_imageButton setImage:image forState:UIControlStateNormal];

        gY += _imageButton.frame.size.height;

        gY += 8;
        UILabel *mainTitleLabel = [[UILabel alloc] initWithTitle:info.mainTitle fontSize:16];
        mainTitleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        mainTitleLabel.frame = CGRectMake(0, gY, commonWidth, 23);
        gY += mainTitleLabel.frame.size.height;

        UILabel *altTitleLabel = [[UILabel alloc] initWithTitle:info.altTitle fontSize:12];
        altTitleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        altTitleLabel.frame = CGRectMake(0, gY, commonWidth, 17);
        gY += altTitleLabel.frame.size.height;

        [self addSubview:_imageButton];
        [self addSubview:mainTitleLabel];
        [self addSubview:altTitleLabel];

        self.frame = CGRectMake(0, 0, commonWidth, gY);
    }
    return self;
}

@end
/* end: TransferDirectionView */
