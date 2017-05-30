//
//  ContactSpecialCell.m
//  TouchPalDialer
//
//  Created by game3108 on 15/4/21.
//
//

#import "ContactSpecialCell.h"
#import "UserDefaultsManager.h"
#import "TouchpalMembersManager.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "UILabel+DynamicHeight.h"
#import "CootekNotifications.h"
#import "AllViewController.h"
#import "UILabel+DynamicHeight.h"
#import "NSString+TPHandleNil.h"

@interface ContactSpecialCell()<NSObject>{
    UILabel *_imageLabel;
    UILabel *_mainLabel;
    UILabel *_subLabel;
    UILabel *_numberLabel;

    NSInteger _type;

    UIImageView *_imageView;
    UIImageView *_numberImageView;
    UIImageView *_dotImageView;
    BOOL onTouchMove;
    UILabel *_partBLine;
    UIColor *_lineColor;
}

@end

static CGFloat sMainLabelHeight = 0;
static CGFloat sSubLabelHeight = 0;

@implementation ContactSpecialCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style
             reuseIdentifier:(NSString *)reuseIdentifier
                    delegate:(id<ContactSpecialCellDelegate>)delegate
          contactSpecialInfo:(ContactSpecialInfo *)info
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if ( self ){
        self.delegate = delegate;
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CONTACT_CELL_LEFT_GAP, (CONTACT_CELL_HEIGHT - CONTACT_CELL_PHOTO_DIAMETER )/2, CONTACT_CELL_PHOTO_DIAMETER, CONTACT_CELL_PHOTO_DIAMETER)];

        _imageView.image = [[TPDialerResourceManager sharedManager]getResourceByStyle:@"contact_special_cell_blue_image"];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = _imageView.frame.size.width/2;
        [self.contentView addSubview:_imageView];

        if (info.text) {
            _imageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CONTACT_CELL_PHOTO_DIAMETER, CONTACT_CELL_PHOTO_DIAMETER)];
            _imageLabel.font = [UIFont fontWithName:info.fontName size:24];
            _imageLabel.backgroundColor = [UIColor clearColor];
            if (info.bgColorStyle) {
                _imageLabel.layer.backgroundColor = [TPDialerResourceManager getColorForStyle:info.bgColorStyle].CGColor;
            }
            _imageLabel.layer.masksToBounds = YES;
            _imageLabel.layer.cornerRadius = _imageLabel.frame.size.width/2;
            _imageLabel.textAlignment = NSTextAlignmentCenter;

            NSString *colorStyle = nil;
            if (info.textColorStyle) {
                colorStyle = info.textColorStyle;
            } else {
                colorStyle = @"contact_special_cell_icon_color";
            }
            _imageLabel.textColor = [TPDialerResourceManager getColorForStyle:colorStyle];
            _imageLabel.text = info.text;
            [_imageView addSubview:_imageLabel];
        }


        self.backgroundColor = [UIColor clearColor];

        CGFloat contentAreaWidth = TPScreenWidth() - CONTACT_CELL_MARGIN_LEFT - INDEX_SECTION_VIEW_WIDTH;
        if (info) {
            if (![NSString isNilOrEmpty:info.mainTitle]) {
                _mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(CONTACT_CELL_MARGIN_LEFT, 0, contentAreaWidth, 20)];
                _mainLabel.backgroundColor = [UIColor clearColor];
                _mainLabel.font = [UIFont boldSystemFontOfSize:17];
                _mainLabel.textAlignment = NSTextAlignmentLeft;
                [self.contentView addSubview:_mainLabel];
                _mainLabel.text = info.mainTitle;
                if (sMainLabelHeight == 0) {
                    [_mainLabel adjustSizeByFillContent];
                    sMainLabelHeight = _mainLabel.frame.size.height;
                    [FunctionUtility setWidth:contentAreaWidth forView:_mainLabel];
                }
            }
            
            if (![NSString isNilOrEmpty:info.subTitle]) {
                _subLabel = [[UILabel alloc]initWithFrame:CGRectMake(CONTACT_CELL_MARGIN_LEFT, 30, contentAreaWidth, 20)];
                _subLabel.backgroundColor = [UIColor clearColor];
                _subLabel.font = [UIFont boldSystemFontOfSize:12];
                _subLabel.textAlignment = NSTextAlignmentLeft;
                _subLabel.text = info.subTitle;
                
                [self.contentView addSubview:_subLabel];
            }
            
            if (info.subTitle != nil) {
                // only main title, to adjust the position of the main label
                if (info.type == NODE_CONTACT_TRANSFER) {
                    CGRect frame = _mainLabel.frame;
                    
                    if (![UserDefaultsManager boolValueForKey:CONTACT_TRANSFER_GUIDE_SHOWN defaultValue:NO]) {
                        [_mainLabel adjustSizeByFixedHeight];  // adjust the width
                        CGFloat gX = frame.origin.x + _mainLabel.frame.size.width;
                        CGSize dotSize = CGSizeMake(32, 16);
                        CGRect dotFrame = CGRectMake(gX + 10, (CONTACT_CELL_HEIGHT - dotSize.height) / 2, dotSize.width, dotSize.height);
                        
                        _dotImageView = [[UIImageView alloc] initWithFrame:dotFrame];
                        _dotImageView.image = [TPDialerResourceManager getImageByColorName:@"tp_color_red_500" withFrame:_dotImageView.bounds];
                        _dotImageView.clipsToBounds = YES;
                        _dotImageView.layer.cornerRadius = dotSize.height / 2;
                        
                        UILabel *dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dotFrame.size.width, dotFrame.size.height)];
                        dotLabel.backgroundColor = [UIColor clearColor];
                        dotLabel.text = @"NEW";
                        dotLabel.textColor = [UIColor whiteColor];
                        dotLabel.font = [UIFont systemFontOfSize:10];
                        dotLabel.textAlignment = NSTextAlignmentCenter;
                        
                        [_dotImageView addSubview:dotLabel];
                        [self.contentView addSubview:_dotImageView];
                    }
                }
                // for contact transfer node
            }
            if(info.type == NODE_MY_FAMILY) {
                        if (![UserDefaultsManager boolValueForKey:CONTACT_FAMILY_GUIDE_SHOWN defaultValue:NO]) {
                            CGRect frame = _mainLabel.frame;
                            [_mainLabel adjustSizeByFixedHeight];  // adjust the width
                            CGFloat gX = frame.origin.x + _mainLabel.frame.size.width;
                            CGSize dotSize = CGSizeMake(32, 16);
                            CGRect dotFrame = CGRectMake(gX + 10, (CONTACT_CELL_HEIGHT - dotSize.height) / 2, dotSize.width, dotSize.height);
                            _dotImageView = [[UIImageView alloc] initWithFrame:dotFrame];
                            _dotImageView.image = [TPDialerResourceManager getImageByColorName:@"tp_color_red_500" withFrame:_dotImageView.bounds];
                            _dotImageView.clipsToBounds = YES;
                            _dotImageView.layer.cornerRadius = dotSize.height / 2;
                            
                            UILabel *dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dotFrame.size.width, dotFrame.size.height)];
                            dotLabel.backgroundColor = [UIColor clearColor];
                            dotLabel.text = @"NEW";
                            dotLabel.textColor = [UIColor whiteColor];
                            dotLabel.font = [UIFont systemFontOfSize:10];
                            dotLabel.textAlignment = NSTextAlignmentCenter;
                            
                            [_dotImageView addSubview:dotLabel];
                            [self.contentView addSubview:_dotImageView];
                        } else {
                            _dotImageView.hidden = YES;
                            if ([TouchpalMembersManager getTouchpalerFamilyArrayCount]==0) {
                                _numberLabel.hidden = YES;
                            } else {
                                NSDate *nowDate = [NSDate date];
                                NSDate *oldDate = [UserDefaultsManager dateForKey:CONTACT_FAMILY_GUIDE_CLICK_DATE defaultValue:[NSDate dateWithTimeIntervalSince1970:0]];
                                NSTimeInterval interval = [nowDate timeIntervalSinceDate:oldDate];
                                    
                                if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME]!=nil
                                    && interval > 60*10) {
                                    _numberLabel.hidden = NO;
                                }
                                else {
                                    _numberLabel.hidden = YES;
                                }
                            }
                        }
                    

                
            }
        }

        CGFloat numberDiameter = 16;
        CGFloat redDotX = TPScreenWidth() - COOTEK_USER_ICON_MARGIN_RIGHT - numberDiameter - INDEX_SECTION_VIEW_WIDTH;
        _numberImageView = [[UIImageView alloc]initWithFrame:CGRectMake(redDotX, (CONTACT_CELL_HEIGHT-numberDiameter)/2, numberDiameter, numberDiameter)];
        _numberImageView.layer.masksToBounds = YES;
        _numberImageView.layer.cornerRadius = 8.0f;
        _numberImageView.image = [FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_red_500"]];
        _numberImageView.hidden = YES;
        [self.contentView addSubview:_numberImageView];
        _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0 ,0, numberDiameter, numberDiameter)];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:12];
        [_numberImageView addSubview:_numberLabel];
        
        if ( info != nil ){
            _type = info.type;
            NSString *numberString = nil;
            if (info.number > 99) {
                numberString = @"99+";
            }else{
                numberString = [NSString stringWithFormat:@"%d",info.number];
            }
            _numberLabel.text = numberString;
            if ( [_numberLabel.text length] > 1){
                _numberLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:8];
            }else{
                _numberLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12];
            }
            
            if (info.type == NODE_CONTACT_TRANSFER) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlert) name:N_REFRESH_SPECIAL_CONTACT_NODE object:nil];
            }
            
        }else{
            _type = 0;
        }
        _numberImageView.hidden = (info.number && [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME]) == 0;
    }
    
    _lineColor = [TPDialerResourceManager getColorForStyle:@"baseContactCell_downSeparateLine_color"];
    _partBLine = [[UILabel alloc]initWithFrame:CGRectMake(_mainLabel.frame.origin.x, CONTACT_CELL_HEIGHT - 0.5, TPScreenWidth() - _mainLabel.frame.origin.x - INDEX_SECTION_VIEW_WIDTH, 0.5)];
    _partBLine.backgroundColor = _lineColor;
    [self addSubview:_partBLine];

    
    [self adjustLabelsHeights];
    
    return self;
}

- (void) onAlert {
    if (_type == NODE_CONTACT_TRANSFER) {
        if (_dotImageView) {
            _dotImageView.hidden = YES;
        }
    }
}

-(void)setData:(ContactSpecialInfo *)info{
    if ( info != nil ){
        _type = info.type;
        switch (_type) {
            case NODE_TOUCHPALER: {
                _dotImageView.hidden = YES;
                if (info.number) {
                    NSString *numberString = nil;
                    if (info.number > 99) {
                        numberString = @"99+";
                    }else{
                        numberString = [NSString stringWithFormat:@"%d",info.number];
                    }
                    _numberLabel.text  = numberString;
                    if ( [_numberLabel.text length] > 1){
                        _numberLabel.font = [UIFont systemFontOfSize:8];
                    }else{
                        _numberLabel.font = [UIFont systemFontOfSize:12];
                    }
                }
                _numberImageView.hidden = (info.number == 0);
                break;
            }
            case NODE_MY_FAMILY: {
                        if (![UserDefaultsManager boolValueForKey:CONTACT_FAMILY_GUIDE_SHOWN defaultValue:NO]) {
                            _dotImageView.hidden = NO;
                        } else {
                            _dotImageView.hidden = YES;
                            if ([TouchpalMembersManager getTouchpalerFamilyArrayCount]==0) {
                                _numberImageView.hidden = YES;
                            } else {
                                NSDate *nowDate = [NSDate date];
                                NSDate *oldDate = [UserDefaultsManager dateForKey:CONTACT_FAMILY_GUIDE_CLICK_DATE defaultValue:[NSDate dateWithTimeIntervalSince1970:0]];
                                NSTimeInterval interval = [nowDate timeIntervalSinceDate:oldDate];
                                
                                if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME]!=nil
                                    && interval > 60*10) {
                                    _numberLabel.text  = [NSString stringWithFormat:@"%d",[TouchpalMembersManager getTouchpalerFamilyArrayCount]];
                                    _dotImageView.hidden = YES;
                                    _numberImageView.hidden = NO;
                                } else {
                                    _numberImageView.hidden = YES;
                                }
                            }
                            
                        }
                    
                break;
            }
                
            case NODE_CONTACT_SMART_GROUP:
            case NODE_CONTACT_TRANSFER: {
                _numberImageView.hidden = YES;
                _subLabel.hidden = YES;
                break;
            }
            case NODE_CONTACT_INVITE: {
                
                break;
            }
            default:
                break;
        }
        _imageLabel.font = [UIFont fontWithName:info.fontName size:24];
        _imageLabel.text = info.text;
        if (info.bgColorStyle) {
            _imageLabel.layer.backgroundColor = [TPDialerResourceManager getColorForStyle:info.bgColorStyle].CGColor;
        }
        NSString *colorStyle = (info.textColorStyle == nil)? @"contact_special_cell_icon_color": info.textColorStyle;
        _imageLabel.textColor = [TPDialerResourceManager getColorForStyle:colorStyle];
        
        _mainLabel.text = info.mainTitle;
        _subLabel.text = info.subTitle;
        
        _subLabel.hidden = [NSString isNilOrEmpty:info.subTitle];
        [self adjustLabelsHeights];
        
    } else {
        _type = NODE_UNKOWN;
    }
    
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    onTouchMove = YES;
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ( onTouchMove ){
        onTouchMove = NO;
    }else{
        [self.delegate onButtonPressed:_type];
    }
    [super touchesEnded:touches withEvent:event];
}

- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];

    _mainLabel.textColor = [[TPDialerResourceManager sharedManager]
                          getUIColorFromNumberString:[propertyDic objectForKey:@"titleLabel_textColor"]];
    _mainLabel.backgroundColor = [UIColor clearColor];

    _subLabel.textColor = [[TPDialerResourceManager sharedManager]
                            getUIColorFromNumberString:[propertyDic objectForKey:@"subtitleLabel_textColor"]];
    _subLabel.backgroundColor = [UIColor clearColor];
    _lineColor = [TPDialerResourceManager getColorForStyle:@"baseContactCell_downSeparateLine_color"];
    _partBLine.backgroundColor = _lineColor;

    UIView *selectedView = [[UIView alloc] initWithFrame:self.frame];
    selectedView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"defaultCellSelected_color"];
    self.selectedBackgroundView = selectedView;

    NSNumber *toTop = [NSNumber numberWithBool:YES];
    self.contentView.layer.backgroundColor = [TPDialerResourceManager getColorForStyle:@"defaultCellBackground_color"].CGColor;
    return toTop;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) showBottomLine {
    _partBLine.hidden = NO;
}

- (void) hideBottomLine {
    _partBLine.hidden = YES;
}

#pragma mark helpers
- (void) adjustLabelsHeights {
    CGFloat totalHeight = 0;
    
    if (_mainLabel != nil && !_mainLabel.isHidden) {
        if (sMainLabelHeight == 0) {
            [_mainLabel adjustSizeByFixedWidth];
            sMainLabelHeight = _mainLabel.frame.size.height;
        }
        totalHeight += sMainLabelHeight;
    }
    if (_subLabel != nil && !_subLabel.isHidden) {
        if (sSubLabelHeight == 0) {
            [_subLabel adjustSizeByFixedWidth];
            sSubLabelHeight =  _subLabel.frame.size.height;
        }
        totalHeight += sSubLabelHeight;
        totalHeight += MAIN_SUB_DIFF;
    }
    
    CGFloat gY = (CONTACT_CELL_HEIGHT - totalHeight) / 2;
    if (!_mainLabel.isHidden) {
        [FunctionUtility setY:gY forView:_mainLabel];
        gY += _mainLabel.frame.size.height;
    }
    if (!_subLabel.isHidden) {
        gY += MAIN_SUB_DIFF; // margin of sublabel
        [FunctionUtility setY:gY forView:_subLabel];
    }
}


@end
