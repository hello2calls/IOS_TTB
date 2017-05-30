//
//  FeedsRedPackPopUpView.h
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import <Foundation/Foundation.h>
#import "YPUIView.h"
#import "YPImageView.h"

@interface FeedsRedPacketShowPopUpView : YPUIView

@property(nonatomic, strong) YPImageView* closeView;
@property(nonatomic, strong) YPImageView* imageView;
- (instancetype) initWithContent:(NSString *)content1 content2:(NSString *)content2;
- (void) drawContent:(NSString *) content1 content2:(NSString *)content2;
- (void) closeSelf;
@end
