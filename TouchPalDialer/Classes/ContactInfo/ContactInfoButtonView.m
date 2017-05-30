//
//  ContactInfoMainButtonView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/20.
//
//

#import "ContactInfoButtonView.h"
#import "TPDialerResourceManager.h"
#import "Favorites.h"
#import "FunctionUtility.h"

@implementation ContactInfoButtonView
- (instancetype)initWithFrame:(CGRect)frame andInfoModel:(ContactInfoModel *)infoModel{
    self = [super initWithFrame:frame];
    
    if ( self ){
        self.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_50"];
        [self generateButton:infoModel];
    }
    
    return self;
}

- (void)generateButton:(ContactInfoModel *)infoModel{
    NSArray *buttonArray = [self generateArray:infoModel];
    int buttonSize = [buttonArray count];
    for ( int i = 0 ; i < buttonSize ; i ++){
        
        ContactInfoButtonModel *info = [buttonArray objectAtIndex:i];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width*(i%buttonSize)/buttonSize, 0, self.frame.size.width/buttonSize, self.frame.size.height)];
        button.backgroundColor = [UIColor clearColor];
        button.tag = info.buttonTag;
        [button addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"] withFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)] forState:UIControlStateHighlighted];
        [self addSubview:button];
        
        UILabel *iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 8, button.frame.size.width, 24)];
        iconLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
        iconLabel.text = info.iconStr;
        iconLabel.textColor = [UIColor whiteColor];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.backgroundColor = [UIColor clearColor];
        [button addSubview:iconLabel];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, button.frame.size.width, 12)];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:11];
        titleLabel.text = info.titleStr;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        [button addSubview:titleLabel];
    }
}

- (NSArray *) generateArray:(ContactInfoModel *)infoModel{
    NSMutableArray *buttonArray = [NSMutableArray array];
    InfoType infoType = infoModel.infoType;
    if ( infoType == knownInfo ){
        ContactInfoButtonModel *info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"a";
        info.titleStr = NSLocalizedString(@"contact_info_call_log", "");
        info.buttonTag = knownCalllog;
        [buttonArray addObject:info];
        
        info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"d";
        info.titleStr = NSLocalizedString(@"detail_shortcut_gesture", "");
        info.buttonTag = knownGesture;
        [buttonArray addObject:info];
        
        info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"b";
        info.titleStr = NSLocalizedString(@"detail_shortcut_share", "");
        info.buttonTag = knownShare;
        [buttonArray addObject:info];
        
        info = [[ContactInfoButtonModel alloc]init];
        BOOL isFavorite = [Favorites isExistFavorite:infoModel.personId];
        if ( isFavorite ){
            info.iconStr = @"f";
            info.titleStr = NSLocalizedString(@"detail_shortcut_unfavor", "");
        }else{
            info.iconStr = @"e";
            info.titleStr = NSLocalizedString(@"detail_shortcut_favor", "");
        }
        info.buttonTag = knownStore;
        [buttonArray addObject:info];
    }else{
        ContactInfoButtonModel *info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"a";
        info.titleStr = NSLocalizedString(@"contact_info_call_log", "");
        info.buttonTag = unknownCallog;
        [buttonArray addObject:info];
        
        info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"c";
        info.titleStr = NSLocalizedString(@"Copy", "");
        info.buttonTag = unknownCopy;
        [buttonArray addObject:info];
        
        info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"b";
        info.titleStr = NSLocalizedString(@"Share", "");
        info.buttonTag = unknownShare;
        [buttonArray addObject:info];
    }
    return buttonArray;
}

- (void)refreshButtonView:(ContactInfoModel *)infoModel{
    for(UIView *view in [self subviews])
    {
        [view removeFromSuperview];
    }
    [self generateButton:infoModel];
}

- (void)onButtonPressed:(UIButton *)sender{
    [_delegate onButtonPressed:sender.tag];
}

@end
