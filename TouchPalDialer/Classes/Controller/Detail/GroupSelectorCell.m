//
//  GroupSelectorCell.m
//  TouchPalDialer
//
//  Created by zhang Owen on 12/5/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "GroupSelectorCell.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"

@implementation GroupSelectorCell
@synthesize selectorImageview;
@synthesize groupNameLabel;
@synthesize hightLight;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, TPScreenWidth() -75, 50)];
        groupNameLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_grey_800"];
        groupNameLabel.backgroundColor = [UIColor clearColor];
		groupNameLabel.font = [UIFont systemFontOfSize:16];
		[self addSubview:groupNameLabel];
		
		selectorImageview = [[UIImageView alloc] initWithFrame:CGRectMake(TPScreenWidth() -45 +7.5, 12.5, 25, 25)];
		[self addSubview:selectorImageview];
        UIView *backview = [[UIView alloc] initWithFrame:self.frame];
        backview.backgroundColor = [UIColor clearColor];
        self.backgroundView = backview;
        
        UIView *selectedView = [[UIView alloc] initWithFrame:self.frame];
        selectedView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_grey_400"];
        self.selectedBackgroundView = selectedView;
    }
    return self;
}

- (void)setSelectorImage:(BOOL)ifhigh {
	hightLight = ifhigh;
	
	UIImage *h_img = [[TPDialerResourceManager sharedManager] getImageByName:@"login_checked@2x.png"];
	UIImage *n_img = [[TPDialerResourceManager sharedManager] getImageByName:@"login_uncheck@2x.png"];
	
	if (hightLight) {
		self.selectorImageview.image = h_img;
	} else {
		self.selectorImageview.image = n_img;
	}
}


- (void)dealloc {
    [SkinHandler removeRecursively:self];
}


@end
