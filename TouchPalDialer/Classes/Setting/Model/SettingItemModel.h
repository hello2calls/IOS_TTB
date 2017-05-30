//
//  SettingItemModel.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import <Foundation/Foundation.h>
#import "FeatureTipModel.h"

typedef enum {
    Type_none,
    Type_dot,
    Type_new,
    Type_num,
}hintType;

@interface SettingItemModel : NSObject

@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, copy) NSString* monitorKey;
@property (nonatomic, assign) int hintType;
@property (nonatomic, assign) int hintCount;
@property (nonatomic, retain) FeatureTipModel* featureTip;

@end
