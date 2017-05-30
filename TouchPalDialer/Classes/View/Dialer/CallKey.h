//
//  CallKey.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperKey.h"
#define CALL_KEY_ICON @"callKeyIcon"
#define CALL_KEY_BACK @"CallKeyBackgroundImage"
#define CALL_KEY_BACK_H @"CallKeyBackgroundImage_ht"

@interface CallKey : SuperKey {
	NSString *local_str;
    UIImage *callIcon;
}

@property(nonatomic, retain) NSString *local_str;
@property(nonatomic, retain) UIImage *callIcon;
@property(nonatomic, retain) UIColor *callkeyTextColor;
- (id)initCallKeyWithFrame:(CGRect)frame;
@end
