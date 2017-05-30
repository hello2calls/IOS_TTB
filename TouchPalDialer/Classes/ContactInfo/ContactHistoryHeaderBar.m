//
//  ContactHistoryHeaderBar.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/23.
//
//

#import "ContactHistoryHeaderBar.h"
#import "TPDialerResourceManager.h"
#import "TPHeaderButton.h"
#import "FunctionUtility.h"

@interface ContactHistoryHeaderBar(){
    UIButton *_leftButton;
    UIButton *_rightButton;
    
    ContactHeaderMode _mode;
}

@end

@implementation ContactHistoryHeaderBar

- (instancetype)initWithFrame:(CGRect)frame andModel:(ContactInfoModel *)infoModel{
    self = [super initWithFrame:frame];
    
    if ( self ){
        _mode = ContactHeaderNormal;
        self.backgroundColor = [FunctionUtility getBgColorOfLongPressView];
        
        _leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff(), 50, 45)];
        [_leftButton setBackgroundImage:[TPDialerResourceManager getImage:@"white_navigation_back_icon@2x.png"] forState:UIControlStateNormal];
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_leftButton];
        [_leftButton addTarget:self action:@selector(headerLeftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 50, TPHeaderBarHeightDiff(), 50, 45)];
        [_rightButton setTitle:NSLocalizedString(@"Edit", "") forState:UIControlStateNormal];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_rightButton];
        [_rightButton addTarget:self action:@selector(headerRightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, TPHeaderBarHeightDiff(), self.frame.size.width - 100 , 45)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_3];
        headerLabel.text = infoModel.firstStr;
        [self addSubview:headerLabel];
    }
    
    return self;
}

- (void)refreshHeaderMode:(ContactHeaderMode)mode{
    _mode = mode;
    if ( mode == ContactHeaderNormal ){
        [_rightButton setTitle:NSLocalizedString(@"Edit", "") forState:UIControlStateNormal];
        _rightButton.hidden = NO;
        [_leftButton setBackgroundImage:[TPDialerResourceManager getImage:@"white_navigation_back_icon@2x.png"] forState:UIControlStateNormal];
        [_leftButton setTitle:@"" forState:UIControlStateNormal];
    }else if ( mode == ContactHeaderDelete ){
        [_rightButton setTitle:NSLocalizedString(@"Done", "") forState:UIControlStateNormal];
        _rightButton.hidden = NO;
        [_leftButton setBackgroundImage:nil forState:UIControlStateNormal];
        [_leftButton setTitle:NSLocalizedString(@"Delete", "") forState:UIControlStateNormal];
    }else if ( mode == ContactHeaderNo ){
        [_rightButton setTitle:NSLocalizedString(@"Edit", "") forState:UIControlStateNormal];
        _rightButton.hidden = YES;
        [_leftButton setBackgroundImage:[TPDialerResourceManager getImage:@"white_navigation_back_icon@2x.png"] forState:UIControlStateNormal];
        [_leftButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void) headerLeftButtonAction{
    [_delegate headerLeftButtonAction:_mode];
}

- (void) headerRightButtonAction{
    [_delegate headerRightButtonAction:_mode];
}
@end
