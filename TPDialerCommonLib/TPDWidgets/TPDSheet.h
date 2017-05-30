//
//  TPDSheet.h
//  TouchPalDialer
//
//  Created by weyl on 16/11/28.
//
//

#import <UIKit/UIKit.h>

@interface TPDSheet : UIView

typedef NS_ENUM(NSInteger, UICallLogAction) {
    UICallLogActionPhoneCall,
    UICallLogActionSendSMS,
    UICallLogActionCopy,
    UICallLogActionCancel,
    UICallLogActionOthers,
};
+(UIView*)longPressSheet:(id)dataModel ClickAction:(void (^)(UICallLogAction action))clickAction;

+(UIView*)contactOperationSheet;
@end
