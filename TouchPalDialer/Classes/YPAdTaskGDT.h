//
//  YPAdTaskGDT.h
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "YPTaskBase.h"
#import "GDTNativeAd.h"

@interface YPAdTaskGDT : YPTaskBase<GDTNativeAdDelegate>

- (void) registerAd:(UIViewController *)controller withPlacementId:(NSString *)placementId;
@end
