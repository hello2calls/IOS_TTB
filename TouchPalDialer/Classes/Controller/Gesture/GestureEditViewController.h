//
//  GestureEditViewController.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GestureInputView.h"
#import "GestureModel.h"
#import "TPHeaderButton.h"
#import "GestureUtility.h"
#import "SelectModel.h"
#import "ContactCacheDataModel.h"

@interface GestureEditViewController : UIViewController<GestureInputDelegate,UIAlertViewDelegate>

@property(nonatomic,assign)BOOL signedContact;
@property(nonatomic,assign)BOOL shouldClearGesture;
@property(nonatomic,assign)BOOL isEditGesture;

- (id)init;
- (id)initWithGesturePic;
- (id)initWithGestureName : (NSString *) name;
@end
