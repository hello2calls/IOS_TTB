//
//  DefaultSettingCellView.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-19.
//
//

#import "DefaultSettingCellView.h"
#import "HighlightTip.h"
#import "TPDialerResourceManager.h"

@interface DefaultSettingCellView() {
    UserSettingHighlightTip* tip_;
}
@property (nonatomic, retain) SettingItemModel* cellData;
@property (nonatomic, retain) UILabel *hintLabel;
@end

@implementation DefaultSettingCellView

@synthesize cellData;

+(DefaultSettingCellView*) defaultCellWithData:(SettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position {
    return [DefaultSettingCellView defaultCellWithData:data forPosition:position selectionStyle:UITableViewCellSelectionStyleBlue accessoryType:UITableViewCellAccessoryNone];
}

+(DefaultSettingCellView*) defaultCellWithData:(SettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position selectionStyle:(UITableViewCellSelectionStyle)selectionStyle accessoryType:(UITableViewCellAccessoryType) accessoryType {
    DefaultSettingCellView* result = [[DefaultSettingCellView alloc] initWithData:data forPosition:position cellStyle:[DefaultSettingCellView styleForData:data] selectionStyle:selectionStyle accessoryType:accessoryType];
    [result fillData:data];
    return result;
}

-(id)initWithData:(SettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position cellStyle:(UITableViewCellStyle)cellStyle selectionStyle:(UITableViewCellSelectionStyle)selectionStyle accessoryType:(UITableViewCellAccessoryType) accessoryType {
    
    self = [super initWithStyle:cellStyle
                reuseIdentifier:[DefaultSettingCellView reuseIdentifierForData:data inPosition:position]
                   cellPosition:position];
    if(self) {
        self.selectionStyle = selectionStyle;
        if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            UIImage *accessoryImage = [[TPDialerResourceManager sharedManager] getImageByName:@"setting_listitem_detail@2x.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(TPScreenWidth() - accessoryImage.size.width - 16, (60 - accessoryImage.size.height ) / 2, accessoryImage.size.width, accessoryImage.size.height);
            button.frame = frame;
            [button setImage:accessoryImage forState:UIControlStateNormal];
            [button setImage:accessoryImage forState:UIControlStateHighlighted];
            button.backgroundColor= [UIColor clearColor];
            [self addSubview:button];
        }else{
            self.accessoryType = accessoryType;
        }
        
        UILabel *tmpHintLabel = [[UILabel alloc]init];
        tmpHintLabel.textAlignment = NSTextAlignmentCenter;
        tmpHintLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        tmpHintLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        tmpHintLabel.layer.masksToBounds = YES;
        tmpHintLabel.hidden = YES;
        [self addSubview:tmpHintLabel];
        self.hintLabel = tmpHintLabel;
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:13];

    }
    
    return self;
}

+(UITableViewCellStyle) styleForData:(SettingItemModel*) data {
    if(data.subtitle != nil && data.subtitle.length > 0) {
        return UITableViewCellStyleSubtitle;
    } else {
        return UITableViewCellStyleDefault;
    }
}

+(NSString*) reuseIdentifierForData:(SettingItemModel*) data inPosition:(RoundedCellBackgroundViewPosition)position {
    return [NSString stringWithFormat:@"%@_%d", [data class], position];
}

-(void) fillData:(SettingItemModel*) data {
    
    self.cellData = data;
    
    if(tip_ != nil) {
        // remove the original tip
        [tip_ detach];
        tip_ = nil;
    }
    
    if(data.title) {
        self.textLabel.text = NSLocalizedString(data.title, @"");
    }
    if(data.subtitle != nil && data.subtitle.length > 0) {
        self.detailTextLabel.text = NSLocalizedString(data.subtitle, @"");
    }
    self.userInteractionEnabled = data.isEnabled;
    if(data.isEnabled) {
        self.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
        self.textLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
        self.detailTextLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
        self.detailTextLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    } else {
        self.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
        self.detailTextLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    }
    
    if(data.featureTip && data.featureTip.showTip) {
        
        tip_ = [[UserSettingHighlightTip alloc] initWithUserSetting:data.featureTip.tipKey expectedValue:data.featureTip.expectedValue];
        CGPoint p = CGPointMake(self.frame.size.width - 60, 0);
        [tip_ attachToView:self atPosition:p];
    }
    
    CGFloat textWidth = 0;
    CGFloat titleWidth = 0;
    CGFloat subtitleWidth = 0;
    if (data.title) {
        titleWidth = [data.title sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_1_5] constrainedToSize:CGSizeMake(MAXFLOAT, self.frame.size.height)].width;
    }
    if (data.subtitle) {
        subtitleWidth = [data.subtitle sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_6] constrainedToSize:CGSizeMake(MAXFLOAT, self.frame.size.height)].width;
    }
    if (titleWidth > subtitleWidth) {
        textWidth = titleWidth;
    } else  {
        textWidth = subtitleWidth;
    }
    textWidth = (int)textWidth;
    switch (data.hintType) {
        case Type_new:
            _hintLabel.frame = CGRectMake(textWidth + 20, self.frame.size.height / 2 - 7, 35, 14);
            _hintLabel.text = @"NEW";
            _hintLabel.font = [UIFont systemFontOfSize:10];
            _hintLabel.layer.cornerRadius = 7;
            _hintLabel.hidden = NO;
            break;
        case Type_dot:
            _hintLabel.frame = CGRectMake(textWidth + 15, 10, 10, 10);
            _hintLabel.layer.cornerRadius = 5;
            _hintLabel.textAlignment = NSTextAlignmentLeft;
            _hintLabel.hidden = NO;
            break;
        case Type_num:
            _hintLabel.frame = CGRectMake(textWidth + 20, self.frame.size.height / 2 - 8, 16, 16);
            _hintLabel.layer.cornerRadius = 8;
            _hintLabel.text = [NSString stringWithFormat:@"%d", data.hintCount];
            _hintLabel.layer.borderWidth = 0;
            if (data.hintCount > 9) {
                _hintLabel.font = [UIFont systemFontOfSize:10];
                _hintLabel.hidden = NO;
            } else if(data.hintCount > 0){
                _hintLabel.font = [UIFont systemFontOfSize:12];
                _hintLabel.hidden = NO;
            } else {
                _hintLabel.hidden = YES;
            }
            break;
        default:
            _hintLabel.hidden = YES;
            break;
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.textLabel.tp_y = (self.tp_height - self.textLabel.tp_height) / 2;
    
    self.detailTextLabel.tp_y = (self.tp_height - self.detailTextLabel.tp_height) / 2;
    self.detailTextLabel.tp_x = self.tp_width - self.detailTextLabel.tp_width - 36;
}
@end
