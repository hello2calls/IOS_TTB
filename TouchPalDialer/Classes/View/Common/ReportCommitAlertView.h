//
//  ReportCommitAlertView.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialClient.h"

@interface ReportCommitAlertView : UIView<SnsLoginDelegate>
- (id)initWithFrame:(CGRect)frame message:(NSString *)message;
@end
