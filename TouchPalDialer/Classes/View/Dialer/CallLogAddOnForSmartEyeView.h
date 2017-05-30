//
//  CallLogAddOnForSmartEyeView.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 9/24/12.
//
//

#import <UIKit/UIKit.h>
#import "UIView+WithSkin.h"
#import "HighLightLabel.h"

@interface CallLogAddOnForSmartEyeView : UIView <SelfSkinChangeProtocol>{
    UILabel *callerTypeLabel_;
    HighLightLabel *attrLabel_;
    //UIImageView *smartEyeView_;
}
@property (nonatomic,retain) NSString *callerType;
@property (nonatomic,retain) NSString *attr;
@property (nonatomic,readonly) HighLightLabel *attrLabel_;

@end
