//
//  GestureModel.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GestureRecognizer.h"   

@interface GestureModel : NSObject{

    GestureRecognizer *mGestureRecognier;
}

@property(nonatomic,retain) GestureRecognizer *mGestureRecognier;
@property(nonatomic,copy) NSArray *pointArray;
@property(nonatomic,assign) BOOL isOpenSwitchGesture;
+ (GestureModel *)getShareInstance;
@end
