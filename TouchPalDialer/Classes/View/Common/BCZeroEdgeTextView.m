//
//  BCZeroEdgeTextView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BCZeroEdgeTextView.h"

//
// BCTextView
//
// UITextView seems to automatically be resetting the contentInset
// bottom margin to 32.0f, causing strange scroll behavior in our small
// textView.  Maybe there is a setting for this, but it seems like odd behavior.
// override contentInset to always be zero.
//


@implementation BCZeroEdgeTextView

- (UIEdgeInsets) contentInset { return UIEdgeInsetsZero;}

@end
