//
//  SelectController.h
//  TouchPalDialer
//
//  Created by game3108 on 16/4/12.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SelectType){
    SelectTypeALL         = 0,
    SelectTypeMOBILE      = 1,
    SelectTypeCOOTEKER    = 2
};

@interface SelectController : NSObject

+ (instancetype) sharedInstance;
- (void) pushSelectViewControllerBySelectType:(SelectType)type andIfSingle:(Boolean)ifSingle andResultBlock:(void(^)(id))resultBlock;


@end
