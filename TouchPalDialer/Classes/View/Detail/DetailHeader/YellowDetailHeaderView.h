//
//  YellowDetailHeaderView.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseDetailHeaderView.h"
#import "BigFaceSticker.h"

@interface YellowDetailHeaderView : BaseDetailHeaderView{
    BigFaceSticker *shopLogo;
    UILabel *signLabel;
}
-(void)willLoadData:(NSInteger)callerID;
-(void)didLoadData:(NSString *)sign logo:(UIImage *)logoIcon;
-(void)loadDefalutData:(NSString *)name;
@end
