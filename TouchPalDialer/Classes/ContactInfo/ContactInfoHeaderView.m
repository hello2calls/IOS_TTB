//
//  ContactInfoHeaderView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/24.
//
//

#import "ContactInfoHeaderView.h"
#import "TPDialerResourceManager.h"

@interface ContactInfoHeaderView(){
    UIButton *_headerButton;
}

@end

@implementation ContactInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame andInfoModel:(ContactInfoModel *)infoModel{
    self = [super initWithFrame:frame];
    
    if ( self ){
        self.backgroundColor = [UIColor clearColor];
        
        UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff(), 50, 45)];
        [leftButton setBackgroundImage:[TPDialerResourceManager getImage:@"white_navigation_back_icon@2x.png"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(onLeftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftButton];
        
        _headerButton = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 50, TPHeaderBarHeightDiff(), 50, 45)];
        [_headerButton setTitle:NSLocalizedString(@"Edit", "") forState:UIControlStateNormal];
        _headerButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        [_headerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_headerButton];
        [_headerButton addTarget:self action:@selector(onRightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        if ( infoModel.infoType == knownInfo )
            [_headerButton setTitle:NSLocalizedString(@"Edit", "") forState:UIControlStateNormal];
        else if ( infoModel.infoType == unknownInfo )
            [_headerButton setTitle:NSLocalizedString(@"Save", "") forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)onLeftButtonAction{
    [_delegate onLeftButtonAction];
}

- (void)onRightButtonAction{
    [_delegate onRightButtonAction];
}

- (void)refreshHeaderView:(ContactInfoModel *)infoModel{
    if ( infoModel.infoType == knownInfo )
        [_headerButton setTitle:NSLocalizedString(@"Edit", "") forState:UIControlStateNormal];
    else if ( infoModel.infoType == unknownInfo )
        [_headerButton setTitle:NSLocalizedString(@"Save", "") forState:UIControlStateNormal];
}

@end
