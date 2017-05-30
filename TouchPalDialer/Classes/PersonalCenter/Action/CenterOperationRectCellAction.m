//
//  CenterOperationRectCellAction.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/9/1.
//
//

#import "CenterOperationRectCellAction.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "TPTouchView.h"

@interface CenterOperationRectCellAction() <TPTouchViewDelegate>

@end

@implementation CenterOperationRectCellAction {
    UILabel *_indicator;
    UILabel *_title;
    UILabel *_desc;
    UILabel *_dotLabel;
    CGRect _area;
    UIView *_bgView;
    CenterOperateInfo *_model;
    UIColor *_highlightColor;
    BOOL _moved;
}

- (id)initWithHostView:(UIView *)view DisplayArea:(CGRect)frame operateInfo:(CenterOperateInfo *)info {
    self = [super init];
    if (self) {
        self.type = info.type;
        self.delegate = info.delegate;
        self.guidePointId = info.guidePointId;
        _area = frame;
        _model = info;
        
        TPTouchView *bgView = [[TPTouchView alloc] initWithFrame:frame];
        bgView.delegate = self;
        [view addSubview:bgView];
        _bgView = bgView;
        
        _highlightColor = [TPDialerResourceManager getColorForStyle:@"personal_center_setting_bg_color"];
        
        _dotLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [_bgView addSubview:_dotLabel];
        [self setContent];
    }
    return self;
}

- (void)setContent {
    [_title removeFromSuperview];
    [_desc removeFromSuperview];
    
    CGFloat titleSize = 24;
    UIFont *titleFont = [UIFont systemFontOfSize:titleSize];
    if (_model.iconTypeName.length > 0) {
        titleSize = 30;
        titleFont = [UIFont fontWithName:_model.iconTypeName size:titleSize];
    }
    CGFloat gap = 10;
    CGFloat descSize = 13;
    CGFloat titleX = 0;
    CGFloat titleY = (_area.size.height - (gap + descSize + titleSize))/2;
    _title = [FunctionUtility labelNoBgWithRect:CGRectMake(titleX, titleY, _area.size.width, titleSize) font:titleFont align:NSTextAlignmentCenter textColor:[TPDialerResourceManager getColorForStyle:_model.iconColor] andText:_model.iconText];
    [_bgView addSubview:_title];
    
    CGFloat descY = _title.frame.size.height + 10 + _title.frame.origin.y;
    _desc = [FunctionUtility labelNoBgWithRect:CGRectMake(0, descY, _area.size.width, descSize) font:[UIFont systemFontOfSize:descSize] align:NSTextAlignmentCenter textColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"] andText:_model.labelText];
    [_bgView addSubview:_desc];
    [self setDotType:_model.dotType withNum:0];
}

- (void)setDotType:(PointType)type withNum:(NSInteger)num{
    UILabel *dotLabel = _dotLabel;
    [self getInfo].dotType = type;
    if (_model.type == VOIP_INFO
        && type == PTHide
        &&![UserDefaultsManager boolValueForKey:have_show_voip_oversea_point defaultValue:NO]
        &&![UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]) {
            dotLabel.frame = CGRectMake(_area.size.width - 35 - 8, 8, 35, 14);
            NSString *text;
            UIColor *backColor;
            text = @"国际长途";
            backColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
            CGRect oldFrame =dotLabel.frame;
            dotLabel.font = [UIFont systemFontOfSize:10];
            oldFrame.size.width = [text sizeWithFont:dotLabel.font].width+10;
            oldFrame.origin.x =  oldFrame.origin.x -10;
            dotLabel.frame = oldFrame;
            dotLabel.text = text;
            dotLabel.textAlignment = NSTextAlignmentCenter;
            dotLabel.font = [UIFont systemFontOfSize:10];
            dotLabel.textColor = [UIColor whiteColor];
            dotLabel.backgroundColor = backColor;
            dotLabel.layer.masksToBounds = YES;
            dotLabel.layer.cornerRadius = 7;
        return;
    }
    if (_model.type == FREE_MINUTE_INFO
        &&[UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]
        &&[UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME ]==1
        )
    {
            if([UserDefaultsManager intValueForKey:have_join_wechat_public_status defaultValue:NO]==0) {
                NSString *text;
                UIColor *backColor;
                dotLabel.frame = CGRectMake(_area.size.width - 35, 8, 35, 14);
                text = @"+200";
                backColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
                CGRect oldFrame =dotLabel.frame;
                dotLabel.font = [UIFont systemFontOfSize:10];
                oldFrame.size.width = [text sizeWithFont:dotLabel.font].width+10;
                oldFrame.size.height = [text sizeWithFont:dotLabel.font].height+2;
                oldFrame.origin.x =  oldFrame.origin.x -10;
                dotLabel.frame = oldFrame;
                dotLabel.text = text;
                dotLabel.textAlignment = NSTextAlignmentCenter;
                dotLabel.font = [UIFont systemFontOfSize:10];
                dotLabel.textColor = [UIColor whiteColor];
                dotLabel.backgroundColor = backColor;
                dotLabel.layer.masksToBounds = YES;
                dotLabel.layer.cornerRadius = 7;
                dotLabel.hidden = NO;
            }else if([UserDefaultsManager intValueForKey:have_join_wechat_public_status defaultValue:NO]==1){
                dotLabel.hidden = YES;
            }
            return;
        
    }
    dotLabel.hidden = (type == PTHide || (type == PTNum && num == 0));
    if ( type == PTNew ){
        dotLabel.frame = CGRectMake(_area.size.width - 35 - 8, 8, 35, 14);
        dotLabel.text = @"NEW";
        dotLabel.textAlignment = NSTextAlignmentCenter;
        dotLabel.font = [UIFont systemFontOfSize:10];
        dotLabel.textColor = [UIColor whiteColor];
        dotLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        dotLabel.layer.masksToBounds = YES;
        dotLabel.layer.cornerRadius = 7;
    }else if ( type == PTDot ){
        dotLabel.frame = CGRectMake(_area.size.width - 13, 8, 10, 10);
        dotLabel.layer.masksToBounds = YES;
        dotLabel.layer.cornerRadius = 5.0f;
        dotLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        dotLabel.text = @"";
    } else if (type == PTNum && num > 0) {
        dotLabel.frame = CGRectMake(_area.size.width - 16-8, 8, 16, 16);
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
        dotLabel.frame = CGRectMake(_area.size.width - 35 - 8, 8, 35, 14);
        dotLabel.text = @"更新";
        dotLabel.textAlignment = NSTextAlignmentCenter;
        dotLabel.font = [UIFont systemFontOfSize:10];
        dotLabel.textColor = [UIColor whiteColor];
        dotLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        dotLabel.layer.masksToBounds = YES;
        dotLabel.layer.cornerRadius = 7;
    }
}

- (void)onPress {
    [self.delegate onOperatePress:_model.type];
}

- (void)clearHighlightStateAnimate {
    [UIView animateWithDuration:0.1 animations:^{
        [self clearHighlightState];
    } completion:^(BOOL finished) {
        [self onPress];
    }];
}

- (CenterOperateInfo *)getInfo {
    return _model;
}

- (void)clearHighlightState {
    [_bgView setBackgroundColor:[UIColor clearColor]];
}

- (void)tpTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_bgView setBackgroundColor:_highlightColor];
}

- (void)tpTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_moved) {
        _moved = NO;
        [self clearHighlightState];
        return;
    }
    [self clearHighlightStateAnimate];
}

- (void)tpTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _moved = YES;
}

@end
