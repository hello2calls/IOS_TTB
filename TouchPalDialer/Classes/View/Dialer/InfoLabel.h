//
//  InfoLabel.h
//  TouchPalDialer
//
//  Created by zhang Owen on 8/9/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InfoLabel : UIView {
	NSString *info;
}

@property(nonatomic, retain) NSString *info;

- (id)initInfoLabelWithFrame:(CGRect)frame withInfo:(NSString *)info_str;

@end
