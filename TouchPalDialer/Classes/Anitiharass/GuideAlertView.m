//
//  GuideAlertView.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/30.
//
//

#import "GuideAlertView.h"
#import "FunctionUtility.h"

#define BGVIEW_MARGIN 30
#define CONTENT_PADDING 20
@interface GuideAlertView  ()

@property (nonatomic,weak) UILabel      *titleLabel;
@property (nonatomic,weak) UILabel      *messageLabel;
@property (nonatomic,weak) UIImageView  *guideImageView;
@property (nonatomic,weak) UIView       *maskView;
@property (nonatomic,weak) UIView       *backgroundView;
@property (nonatomic,weak) UIButton     *cancelButton;
@property (nonatomic,weak) UIButton     *confirmButton;
@end

@implementation GuideAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    
    UIView *maskView = [[UIView alloc] init];
    self.maskView = maskView;
    maskView.backgroundColor = CT_RGBA(0, 0, 0, 0.7);
    [self addSubview:maskView];
    
    UIView *backgroundView = [[UIView alloc] init];
    self.backgroundView = backgroundView;
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.layer.cornerRadius = 5;
    [self addSubview:backgroundView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = CT_RGBA(0, 0, 0, 0.9);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backgroundView addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    self.messageLabel = messageLabel;
    messageLabel.font = [UIFont systemFontOfSize:15];
    messageLabel.textColor = CT_RGBA(0, 0, 0, 0.8);
    messageLabel.numberOfLines = 0;
    [backgroundView addSubview:messageLabel];
    
    UIImageView *guideImageView = [[UIImageView alloc] init];
    self.guideImageView = guideImageView;
    guideImageView.contentMode = UIViewContentModeScaleAspectFit;
    [backgroundView addSubview:guideImageView];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton = confirmButton;
    UIImage *image = [FunctionUtility imageWithColor:CT_RGBA(3, 169, 244, 1) withFrame:CGRectMake(0, 0, 1, 1)];
    [confirmButton setBackgroundImage:image forState:UIControlStateNormal];
//    confirmButton.backgroundColor = CT_RGBA(3, 169, 244, 1);
    confirmButton.layer.cornerRadius = 5;
    confirmButton.layer.masksToBounds = YES;
    confirmButton.adjustsImageWhenHighlighted = YES;
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton setTitle:@"我知道了" forState:UIControlStateNormal];
    [backgroundView addSubview:confirmButton];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    self.cancelButton = cancelButton;
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setTitleColor:CT_RGBA(0, 0, 0, 0.5) forState:UIControlStateNormal];
    [cancelButton setTitle:@"F" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:16];
    [cancelButton addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:cancelButton];
    
    self.backgroundColor = [UIColor clearColor];
}

- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message guideImage:(nullable UIImage *)image {
    
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self buildUI];
        self.titleLabel.text = title;
        self.messageLabel.text = message;
        self.guideImageView.image = image;
    }
    return self;
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.maskView.frame = self.bounds;
    
    CGFloat backgroundW = self.tp_width - BGVIEW_MARGIN * 2;
    
    CGFloat cancelButtonW = 45;
    CGFloat cancelButtonH = 45;
    CGFloat cancelButtonX = backgroundW - cancelButtonW;
    CGFloat cancelButtonY = 0;
    self.cancelButton.frame = CGRectMake(cancelButtonX, cancelButtonY, cancelButtonW, cancelButtonH);
    
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = 30;
    CGFloat titleLabelW = backgroundW;
    CGFloat titleLabelH = 18;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    
    CGFloat messageLabelX = CONTENT_PADDING;
    CGFloat messageLabelY = CGRectGetMaxY(self.titleLabel.frame) + 31;
    CGFloat messageLabelW = backgroundW - 2 * CONTENT_PADDING;
    CGFloat messageLabelH = [self.messageLabel sizeThatFits:CGSizeMake(messageLabelW, CGFLOAT_MAX)].height;
    self.messageLabel.frame = CGRectMake(messageLabelX, messageLabelY, messageLabelW, messageLabelH);
    ;
    
    CGFloat guideImageViewX = CONTENT_PADDING;
    CGFloat guideImageViewY = CGRectGetMaxY(self.messageLabel.frame) + 18;
    CGFloat guideImageViewW = backgroundW - 2 * CONTENT_PADDING;
    CGFloat guideImageViewH = self.guideImageView.image.size.height * (guideImageViewW / self.guideImageView.image.size.width);
    self.guideImageView.frame = CGRectMake(guideImageViewX, guideImageViewY, guideImageViewW, guideImageViewH);

    CGFloat confirmButtonX = CONTENT_PADDING;
    CGFloat confirmButtonY = CGRectGetMaxY(self.guideImageView.frame) + 29;
    CGFloat confirmButtonW = backgroundW - 2 * CONTENT_PADDING;
    CGFloat confirmButtonH = 50;
    self.confirmButton.frame = CGRectMake(confirmButtonX, confirmButtonY, confirmButtonW, confirmButtonH);
    
    CGFloat backgroundH = CGRectGetMaxY(self.confirmButton.frame) + 20;
    CGFloat backgroundX = BGVIEW_MARGIN;
    CGFloat backgroundY = (self.tp_height - backgroundH) / 2;
    self.backgroundView.frame = CGRectMake(backgroundX, backgroundY, backgroundW, backgroundH);
}
@end
