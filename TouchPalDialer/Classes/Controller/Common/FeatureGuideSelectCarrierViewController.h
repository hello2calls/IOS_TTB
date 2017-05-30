//
//  FeatureGuideSelectCountryViewController.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 8/30/12.
//
//

#import <UIKit/UIKit.h>
#import "CootekViewController.h"

@interface FeatureGuideSelectCarrierViewController : CootekViewController

@property(nonatomic,copy) void(^selectRowBlock)(id selectedData);
@end
