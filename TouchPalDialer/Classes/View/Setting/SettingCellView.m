//
//  SettingCellView.m
//  TouchPalDialer
//
//  Created by Ailce on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingCellView.h"
#import "TPUIButton.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "TPDialerResourceManager.h"
#import "CustomTextField.h"

#define CHECK_BUTTON_TAG 100
#define CELLDISTANCE ([[UIDevice currentDevice].systemVersion intValue] >= 7) ? 15 : 20
#define LABEL_WIDTH (TPScreenWidth()-40)

@interface SettingCellView (){
  BOOL checked_;
}
@end

@implementation SettingCellView

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize rightTextField;
@synthesize rightSwitch;
@synthesize delegate;
@synthesize cellKey;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellType:(SettingCellType)type cellPosition:(RoundedCellBackgroundViewPosition)position{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellPosition:position];
    if (self) {
        int width = 0;
        switch (type) {
            case SwitchCellType:
            {
                UISwitch *tmpSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                [tmpSwitch addTarget:self action:@selector(setSwitch:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:tmpSwitch];
                self.rightSwitch = tmpSwitch;
                width = LABEL_WIDTH - rightSwitch.frame.size.width;
                break;
            }
            case TextFieldTypeCell:
            {
                
                CustomTextField *tmpText = [[CustomTextField alloc] initWithFrame:CGRectMake(20, 0, LABEL_WIDTH, self.frame.size.height)];
                tmpText.needFilterCharacters = YES;
                tmpText.textAlignment = NSTextAlignmentRight;
                tmpText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                tmpText.backgroundColor = [UIColor clearColor];
                tmpText.borderStyle = UITextBorderStyleNone;
                tmpText.delegate  = self;
                tmpText.keyboardType = UIKeyboardTypeNumberPad;
                tmpText.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
                [self addSubview:tmpText];
                self.rightTextField = tmpText;
                width = 100;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyBoard)
                                                             name:N_HIDE_KEYBOARD_TEXTFIELD object:nil];
                break;
            }
            case OperationButtonTypeCell:
            {
//                TPUIButton *button = [[TPUIButton alloc] initWithFrame:CGRectMake(TPScreenWidth()-50,0, 40, 60)];
//                UIImage *buttonHighligeted = [[TPDialerResourceManager sharedManager] getImageByName:@"smartEyeSetting_delete_hg@2x.png"];
//                UIImage *buttonNormal = [[TPDialerResourceManager sharedManager] getImageByName:@"smartEyeSetting_delete_normal@2x.png"];
//                [button setBackgroundImage:buttonHighligeted forState:UIControlStateHighlighted];
//                [button setBackgroundImage:buttonNormal forState:UIControlStateNormal];
//                [button addTarget:self action:@selector(touchOperationButton) forControlEvents:UIControlEventTouchUpInside];
//                [self addSubview:button];
                width = LABEL_WIDTH-60;
                break;
            }
            case CheckButtonTypeCell:
            {
                TPUIButton *button = [[TPUIButton alloc] initWithFrame:CGRectMake(TPScreenWidth()-95 +7.5,12.5, 25, 25)];
                [button setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"login_uncheck@2x.png"] forState:UIControlStateNormal];
                [button setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"login_checked@2x.png"] forState:UIControlStateSelected];
                [button addTarget:self action:@selector(touchCheckButton) forControlEvents:UIControlEventTouchUpInside];
                button.tag = CHECK_BUTTON_TAG;
                [self addSubview:button];
                width = LABEL_WIDTH-90;
                break;
            }
            default:
                width = LABEL_WIDTH;
                break;
        }
        if( style == UITableViewCellStyleSubtitle)
        {
            UILabel* tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELLDISTANCE, 0, width, FONT_SIZE_3)];
            tmpLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
            tmpLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
            tmpLabel.textAlignment = NSTextAlignmentLeft;
            tmpLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:tmpLabel];
            self.textLabel = tmpLabel;
            
            tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELLDISTANCE, 25, width, FONT_SIZE_5)];
            tmpLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultTextGray_color"];
            tmpLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5];
            tmpLabel.textAlignment = NSTextAlignmentLeft;
            tmpLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:tmpLabel];
            self.detailTextLabel = tmpLabel;
        }else{
            UILabel* tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELLDISTANCE, 0, width, self.frame.size.height)];
            tmpLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
            tmpLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
            tmpLabel.textAlignment = NSTextAlignmentLeft;
            tmpLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:tmpLabel];
            self.textLabel = tmpLabel;
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellType:(SettingCellType)type
{
   self = [self initWithStyle:style reuseIdentifier:reuseIdentifier withCellType:type cellPosition:RoundedCellBackgroundViewPositionSingle];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (void)hideKeyBoard{
    [rightTextField resignFirstResponder];
}
- (void)setSwitch:(UISwitch *)sender
{
    if ([delegate respondsToSelector:@selector(changeSwitch:withKey:)]) {
        [delegate changeSwitch:sender.isOn withKey:cellKey];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSCharacterSet *whitespace = [NSCharacterSet  whitespaceAndNewlineCharacterSet]; 
    NSString *tmpString = [textField.text stringByTrimmingCharactersInSet:whitespace];
    if ([delegate respondsToSelector:@selector(textDidEndEditing:withKey:)]) {
        [delegate textDidEndEditing:tmpString withKey:cellKey];
    }
    [textField resignFirstResponder];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([cellKey length] > 0 && [cellKey isEqualToString:@"network"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_SHOW_KEYBOARD_TEXTFIELD
                                                            object:nil
                                                          userInfo:nil];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    int STATUS_MAX_LENGTH = 6;
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([toBeString length] > STATUS_MAX_LENGTH) {
        textField.text = [toBeString substringToIndex:STATUS_MAX_LENGTH];
        return NO;
    }else {
        if ([delegate respondsToSelector:@selector(textChanged:withKey:)]) {
            [delegate textChanged:toBeString withKey:cellKey];
        }
        return YES;
    }
}

- (void)setCheckedForCheckButtonTypeCell:(BOOL)checked{
    UIButton *checkButton = (UIButton *)[self viewWithTag:CHECK_BUTTON_TAG];
    [checkButton setSelected:checked];
}
- (void)touchOperationButton{
    [delegate touchOperationButton:cellKey];
}
- (void)touchCheckButton{
    UIButton *button = (UIButton *)[self viewWithTag:CHECK_BUTTON_TAG];
    [button setSelected:!button.selected];
    if([delegate respondsToSelector:@selector(touchCheckButton: withKey:)]){
        [delegate touchCheckButton:button.selected withKey:cellKey];
    }
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SkinHandler removeRecursively:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.rightTextField.tp_height = self.tp_height;
    self.textLabel.tp_y = (self.tp_height - self.textLabel.tp_height - self.detailTextLabel.tp_height) / 2;
    self.textLabel.tp_x = CELLDISTANCE;
    
    self.detailTextLabel.tp_y = self.textLabel.tp_y + self.textLabel.tp_height + 4;
    self.detailTextLabel.tp_x = CELLDISTANCE;
    
    if (self.rightSwitch != nil) {
        self.rightSwitch.tp_x = self.tp_width - self.rightSwitch.tp_width - 16;
        self.rightSwitch.tp_y = (self.tp_height - self.rightSwitch.tp_height) / 2;
    }
}
@end
