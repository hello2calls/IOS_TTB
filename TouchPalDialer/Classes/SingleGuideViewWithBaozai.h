//
//  SingleGuideViewWithBaozai.h
//  TouchPalDialer
//
//  Created by wen on 16/1/6.
//
//

#import "GuideViewWithBaozai.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultKeys.h"
#import "DialogUtil.h"
typedef NS_ENUM(NSInteger,GUIDETYPE){
    
    TOUCHOAL_FRIEND=1,
//    ADDRESS_TRANSFOR=2,
    
    ACTIVITY=3,
    INVITE_FRIEND=4,
    SKIN=5,
    ANTIHARASS=6,
    VOIP=7,
    MAXGUIDETYPE=8
};

@interface SingleGuideViewWithBaozai : GuideViewWithBaozai

-(instancetype)initWithGuideType:(GUIDETYPE)type image1:(UIImage *)image1 frame:(CGRect)frame;
@end
