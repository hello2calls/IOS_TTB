//
//  CommonDataCell.h
//  TouchPalDialer
//
//  Created by Sendor on 11-9-21.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CootekTableViewCell.h"

@protocol CommonDataCellDelegate

- (void)checkChanged:(BOOL)isChecked mainData:(int)mainData subData:(int)subData;

@end

@interface CommonDataCell : CootekTableViewCell {
    id<CommonDataCellDelegate> __unsafe_unretained delegate;
    int main_data;
    int sub_data;
    BOOL is_checked;
    UIImage* unchecked_image;
    UIImage* checked_image;
    UIImageView *check_image_view;
    UILabel *textLabel_;
}

@property(nonatomic, assign) id<CommonDataCellDelegate> delegate;
@property(nonatomic, readonly) BOOL is_checked;
@property(nonatomic, retain) UIImage* unchecked_image;
@property(nonatomic, retain) UIImage* checked_image;
@property(nonatomic, retain) UIImageView* check_image_view;

- (id)initWithData:(int)mainData subData:(int)subData Image:(UIImage*)cellImage isChecked:(BOOL)isChecked style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setCellText:(NSString*)text;

@end
