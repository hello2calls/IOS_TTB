//
//  CustomEditingCell.m
//  TouchPalDialer
//
//  Created by Sendor on 11-8-31.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "CustomEditingCell.h"


@implementation CustomEditingCell

@synthesize delegate;
@synthesize cell_data;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate clickCell:self];
}


@end
