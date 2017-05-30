//
//  FeatureGuideModelGenerator.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/7/29.
//
//

#import <Foundation/Foundation.h>
#import "BaseHangupModelGenerator.h"

@interface FeatureGuideModelGenerator : BaseHangupModelGenerator
- (id)initWithHangupModel:(HangupModel *)model andIfFirstNormalHangup:(BOOL)isFirst;
- (id)initWithshowBackCallOrFeatureProviderHangupModel:(HangupModel *)model;

@end


@protocol FeatureGuideProtocol
@optional

- (NSString *)headerAltText;

- (UIImage *)guideBgImage;

- (UIImage *)guideIconImage;

- (NSString *)actionText;

- (void(^)(void))actionBlock;

- (NSString *)descriptText;

- (NSString *)descriptTextAlt;

@end

@interface DefaultProvider :NSObject <FeatureGuideProtocol>
@property (nonatomic, weak)FeatureGuideModelGenerator *manager;
@end

@interface VipCallProvider : DefaultProvider

@end

@interface ForeignUserProvider : DefaultProvider

@end

@interface FeatureNumberDisplay : DefaultProvider

@end

@interface FeatureInvitePerson : DefaultProvider

@end

@interface FeatureGuideSpit : DefaultProvider

@end

@interface CommercialGuide : DefaultProvider

@end