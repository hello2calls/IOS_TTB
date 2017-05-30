//
//  AntiharassmentViewController_iOS10.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/18.
//
//

#import "CootekViewController.h"
#import "CACustomTextLayer.h"
#import "YYCycleViewCell.h"



typedef enum : NSUInteger {
    ANTIHARASS_SWITCHOFF_VERSIONNULL_NOUPDATE=0,
    ANTIHARASS_SWITCHON_VERSIONNULL_NOUPDATE=1,
    ANTIHARASS_SWITCHOFF_VERSION_NOUPDATE=2,
    ANTIHARASS_SWITCHON_VERSION_NOUPDATE=3,
    
    ANTIHARASS_SWITCHOFF_VERSIONNULL_UPDATE=4,
    ANTIHARASS_SWITCHON_VERSIONNULL_UPDATE=5,
    ANTIHARASS_SWITCHOFF_VERSION_UPDATE=6,
    ANTIHARASS_SWITCHON_VERSION_UPDATE=7,
} ANTIHARASSTATUS;

@interface AntiharassmentViewController_iOS10 : CootekViewController<UIAlertViewDelegate>
+ (NSInteger)getStatus;
@property (nonatomic,assign)BOOL notCheckDBVersion;
@end
