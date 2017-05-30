//
//  FeedsRedPackOpenPopUpView.h
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import <UIKit/UIKit.h>
#import "YPImageView.h"
#import "FindNewsBonusResult.h"

@interface FeedsRedPacketOpenPopUpView : YPUIView

@property(nonatomic, strong) YPImageView* closeView;
@property(nonatomic, strong) YPImageView* imageView;
- (instancetype) initWithContent:(NSString *)content andResult:(FindNewsBonusResult *)result;
- (void) closeSelf;

@end
