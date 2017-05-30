//
//  centerDefaultOperateModel.m
//  TouchPalDialer
//
//  Created by game3108 on 15/5/12.
//
//

#import "UIView+WithSkin.h"
#import "CenterOperateCellAction.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "ScrollViewButton.h"

@interface CenterOperateCellAction(){
    ScrollViewButton *bgButton;
    UIView *bottomLine;
    UILabel *dotLabel;
    UILabel *iconLabel;
    UILabel *titleLabel;
    UILabel *subtitleLabel;
    NSString *_colorName;
    CenterOperateInfo *_info;
}

@end

@implementation CenterOperateCellAction

- (id)initWithHostView:(UIView *)view DisplayArea:(CGRect)frame operateInfo:(CenterOperateInfo *)info{
    self = [super init];
    
    if ( self ){
        _info = info;
        _type = info.type;
        _delegate = info.delegate;
        _guidePointId = info.guidePointId;
        _colorName = info.iconColor;
        
        bgButton = [[ScrollViewButton alloc]initWithFrame:frame];
        bgButton.highlightColor = [TPDialerResourceManager getColorForStyle:@"personal_center_setting_bg_color"];
        [bgButton addTarget:self action:@selector(onButtonPressAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:bgButton];
        
        if (!info.lastItem) {
            bottomLine = [[UIView alloc]initWithFrame:CGRectMake(48, frame.size.height - 0.5 , frame.size.width - 48, 0.5)];
            bottomLine.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_grey_150"];
            [bgButton addSubview:bottomLine];
        }
        
        iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, (frame.size.height-22)/2 , 25, 25)];
        iconLabel.font = [UIFont fontWithName:info.iconTypeName size:22];
        iconLabel.backgroundColor = [UIColor clearColor];
        iconLabel.text = info.iconText;
        if ( info.iconColor == nil || info.iconColor.length == 0)
            iconLabel.textColor = [UIColor blackColor];
        else
            iconLabel.textColor = [TPDialerResourceManager getColorForStyle:info.iconColor];
        [bgButton addSubview:iconLabel];
        
        CGSize titleSize = [info.labelText sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_3_5]];
        
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(48, (frame.size.height-FONT_SIZE_3_5)/2 -5, titleSize.width, FONT_SIZE_3_5+10)];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_3_5];
        titleLabel.text = info.labelText;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_grey_800"];
        [bgButton addSubview:titleLabel];
        
        dotLabel = [[UILabel alloc]initWithFrame:CGRectMake(bgButton.frame.size.width - 15, 5, 10, 10)];
        [bgButton addSubview:dotLabel];
        dotLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        UILabel *accessoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 15 - 18, 0, 18, frame.size.height)];
        accessoryLabel.text = @"n";
        accessoryLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:18];
        accessoryLabel.backgroundColor = [UIColor clearColor];
        accessoryLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
        accessoryLabel.textAlignment = NSTextAlignmentCenter;
        [bgButton addSubview:accessoryLabel];
        
        CGFloat rightHeight = 14;
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(accessoryLabel.frame.origin.x - 150 - 5, (frame.size.height - rightHeight)/2, 150, 15)];
        rightLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_4_5];
        rightLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        rightLabel.attributedText = info.rightAttrText;
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.backgroundColor = [UIColor clearColor];
        [bgButton addSubview:rightLabel];
        
        subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width * 0.25, 0, frame.size.width *0.75 - 15 - 28, frame.size.height)];
        subtitleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_4];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.textAlignment = NSTextAlignmentRight;
        subtitleLabel.text = info.labelSubText;
        if (info.subtitleHidden) {
            subtitleLabel.alpha = 0;
        }
        subtitleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"personal_center_func_alt_text_color"];
        [bgButton addSubview:subtitleLabel];
        
        [self setDotType:info.dotType withNum:0];
    }
    
    return self;
}

- (void)setOriginY:(CGFloat)y{
    CGRect oldFrame = bgButton.frame;
    bgButton.frame = CGRectMake(oldFrame.origin.x, y, oldFrame.size.width, oldFrame.size.height);
}

- (void)setBottomLineHidden:(BOOL)ifHidden{
    bottomLine.hidden = ifHidden;
}

- (void)setViewHidden:(BOOL)ifHidden{
    _ifHidden = ifHidden;
    bgButton.hidden = ifHidden;
}

- (void)onButtonPressAction{
    [_delegate onOperatePress:_type];
}

- (void)setDotType:(PointType)type withNum:(NSInteger)num{
    dotLabel.hidden = (type == PTHide || (type == PTNum && num == 0));
    CGRect oldFrame = dotLabel.frame;
    if ( type == PTNew ){
        dotLabel.frame = CGRectMake(bgButton.frame.size.width - 35 - 5, oldFrame.origin.y, 35, 14);
        dotLabel.text = @"NEW";
        dotLabel.textAlignment = NSTextAlignmentCenter;
        dotLabel.font = [UIFont systemFontOfSize:10];
        dotLabel.textColor = [UIColor whiteColor];
        dotLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        dotLabel.layer.masksToBounds = YES;
        dotLabel.layer.cornerRadius = 7;
    }else if ( type == PTDot ){
        dotLabel.layer.masksToBounds = YES;
        dotLabel.layer.cornerRadius = 5.0f;
        dotLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        dotLabel.text = @"";
    } else if (type == PTNum && num > 0) {
        dotLabel.frame = CGRectMake(bgButton.frame.size.width - 16 - 5, oldFrame.origin.y, 16, 16);
        dotLabel.layer.cornerRadius = 8;
        dotLabel.layer.masksToBounds = YES;
        dotLabel.textColor = [UIColor whiteColor];
        dotLabel.textAlignment = NSTextAlignmentCenter;
        dotLabel.text = [NSString stringWithFormat:@"%d", num];
        dotLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        dotLabel.layer.borderWidth = 0;
        if (num > 9) {
            dotLabel.font = [UIFont systemFontOfSize:10];
        } else if(num > 0){
            dotLabel.font = [UIFont systemFontOfSize:12];
        }
    } else if (type == PTUpdate) {
        dotLabel.frame = CGRectMake(bgButton.frame.size.width - 35 - 5, oldFrame.origin.y, 35, 14);
        dotLabel.text = @"更新";
        dotLabel.textAlignment = NSTextAlignmentCenter;
        dotLabel.font = [UIFont systemFontOfSize:10];
        dotLabel.textColor = [UIColor whiteColor];
        dotLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        dotLabel.layer.masksToBounds = YES;
        dotLabel.layer.cornerRadius = 7;
    }
    _info.dotType = type;
}

- (void)setTitle:(NSString *)title{
    CGSize titleSize = [title sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_3]];
    CGRect titleFrame = titleLabel.frame;
    titleFrame.size.width = titleSize.width;
    titleLabel.frame = titleFrame;
    CGRect dotFrame = dotLabel.frame;
    dotFrame.origin.x = titleSize.width + 14;
    dotLabel.frame = dotFrame;
    titleLabel.text = title;
}

- (void)setSubTitle:(NSString *)subtitle {
    subtitleLabel.text = subtitle;
}

- (void)setSubTitleAlpha:(CGFloat)alpha {
    subtitleLabel.alpha = alpha;
}


- (void)setContent {

}

- (void)clearHighlightState {
    [bgButton clearHighlightState];
}

- (CenterOperateInfo *)getInfo {
    return _info;
}

@end
