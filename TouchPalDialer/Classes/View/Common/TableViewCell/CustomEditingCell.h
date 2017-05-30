//
//  CustomEditingCell.h
//  TouchPalDialer
//
//  Created by Sendor on 11-8-31.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CootekTableViewCell.h"


@protocol CustomEditingCellProtocol

- (void)clickCell:(UITableViewCell*)cell;

@end


@interface CustomEditingCell : CootekTableViewCell {
    NSInteger cell_data;
}

@property(nonatomic, assign) id<CustomEditingCellProtocol> delegate;
@property(nonatomic) NSInteger cell_data;

@end
