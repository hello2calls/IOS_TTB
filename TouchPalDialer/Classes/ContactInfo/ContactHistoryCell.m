//
//  ContactHistoryCell.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/23.
//
//

#import "ContactHistoryCell.h"
#import "TPDialerResourceManager.h"
#import "ContactInfoUtil.h"
#import "FunctionUtility.h"

@interface ContactHistoryCell(){
    UILabel *_voipLabel;
    
    UILabel *_mainLabel;
    UILabel *_subLabel;
    UILabel *_timeLabel;
    
    UIView *_bottomLine;
}

@end

@implementation ContactHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                 callLogModel:(CallLogDataModel *)model{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self ){
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        UIView *view_bg = [[UIView alloc]initWithFrame:self.frame];
        view_bg.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"];
        self.selectedBackgroundView = view_bg;
        
        _voipLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,23,14,14)];
        _voipLabel.backgroundColor = [UIColor clearColor];
        if ( model.ifVoip ){
            _voipLabel.text = @"o";
            _voipLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
        }else{
            _voipLabel.text = @"0";
            _voipLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
        }
        _voipLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:14];
        _voipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_voipLabel];
        
        _mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 12, TPScreenWidth() - 140, 16)];
        _mainLabel.backgroundColor = [UIColor clearColor];
        _mainLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        _mainLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        _mainLabel.text = [ContactInfoUtil getTimeStr:model.callTime];
        [self addSubview:_mainLabel];
        
        _subLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 34, TPScreenWidth() - 140, 14)];
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        _subLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        _subLabel.text = model.number;
        [self addSubview:_subLabel];
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(TPScreenWidth() - 140, 23, 124, 14)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        _timeLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.text = [FunctionUtility getTimeString:model.duration];
        [self addSubview:_timeLabel];
        
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(40 , 59.5, TPScreenWidth()-40, 0.5)];
        _bottomLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_150"];
        [self addSubview:_bottomLine];
    }
    
    return self;
}

- (void) refreshView:(CallLogDataModel *)model{
    _mainLabel.text = [ContactInfoUtil getTimeStr:model.callTime];
    _subLabel.text = model.number;
    _timeLabel.text = [FunctionUtility getTimeString:model.duration];
    if ( model.ifVoip ){
        _voipLabel.text = @"o";
        _voipLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
    }else{
        _voipLabel.text = @"0";
        _voipLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
    }
}

- (void)showBottomLine{
    _bottomLine.hidden = NO;
}

- (void)hideBottomLine{
    _bottomLine.hidden = YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if ( self.editing ){
        _voipLabel.frame = CGRectMake(56,23,14,14);
        _mainLabel.frame = CGRectMake(80, 12, TPScreenWidth() - 140, 16);
        _subLabel.frame = CGRectMake(80, 34, TPScreenWidth() - 140, 14);
        _bottomLine.frame = CGRectMake(80 , 59.5, TPScreenWidth()-40, 0.5);
    }else{
        _voipLabel.frame = CGRectMake(16,23,14,14);
        _mainLabel.frame = CGRectMake(40, 12, TPScreenWidth() - 140, 16);
        _subLabel.frame = CGRectMake(40, 34, TPScreenWidth() - 140, 14);
        _bottomLine.frame = CGRectMake(40 , 59.5, TPScreenWidth() - 40, 0.5);
    }
}

@end
