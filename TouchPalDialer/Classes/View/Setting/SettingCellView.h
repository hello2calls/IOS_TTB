//
//  SettingCellView.h
//  TouchPalDialer
//
//  Created by Ailce on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CootekTableViewCell.h"
#import "UITableView+TP.h"

#define N_HIDE_KEYBOARD_TEXTFIELD   @"N_HIDE_KEYBOARD_TEXTFIELD"
#define N_SHOW_KEYBOARD_TEXTFIELD   @"N_SHOW_KEYBOARD_TEXTFIELD" 

typedef enum {
    Default_Cell,
    SwitchCellType,
    TextFieldTypeCell,
    OperationButtonTypeCell,
    CheckButtonTypeCell,
}SettingCellType;

@protocol SettingCellDelegate <NSObject>
@optional
- (void)changeSwitch:(BOOL)is_on  withKey:(NSString *)key;
- (void)textDidEndEditing:(NSString *)text withKey:(NSString *)key;
- (void)textChanged:(NSString *)text withKey:(NSString *)key;
- (void)touchOperationButton:(NSString *)cellKey;
- (void)touchCheckButton:(BOOL)checked withKey:(NSString *)cellKey;
@end

@interface SettingCellView : CootekTableViewCell<UITextFieldDelegate>{
    UILabel *textLabel;
    UILabel *detailTextLabel;
    UITextField *rightTextField;
    UISwitch *rightSwitch;
    id<SettingCellDelegate> __unsafe_unretained delegate;
    NSString *cellKey;
}

@property(nonatomic,retain)NSString *cellKey;;
@property(nonatomic,retain)UILabel *textLabel;
@property(nonatomic,retain)UILabel *detailTextLabel;
@property(nonatomic,retain)UITextField *rightTextField;
@property(nonatomic,retain)UISwitch *rightSwitch;
@property(nonatomic,assign)id<SettingCellDelegate> delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellType:(SettingCellType)type;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellType:(SettingCellType)type cellPosition:(RoundedCellBackgroundViewPosition)position;
- (void)setCheckedForCheckButtonTypeCell:(BOOL)checked;
- (void)touchCheckButton;
@end
