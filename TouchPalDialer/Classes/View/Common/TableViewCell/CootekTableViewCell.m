//
//  CootekTableViewCell.m
//  TouchPalDialer
//
//  Created by zhang Owen on 12/16/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "CootekTableViewCell.h"
#import "TPDialerResourceManager.h"
#import "DialerSearchResultViewController.h"
#import "FunctionUtility.h"

#define TEXTLABEL_IN_COOTEKTABLE_VIEW_CELL 123434
#define ICON_IMAGE_IN_COOTEKTABLE_VIEW_CELL 123352
@interface CootekTableViewCell (){
}
@property (nonatomic,weak) UIView  *topSplitLine;
@property (nonatomic,weak) UIView  *bottomSplitLine;
@end

@implementation CootekTableViewCell
@synthesize cellPosition = cellPosition_;

@synthesize bottomLine = bl;
#pragma mark for PlainSytle tableView
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier useDefaultSelectedBackgroundColor:(BOOL)useDefaultColor{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *selectedView = [[UIView alloc] initWithFrame:self.frame];
        if(useDefaultColor){
            selectedView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"defaultCellSelected_color"];
        }else{
            selectedView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellSelected_color"];
        }
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedView;
        
        bl = [[UILabel alloc] initWithFrame:CGRectMake(0, CELL_HEIGHT-0.5, TPScreenWidth(), 0.5)];
        bl.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
        [self addSubview:bl];
        bl.hidden = YES;
    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier useDefaultSelectedBackgroundColor:NO];
}
#pragma mark for GoupedStyle tableView
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellPosition:(RoundedCellBackgroundViewPosition)position{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellPosition_ = position;
        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_Background_color"];
        //important! make sure that the contentView's background is transparent
        self.contentView.backgroundColor = [UIColor clearColor];
        if (!([[[UIDevice currentDevice] systemVersion] floatValue] > 7)) {
            self.contentView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_Background_color"];
        }
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        UIView *htBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        UIColor *selectedBgColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_Background_ht_color"];
        
        htBackgroundView.backgroundColor = selectedBgColor;
//        htBackgroundView.layer.borderColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultUITableViewSeperator_color"].CGColor;
//        htBackgroundView.layer.borderWidth = 0.5;
        
//        // the top border
//        CALayer *topBorderLayer = [CALayer layer];
//        topBorderLayer.backgroundColor = selectedBgColor.CGColor;
//        topBorderLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5);
//        
//        // the bottom border
//        CALayer *bottomBorderLayer = [CALayer layer];
//        bottomBorderLayer.backgroundColor = selectedBgColor.CGColor;
//        bottomBorderLayer.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 0.5);
//        
//        // add vertical borders, no horizontal borders
//        [htBackgroundView.layer addSublayer:topBorderLayer];
//        [htBackgroundView.layer addSublayer:bottomBorderLayer];
        
        self.selectedBackgroundView = htBackgroundView;
        
        UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
        
        UIView *topSplitLine        = [[UIView alloc] init];
        topSplitLine.backgroundColor   = lineColor;
        self.topSplitLine           = topSplitLine;
        [self addSubview:topSplitLine];
        
        UIView *bottomSplitLine     = [[UIView alloc] init];
        bottomSplitLine.backgroundColor   = lineColor;
        self.bottomSplitLine        = bottomSplitLine;
        [self addSubview:bottomSplitLine];
        
        UILabel *checkMarkLabel     = [[UILabel alloc] init];
        self.checkMarkLabel         = checkMarkLabel;
        checkMarkLabel.font         = [UIFont fontWithName:@"iPhoneIcon2" size:20];;
        checkMarkLabel.backgroundColor = [UIColor clearColor];
        checkMarkLabel.textColor    = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_light_blue_500"];
        checkMarkLabel.hidden       = YES;
        checkMarkLabel.text         = @"v";
        [checkMarkLabel sizeToFit];
        [self addSubview:checkMarkLabel];
        
    }
    return self;
}

- (void)refreshSeparateLineColor:(UIColor *)color{
    self.bottomLine.backgroundColor = color;
}

- (void)onShowString:(NSString *)string{
    self.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
    self.textLabel.text = string;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
}
- (void)onShowAddShop{
    self.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
    self.textLabel.text = NSLocalizedString(@"What are you looking for?", @"");
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"addShopCellText_color"];
}

-(void)switchWithADDEXTERCELLTYPE:(NSUInteger)exterType NormalCellType:(NSUInteger)type{
     NSUInteger realType  = exterType == None ? type+1:type;
        switch (realType) {
            case 0:
                [self switchExterCellADDEXTERCELLTYPE:exterType];
                break;
            case 1:
                [self onShowSmsCell];
                break;
            case 2:
                [self onShowAddContact];
                break;
            case 3:
                [self onShowAddToExistingContact];
                break;
            default:
                break;
        }
    
}

-(void)switchExterCellADDEXTERCELLTYPE:(ADDEXTERCELLTYPE)exterType{
    switch (exterType) {
        case ChangeToNmberPad:
            [self onShowChangeNumberPad];
            break;
        case ChangeToQWERTYPad:
            [self onShowChangeQWERTYPad];
            break;
        case PasteClipBoard:
            [self onShowPasteClipBoard];
            break;
        default:
            break;
    }
}


- (void)onShowSmsCell{
    [self addCutomTextLabelWithText:NSLocalizedString(@"Send message", @"Send message")
                              image:[[TPDialerResourceManager sharedManager] getImageByName:@"dailer_item_send_message@2x.png"]
                          textColor:nil];
}

- (void)onShowAddContact{
    [self addCutomTextLabelWithText:NSLocalizedString(@"Create new contact", @"")
                              image:[[TPDialerResourceManager sharedManager]
                                     getImageByName:@"dailer_item_add_contact@2x.png"]
                          textColor:nil];
}

- (void) onShowAddToExistingContact {
    [self addCutomTextLabelWithText:NSLocalizedString(@"Add to existing contact", @"")
                              image:[[TPDialerResourceManager sharedManager]
                                     getImageByName:@"dailer_item_add_contact@2x.png"]
                          textColor:nil];
}
- (void) onShowChangeNumberPad {
    [self addCutomTextLabelWithText:NSLocalizedString(@"Change key number pad", @"")
                              image:[[TPDialerResourceManager sharedManager]
                                     getImageByName:@"dailer_item_change_keyboard@2x.png"]
                          textColor:nil];
}
- (void) onShowChangeQWERTYPad {
    [self addCutomTextLabelWithText:NSLocalizedString(@"Change to qwerty pad", @"")
                              image:[[TPDialerResourceManager sharedManager]
                                     getImageByName:@"dailer_item_change_keyboard@2x.png"]
                          textColor:nil];
}
- (void) onShowPasteClipBoard {
    [self addCutomTextLabelWithText:NSLocalizedString(@"Paste the clipboard number", @"")
                              image:[[TPDialerResourceManager sharedManager]
                                     getImageByName:@"dailer_item_paste_number@2x.png"]
                          textColor:nil];
}


- (void)addCutomTextLabelWithText:(NSString *)text image:(UIImage *)icon textColor:(UIColor *)textColor{
    UILabel *textLabel = (UILabel *)[self viewWithTag:TEXTLABEL_IN_COOTEKTABLE_VIEW_CELL];
    CGFloat contentHeight = self.contentView.frame.size.height;
    if(textLabel == nil){
        int leftGap = 64;
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftGap, 0, self.frame.size.width-leftGap, contentHeight)];
        textLabel.tag = TEXTLABEL_IN_COOTEKTABLE_VIEW_CELL;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
        textLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:textLabel];
    }
    textLabel.text = text;
    if(textColor == nil){
        textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
    }else{
        textLabel.textColor = textColor;
    }
    UIImageView *iconView = (UIImageView *)[self viewWithTag:ICON_IMAGE_IN_COOTEKTABLE_VIEW_CELL];
    if(iconView == nil){
        iconView = [[UIImageView alloc] initWithImage:icon];
        iconView.tag = ICON_IMAGE_IN_COOTEKTABLE_VIEW_CELL;
        iconView.frame = CGRectMake(12, (contentHeight - iconView.image.size.height) / 2, iconView.image.size.width, iconView.image.size.height);
        [self addSubview:iconView];
    }else{
        iconView.image = icon;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)setBottomlineIfHidden:(BOOL)ifHidden{
    self.bottomLine.hidden = ifHidden;
}
/*
- (id)selfSkinChange:(NSString *)style{
     NSDictionary *propertyDic = [[ResourceManager sharedManager] getPropertyDicByStyle:style];
     self.textLabel.textColor = [[ResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]];
     self.detailTextLabel.textColor = [[ResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:DETAIL_LABEIL_TEXT_COLOR]];
     self.textLabel.backgroundColor = [UIColor clearColor];
     self.detailTextLabel.backgroundColor = [UIColor clearColor];
     NSNumber *toTop = [NSNumber numberWithBool:YES];
     return toTop;
}*/


- (void)layoutSubviews{
    
    [super layoutSubviews];
    CGFloat splitLineX = self.textLabel.tp_x;
    CGFloat splitLineH = 1 / [UIScreen mainScreen].scale;
    CGFloat splitLineY = self.bounds.size.height;
    CGFloat splitLineW = self.bounds.size.width;
    
    self.bottomSplitLine.frame =  CGRectMake(splitLineX, splitLineY, splitLineW, splitLineH);
    
    self.topSplitLine.frame =  CGRectMake(splitLineX, 0, splitLineW, splitLineH);
    
    if(cellPosition_ == RoundedCellBackgroundViewPositionTop) {
        self.topSplitLine.tp_x = 0;
    }else if(cellPosition_ == RoundedCellBackgroundViewPositionBottom) {
        self.bottomSplitLine.tp_x = 0;
    }if(cellPosition_ == RoundedCellBackgroundViewPositionSingle) {
        self.bottomSplitLine.tp_x = 0;
        self.topSplitLine.tp_x = 0;
    }
    
    self.checkMarkLabel.tp_x = self.tp_width - self.checkMarkLabel.tp_width - 16;
    self.checkMarkLabel.tp_y = (self.tp_height - self.checkMarkLabel.tp_height) / 2;
}

@end
