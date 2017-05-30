//
//  QRContentView.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/21.
//
//

#import "QRContentView.h"
#import "ContactTransferConst.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "ContactTransferUtil.h"
#import "UILabel+TPHelper.h"
#import "UILabel+DynamicHeight.h"

@implementation QRContentView {
    CGRect _qrWindowFrame;
    UIButton *_refreshButton;
    CGRect _frame;
    CGFloat _lineHeight;
    UIView *_errorView;
    UIImageView *_qrImageView;
}

- (instancetype) initWithFrame:(CGRect)frame status:(NSInteger)currentStatus {
    if (self = [super initWithFrame:frame]) {
        _status = currentStatus;
        _frame = frame;
        _lineHeight = 20;

        self.frame = _frame;

        _qrWindowFrame = [self getQRWindowFrame];
        UIImageView *qrWindow = [self getImageViewByName:@"contact_transfer_qr_code_bg@2x.png"
                                                   frame:_qrWindowFrame];
        qrWindow.backgroundColor = [UIColor clearColor];

        [self refreshQRImage];

        CGFloat insetOfRefreshButton = (QR_WINDOW_WIDTH - QR_REFRESH_BUTTON_WIDH) / 2;
        _refreshButton = [self getRefreshButton:CGRectInset(_qrWindowFrame, insetOfRefreshButton, insetOfRefreshButton)];
        [_refreshButton addTarget:self.delegate action:@selector(onClickQRImage) forControlEvents:UIControlEventTouchUpInside];

        _errorView = [self getErrorView];

        [self addSubview:qrWindow];
        [self addSubview:_qrImageView];
        [self addSubview:_refreshButton];
        [self addSubview:_errorView];
    }
    return self;
}

- (void) refreshQRImage {
    UIImage *qrImage = [FunctionUtility getQRImageFromString:[ContactTransferUtil getQRString] withSize:CGSizeMake(QR_IMAGE_WIDTH, QR_IMAGE_WIDTH)];
    if (_qrImageView == nil) {
        CGFloat insetOfQRImage = (QR_WINDOW_WIDTH - QR_IMAGE_WIDTH) / 2;
        _qrImageView = [self getImageViewByImage:qrImage frame:CGRectInset(_qrWindowFrame, insetOfQRImage, insetOfQRImage)];
    } else if (qrImage) {
        _qrImageView.image = qrImage;
        _qrImageView.alpha = 0.8;
    }
}

- (BOOL) isGeneratingError {
    return !_qrImageView || (!_qrImageView.image);
}

- (void) setStatus:(NSInteger)status {
    _status = status;

    // update the views
    [_errorView removeFromSuperview];
    _errorView = [self getErrorView];
    [self addSubview:_errorView];

    switch (_status) {
        case STATUS_GENERATE_QRCODE_FAILED:
        case STATUS_OPPOSITE_FINISHED:
        case STATUS_SELF_FINISHED: {
            // failed
            _qrImageView.alpha = 0.1;
            _refreshButton.hidden = NO;
            break;
        }
        default: {
            // try to send
            _qrImageView.alpha = 0.8;
            _refreshButton.hidden = YES;
            break;
        }
    }
    //
}

- (CGRect) getQRWindowFrame {
    CGFloat gX = (TPScreenWidth() - QR_WINDOW_WIDTH) / 2;
    CGFloat gY = 110;
    CGRect frame = CGRectMake(gX, gY, QR_WINDOW_WIDTH, QR_WINDOW_WIDTH);
    return frame;
}

- (UIImageView *) getImageViewByImage:(UIImage *)image frame:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleToFill;
    if (!CGRectIsNull(frame)) {
        imageView.frame = frame;
    }
    return imageView;
}

- (UIImageView *) getImageViewByName:(NSString *)imageName frame:(CGRect)frame {
    UIImage *image = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:imageName];
    return [self getImageViewByImage:image frame:frame];
}

- (UIButton *) getRefreshButton:(CGRect) frame {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    UIImage *normalBgImage = [TPDialerResourceManager getImageByColorName:@"0x3303a9f4" withFrame:button.bounds];
    UIImage *hlBgImage = [TPDialerResourceManager getImageByColorName:@"tp_color_light_blue_500" withFrame:button.bounds];

    [button setBackgroundImage:normalBgImage forState:UIControlStateNormal];
    [button setBackgroundImage:hlBgImage forState:UIControlStateHighlighted];

    button.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:36];
    [button setTitle:@"J" forState:UIControlStateNormal];

    button.clipsToBounds = YES;
    button.backgroundColor = [UIColor clearColor];
    button.layer.cornerRadius = button.bounds.size.width / 2;

    button.hidden = YES;

    return button;
}

- (UIView *) getErrorView {
    CGFloat gX = 0;
    CGFloat gY = 0;
    UIView *container = [[UIView alloc] initWithFrame:CGRectZero];

    NSString *firstLineText = nil;
    NSString *leftText = nil;
    NSString *clickableText = nil;
    NSString *rightText = nil;

    switch (_status) {
        case STATUS_SEND_CONNECTION: {
            firstLineText = @"请在新手机上选择\"接收\"";
            leftText = @"并扫描上方的二维码";
            break;
        }
        case STATUS_GENERATE_QRCODE_FAILED:
        default: {
            firstLineText = @"连接失败，请检查网络连接后";
            if (_status == STATUS_GENERATE_QRCODE_FAILED) {
                firstLineText = @"二维码生成失败";
            }
            clickableText = @"刷新重试";
            break;
        }
    }

    UILabel *firstLine = nil;
    UILabel *leftLabel = nil;
    UILabel *clickLabel = nil;
    UILabel *rightLabel = nil;

    UIColor *greyColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
    if (firstLineText) {
        firstLine = [[UILabel alloc] initWithTitle:firstLineText fontSize:14];
        firstLine.textColor = greyColor;
        [firstLine adjustSizeByFillContent];
        //    gX = (TPScreenWidth() - firstLine.frame.size.width) / 2;
        [self adjustForLineHeight:firstLine];
        gY += firstLine.frame.origin.y * 2 + firstLine.frame.size.height;
    }

    if (leftText) {
        leftLabel = [[UILabel alloc] initWithTitle:leftText fontSize:14];
        [leftLabel adjustSizeByFillContent];
        leftLabel.textColor = greyColor;
    }

    if (clickableText) {
        clickLabel = [[UILabel alloc] initWithTitle:clickableText fontSize:14];
        clickLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        clickLabel.highlightedTextColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_700"];
        clickLabel.userInteractionEnabled = YES;
        [clickLabel adjustSizeByFillContent];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(onClickQRImage)];
        [clickLabel addGestureRecognizer:tapRecognizer];
    }

    if (rightText) {
        rightLabel = [[UILabel alloc] initWithTitle:rightText fontSize:14];
        [rightLabel adjustSizeByFillContent];
        rightLabel.textColor = greyColor;
    }


    CGFloat totalWidth = leftLabel.frame.size.width + clickLabel.frame.size.width + rightLabel.frame.size.width;
    if (firstLine) {
        [container addSubview:firstLine];
    }
    gX = (TPScreenWidth() - totalWidth) / 2;
    if (leftLabel) {
        [self adjustForLineHeight:leftLabel x:gX y:gY];
        gX += leftLabel.frame.size.width;
        [container addSubview:leftLabel];
    }
    if (clickLabel) {
        [self adjustForLineHeight:clickLabel x:gX y:gY];
        gX += clickLabel.frame.size.width;
        [container addSubview:clickLabel];
    }
    if (rightLabel) {
        [self adjustForLineHeight:rightLabel x:gX y:gY];
        gX += rightLabel.frame.size.width;
        [container addSubview:rightLabel];
    }
    gY += _lineHeight;

    CGRect oldFrame = container.frame;
    container.frame = CGRectMake(oldFrame.origin.x, _qrWindowFrame.origin.y + QR_WINDOW_WIDTH + 20, TPScreenWidth(), gY);
    return container;
}

- (void) adjustForLineHeight:(UIView *)view{
    if (!view) {
        return;
    }
    CGRect frame = view.frame;
    [self adjustForLineHeight:view x:(TPScreenWidth() - frame.size.width) / 2
                            y:(_lineHeight - frame.size.height)];
}

- (void) adjustForLineHeight:(UIView *)view x:(CGFloat)newX  y:(CGFloat)newY{
    if (!view) {
        return;
    }
    CGRect frame = view.frame;
    view.frame = CGRectMake(newX, newY, frame.size.width, frame.size.height);
}

@end
