//
//  CallViewController.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-12.
//
//

#import <UIKit/UIKit.h>
#import "PJSIPManager.h"

#define WEB_AD_READY_NOTI_TIME @"web_ad_ready_noti_time"

typedef enum{
    CallModeBackCall,
    CallModeIncomingCall,
    CallModeOutgoingCall,
    CallModeTestType 
}CallMode;


#define AD_PAGE_NORMAL @"ad_page_normal"
#define AD_PAGE_DEFAULT @"ad_page_default"
#define AD_PAGE_ERROR_CDOE @"ad_page_error_code"

@interface CallViewController : UIViewController <CallStateChangeDelegate>
+ (id)instanceWithNumberArr:(NSArray *)number andCallMode:(CallMode)callMode;
+ (id)instanceWithNumber:(NSString *)number andCallMode:(CallMode)callMode;
+ (id)instanceWithNumberArr:(NSArray *)number andCallMode:(CallMode)callMode requestAdUUId:(NSString *)uuid;
@end
