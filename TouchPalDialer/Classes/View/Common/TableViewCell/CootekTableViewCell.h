//
//  CootekTableViewCell.h
//  TouchPalDialer
//
//  Created by zhang Owen on 12/16/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedCellBackGroundView.h"

@interface CootekTableViewCell : UITableViewCell  {

}
@property (nonatomic,assign)RoundedCellBackgroundViewPosition cellPosition;
@property (nonatomic) UILabel *bottomLine;
@property (nonatomic,weak) UILabel *checkMarkLabel;

- (void)onShowSmsCell;
- (void)onShowAddContact;
- (void)onShowAddToExistingContact;
- (void)onShowAddShop;
- (void)onShowString:(NSString *)string;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellPosition:(RoundedCellBackgroundViewPosition)position;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier useDefaultSelectedBackgroundColor:(BOOL)useDefaultColor;
- (void)addCutomTextLabelWithText:(NSString *)text image:(UIImage *)icon textColor:(UIColor *)textColor;
- (void)setBottomlineIfHidden:(BOOL)ifHidden;
- (void)refreshSeparateLineColor:(UIColor *)color;
-(void)switchWithADDEXTERCELLTYPE:(NSUInteger)exterType NormalCellType:(NSUInteger)type;
@end
