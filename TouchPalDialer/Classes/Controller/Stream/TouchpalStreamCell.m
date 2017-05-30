//
//  TouchpalStreamCell.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/26.
//
//

#import "TouchpalStreamCell.h"
#import "TPDialerResourceManager.h"
#import "AllViewController.h"

@interface TouchpalStreamCell(){
    UILabel *timeLabel;
    
    UILabel *mainLabel;
}

@end

@implementation TouchpalStreamCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier info:(C2CHistoryInfo *)info{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:info.datetime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, VOIP_CELL_HEIGHT/2 - FONT_SIZE_4_5 - 3, 150, FONT_SIZE_4_5 + 1)];
        timeLabel.text = dateString;
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
        timeLabel.textColor = [TPDialerResourceManager getColorForStyle:@"stream_timelabel_text_color"];
        [self addSubview:timeLabel];
        
        NSString *bonusTime;
        NSString *shareLabel;
        if ( info.bonusType == 1){
            if ( info.bonus >= 0 ){
                bonusTime = [NSString stringWithFormat:@"%dMB",info.bonus];
                shareLabel = [NSString stringWithFormat:@"%@%@%@%@%@",NSLocalizedString(@"stream_sharelabel_title1", ""),info.eventName,NSLocalizedString(@"stream_sharelabel_title2", ""),bonusTime,NSLocalizedString(@"stream_sharelabel_title3", "")];
            }else{
                bonusTime = [NSString stringWithFormat:@"%dMB",-info.bonus];
                shareLabel = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"stream_sharelabel_title4", ""),bonusTime,NSLocalizedString(@"stream_sharelabel_title3", "")];
            }
        }else{
            bonusTime = [NSString stringWithFormat:@"%d分钟",info.bonus/60];
            shareLabel = [NSString stringWithFormat:@"%@%@%@%@",NSLocalizedString(@"stream_sharelabel_title1", ""),info.eventName,NSLocalizedString(@"stream_sharelabel_title2", ""),bonusTime];
        }
        
        NSRange range1;
        NSRange range2;
        NSRange range3;
        NSRange range4 = NSMakeRange (0, 0);
        NSRange range5 = NSMakeRange (0, 0);
        
        if ( info.bonusType == 1 && info.bonus < 0 ){
            range1 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title4", "")];
            range2 = [shareLabel rangeOfString:bonusTime];
            range3 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title3", "") options:NSBackwardsSearch];
        }else{
            range1 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title1", "")];
            range2 = [shareLabel rangeOfString:info.eventName];
            range3 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title2", "")];
            range4 = [shareLabel rangeOfString:bonusTime];
            range5 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title3", "") options:NSBackwardsSearch];
        }
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:shareLabel];
        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_text_color"] range:range1];
        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_first_color"]  range:range2];
        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_text_color"] range:range3];
        if ( info.bonusType == 1) {
            [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_third_color"] range:range4];
        }else{
            [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_second_color"] range:range4];
        }
        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_text_color"] range:range5];
        
        mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, VOIP_CELL_HEIGHT/2 + 3, TPScreenWidth() - 32, FONT_SIZE_4_5 + 1)];
        mainLabel.textAlignment = NSTextAlignmentLeft;
        mainLabel.attributedText = str;
        mainLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
        mainLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:mainLabel];
    
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(CONTACT_CELL_LEFT_GAP, VOIP_CELL_HEIGHT-0.5, TPScreenWidth()-CONTACT_CELL_LEFT_GAP*2, 0.5)];
        line.backgroundColor = [TPDialerResourceManager getColorForStyle:@"stream_line_color"];
        [self addSubview:line];
    }
    return self;
}

- (void)setData:(C2CHistoryInfo *)info{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:info.datetime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    timeLabel.text = dateString;
    
    NSString *bonusTime;
    NSString *shareLabel;
    if ( info.bonusType == 1){
        if ( info.bonus >= 0 ){
            bonusTime = [NSString stringWithFormat:@"%dMB",info.bonus];
            shareLabel = [NSString stringWithFormat:@"%@%@%@%@%@",NSLocalizedString(@"stream_sharelabel_title1", ""),info.eventName,NSLocalizedString(@"stream_sharelabel_title2", ""),bonusTime,NSLocalizedString(@"stream_sharelabel_title3", "")];
        }else{
            bonusTime = [NSString stringWithFormat:@"%dMB",-info.bonus];
            shareLabel = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"stream_sharelabel_title4", ""),bonusTime,NSLocalizedString(@"stream_sharelabel_title3", "")];
        }
    }else{
        bonusTime = [NSString stringWithFormat:@"%d分钟",info.bonus/60];
        shareLabel = [NSString stringWithFormat:@"%@%@%@%@",NSLocalizedString(@"stream_sharelabel_title1", ""),info.eventName,NSLocalizedString(@"stream_sharelabel_title2", ""),bonusTime];
    }
    
    NSRange range1;
    NSRange range2;
    NSRange range3;
    NSRange range4 = NSMakeRange (0, 0);
    NSRange range5 = NSMakeRange (0, 0);
    
    if ( info.bonusType == 1 && info.bonus < 0 ){
        range1 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title4", "")];
        range2 = [shareLabel rangeOfString:bonusTime];
        range3 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title3", "") options:NSBackwardsSearch];
    }else{
        range1 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title1", "")];
        range2 = [shareLabel rangeOfString:info.eventName];
        range3 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title2", "")];
        range4 = [shareLabel rangeOfString:bonusTime];
        range5 = [shareLabel rangeOfString:NSLocalizedString(@"stream_sharelabel_title3", "") options:NSBackwardsSearch];
    }
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:shareLabel];
    [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_text_color"] range:range1];
    [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_first_color"]  range:range2];
    [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_text_color"] range:range3];
    if ( info.bonusType == 1) {
        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_third_color"] range:range4];
    }else{
        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_second_color"] range:range4];
    }
    [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"stream_mainlabel_text_color"] range:range5];
    
    mainLabel.attributedText = str;
    
}
@end
