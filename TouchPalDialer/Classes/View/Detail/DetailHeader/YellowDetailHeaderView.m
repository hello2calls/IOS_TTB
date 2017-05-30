//
//  YellowDetailHeaderView.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YellowDetailHeaderView.h"
#import "TPDialerResourceManager.h"

@implementation YellowDetailHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //logo
		shopLogo = [[BigFaceSticker alloc] initWithFrame:CGRectMake(8, 8, 50, 50)];
		[self addSubview:shopLogo];
		[shopLogo release];
        //signnature
        signLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 200, 25)];
        signLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"jotTitle_textColor"]];
        signLabel.font = [UIFont boldSystemFontOfSize:CELL_FONT_SMALL];
        signLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:signLabel];
        [signLabel release];
        //
        namelabel.frame = CGRectMake(70, 8, 250, 25);
    }
    return self;
}

-(void)loadDefalutData:(NSString *)name{
    namelabel.frame = CGRectMake(10, 10, 300, 50);
    namelabel.text = name;
}
-(void)willLoadData:(NSInteger)callerID{
    namelabel.frame = CGRectMake(10, 0, 300, 50);
    namelabel.text =[NSString stringWithFormat: @"肯德基_%d",callerID];
}
-(void)didLoadData:(NSString *)sign logo:(UIImage *)logoIcon{
    if (logoIcon) {
        namelabel.frame = CGRectMake(70, 8, 250, 25);
        signLabel.frame = CGRectMake(70, 35, 200, 25);
        shopLogo.m_photo = logoIcon;
        [shopLogo setNeedsDisplay];
    }
    signLabel.text = sign;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
