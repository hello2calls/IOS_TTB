//
//  GroupSelectorCell.h
//  TouchPalDialer
//
//  Created by zhang Owen on 12/5/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CootekTableViewCell.h"


@interface GroupSelectorCell : CootekTableViewCell {
	UIImageView *selectorImageview;
	UILabel *groupNameLabel;
	BOOL hightLight;
}

@property(nonatomic, retain) UIImageView *selectorImageview;
@property(nonatomic, retain) UILabel *groupNameLabel;
@property(nonatomic) BOOL hightLight;

- (void)setSelectorImage:(BOOL)ifhigh;

@end
