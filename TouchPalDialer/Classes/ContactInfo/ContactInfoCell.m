//
//  ContactInfoCell.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/22.
//
//

#import "ContactInfoCell.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "ScrollViewButton.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import "AllViewController.h"
#import "PhoneNumber.h"
@interface ContactInfoCell(){
    ContactInfoCellModel *_model;
    
    UILabel *_mainLabel;
    UILabel *_subLabel;
    
    ScrollViewButton *_rightButton;
    UILabel *_rightMiddleIcon;
    
    UIView *_bottomLine;
    UIImageView *_invitingImageView;
}

@end

@implementation ContactInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
             ContactInfoCellModel:(ContactInfoCellModel *)model
                     personId:(NSInteger)personId{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self ){
        _model = model;
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        UIView *view_bg = [[UIView alloc]initWithFrame:self.frame];
        view_bg.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"];
        self.selectedBackgroundView = view_bg;
        
        _mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 12, TPScreenWidth()-32, 20)];
        _mainLabel.backgroundColor = [UIColor clearColor];
        _mainLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        _mainLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:17];
        _mainLabel.numberOfLines = 0;
        _mainLabel.text = model.mainStr;
        [self addSubview:_mainLabel];
        
        _subLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 40, TPScreenWidth()-32, 14)];
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        _subLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        _subLabel.text = model.subStr;
        [self addSubview:_subLabel];
        
        UIColor *buttonColor = [FunctionUtility getBgColorOfLongPressView];
        
        _rightButton = [[ScrollViewButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 60, 0, 60, 66)];
        _rightButton.highlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"];
        _rightButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
        [_rightButton setTitleColor:buttonColor forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(onCellRightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightButton];
        
        _rightMiddleIcon = [[UILabel alloc]initWithFrame:CGRectMake(TPScreenWidth() - 120, 0, 60, 66)];
        _rightMiddleIcon.backgroundColor = [UIColor clearColor];
        _rightMiddleIcon.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
        _rightMiddleIcon.textAlignment = NSTextAlignmentCenter;
        _rightMiddleIcon.textColor = buttonColor;
        [self addSubview:_rightMiddleIcon];
        
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(16 , 63.5, TPScreenWidth()-16, 0.5)];
        _bottomLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_150"];
        [self addSubview:_bottomLine];
        
        [self showButton];
        [self adjustHeight];
    }
    
    return self;
}

- (void)showBottomLine{
    _bottomLine.hidden = NO;
}

- (void)hideBottomLine{
    _bottomLine.hidden = YES;
}

- (void)adjustHeight{
    CGSize mainSize = [_model.mainStr sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:17]
                                 constrainedToSize:CGSizeMake(TPScreenWidth()-32, 100)];
    NSInteger mainLabelHeight = ceil(mainSize.height) > 20? ceil(mainSize.height) : 20;
    CGFloat cellHeight = mainLabelHeight + 46 > 66 ? mainLabelHeight + 48 : 66;
    switch (_model.cellType) {
        case CellPhone:
        case CellInviting:
        {
            _mainLabel.frame = CGRectMake(16, 12, TPScreenWidth()-152, mainLabelHeight);
            _subLabel.frame = CGRectMake(16, cellHeight - 26, TPScreenWidth()-152, 14);
            break;
        }
        case CellFaceTime:
        
        {
            _mainLabel.frame = CGRectMake(16, 24, TPScreenWidth()-152, mainLabelHeight);
            break;
        }
        default: {
            _mainLabel.frame = CGRectMake(16, 12, TPScreenWidth()-32, mainLabelHeight);
            _subLabel.frame = CGRectMake(16, cellHeight - 26, TPScreenWidth()-32, 14);
            break;
        }
    }
    _bottomLine.frame = CGRectMake(16 , cellHeight - 2.5, TPScreenWidth()-16, 0.5);
}

- (void)showButton{
    _rightButton.hidden = YES;
    _rightButton.userInteractionEnabled = YES;
    _rightMiddleIcon.hidden = YES;
    _invitingImageView.hidden = YES;
    _rightButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    _rightMiddleIcon.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    _rightMiddleIcon.textColor = [FunctionUtility getBgColorOfLongPressView];

    [_rightButton setImage:nil forState:UIControlStateNormal];
    if ( _model.cellType == CellFaceTime ){
        [_rightButton setTitle:@"k" forState:UIControlStateNormal];
        _rightButton.hidden = NO;
        _rightButton.userInteractionEnabled = NO;
    }else if ( _model.cellType == CellPhone ){
        [_rightButton setTitle:@"i" forState:UIControlStateNormal];
        if ([FunctionUtility CheckIfExistInBindSuccessListarrayWithPhone:_mainLabel.text]) {
            _rightMiddleIcon.font = [UIFont fontWithName:@"iPhoneIcon1" size:24];
            _rightMiddleIcon.text = @"t";
            _rightMiddleIcon.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"0xfc5c8d"];
            _mainLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"0xfc5c8d"];
        } else {
            _rightMiddleIcon.text = @"z";
            _mainLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
            _rightMiddleIcon.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
            _rightMiddleIcon.textColor = [FunctionUtility getBgColorOfLongPressView];
        }
        _rightButton.hidden = NO;
        _rightMiddleIcon.hidden = NO;
    } else if (_model.cellType == CellInviting) {
        _rightButton.hidden = NO;
        _rightButton.userInteractionEnabled = NO;
        UIImage *invitingIcon = [TPDialerResourceManager getImage:@"cell-inviting-icon@2x.png"];
        [_rightButton setTitle:nil forState:UIControlStateNormal];
        [_rightButton setImage:invitingIcon forState:UIControlStateNormal];
        if (![UserDefaultsManager boolValueForKey:INVITING_IN_CONTACT_SUCCEED defaultValue:NO]) {
            _rightButton.hidden = NO;
        } else {
            _rightButton.hidden = NO;

            }
        }
    
}


- (void)refreshView:(ContactInfoCellModel *)model{
    _model = model;
    _mainLabel.text = model.mainStr;
    _subLabel.text = model.subStr;
    [self showButton];
    [self adjustHeight];
}

- (void)onCellRightButtonPressed{
    [_delegate onCellRightButtonPressed:_model];
    [_rightButton clearHighlightState];
}


@end
