//
//  CommonDataCell.m
//  TouchPalDialer
//
//  Created by Sendor on 11-9-21.
//  Refactored by Chen Lu on 12-9-7.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "CommonDataCell.h"
#import "TPDialerResourceManager.h"

@implementation CommonDataCell

@synthesize delegate;
@synthesize is_checked;
@synthesize unchecked_image;
@synthesize checked_image;
@synthesize check_image_view;

- (id)initWithData:(int)mainData subData:(int)subData Image:(UIImage*)cellImage isChecked:(BOOL)isChecked style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        main_data = mainData;
        sub_data = subData;
        is_checked = isChecked;
        
        self.imageView.image = cellImage;
        self.unchecked_image = [[TPDialerResourceManager sharedManager] getImageByName:@"login_uncheck@2x.png"];
        self.checked_image = [[TPDialerResourceManager sharedManager] getImageByName:@"login_checked@2x.png"];
        UIImageView *checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(TPScreenWidth()-45 + 7.5, 12.5, 25, 25)];
        
        if (is_checked) {
            checkImageView.image = checked_image;
        } else {
            checkImageView.image = unchecked_image;
        }
        [self addSubview:checkImageView];
        self.check_image_view = checkImageView;
        
        textLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, TPScreenWidth()-60, 50)];
        textLabel_.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"defaultCellMainText_color"];
        textLabel_.backgroundColor = [UIColor clearColor];
        textLabel_.font = [UIFont systemFontOfSize:16];
        [self addSubview:textLabel_];
    }
    return self;
}

- (void)setCellText:(NSString *)text
{
    textLabel_.text = text;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	is_checked = !is_checked;
	if (is_checked) {
        self.check_image_view.image = checked_image;
    } else {
		self.check_image_view.image = unchecked_image;
	}
    [delegate checkChanged:is_checked mainData:main_data subData:sub_data];
}


@end
