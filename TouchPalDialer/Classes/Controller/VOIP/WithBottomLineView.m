//
//  bottomLineView.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-6.
//
//

#import "WithBottomLineView.h"
#import "TPDialerResourceManager.h"
#import "VoipConsts.h"
#import "UserDefaultsManager.h"
@implementation WithBottomLineView

- (id) initWithFrame:(CGRect)frame withTitle:(NSString *)title  withDescription:(NSString *)description ifParticipate:(BOOL)ifParticipate{
    self = [super initWithFrame:frame];
    
    if (self){
        self.backgroundColor = [UIColor clearColor];
        
        BOOL doubleLine = description && description.length > 0;
        CGFloat titleY = doubleLine ? 14 : (frame.size.height - FONT_SIZE_3_5) / 2;
        NSRange leftRange = [title rangeOfString:@"("];
        NSRange rightRange = [title rangeOfString:@")"];
        NSAttributedString *attributeString = nil;
        if (leftRange.length>0 && rightRange.length>0) {
            if (ifParticipate) {
                  attributeString = [[NSAttributedString alloc] initWithString: [title substringWithRange:NSMakeRange(leftRange.location, rightRange.location-leftRange.location+1)] attributes:@{NSForegroundColorAttributeName:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"]}];
            }else{
                attributeString = [[NSAttributedString alloc] initWithString: [title substringWithRange:NSMakeRange(leftRange.location, rightRange.location-leftRange.location+1)] attributes:@{NSForegroundColorAttributeName:[TPDialerResourceManager getColorForStyle:@"tp_color_orange_500"]}];
            }
           
        }
        UILabel *shareVOIPLabel;
        if (attributeString!=nil) {
            shareVOIPLabel = [[UILabel alloc] init];
            shareVOIPLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
            shareVOIPLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_mainLabel_text_color"];
            CGRect rect;
            shareVOIPLabel.text =[title substringWithRange:NSMakeRange(0, leftRange.location)];

            if (SYSTEM_VERSION_LESS_THAN(iOS7_0)) {
                //version < 7.0
                
                rect.size =  [shareVOIPLabel.text sizeWithFont:shareVOIPLabel.font];
                rect.origin=CGPointMake(0, 0);
            }
            else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
             rect= [shareVOIPLabel.text boundingRectWithSize:CGSizeMake(2000, FONT_SIZE_3_5) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:shareVOIPLabel.font} context:nil];
            }
            shareVOIPLabel.frame=  CGRectMake(16, titleY, rect.size.width, FONT_SIZE_3_5);
            [self addSubview:shareVOIPLabel];

            UILabel *attributeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shareVOIPLabel.frame)+10, titleY, 150, FONT_SIZE_3_5)];
            attributeLabel.attributedText = attributeString;
            if (SYSTEM_VERSION_LESS_THAN(iOS7_0)) {
            attributeLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4];
            }else{
                 attributeLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
            }
            attributeLabel.frame = CGRectMake( CGRectGetMaxX(shareVOIPLabel.frame)+10, titleY, [@"（已获得邀请码）" sizeWithFont:attributeLabel.font].width, FONT_SIZE_3_5);
            _attributeLabel = attributeLabel;
            _mainTitle =shareVOIPLabel;
            [self addSubview:attributeLabel];
            
        }else{
             shareVOIPLabel= [[UILabel alloc] initWithFrame:CGRectMake(16, titleY, TPScreenWidth() - 60, FONT_SIZE_3_5)];
            shareVOIPLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
            shareVOIPLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_mainLabel_text_color"];
            _mainTitle = shareVOIPLabel;
            shareVOIPLabel.text = title;
            [self addSubview:shareVOIPLabel];

        }
        if (leftRange.length>0 && rightRange.length>0){
        _dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_attributeLabel.frame), shareVOIPLabel.frame.origin.y, 35, 14)];
        _dotLabel.text = @"NEW";
        _dotLabel.textAlignment = NSTextAlignmentCenter;
        _dotLabel.font = [UIFont systemFontOfSize:10];
        _dotLabel.textColor = [UIColor whiteColor];
        _dotLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        _dotLabel.layer.masksToBounds = YES;
        _dotLabel.layer.cornerRadius = 7;
        _dotLabel.hidden = [UserDefaultsManager boolValueForKey:hide_voip_oversea_lable_point defaultValue:NO];
        [self addSubview:_dotLabel];
        }
        
        if (doubleLine) {
            UILabel *suggestionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 44, TPScreenWidth() - 60, FONT_SIZE_5_5)];
            suggestionLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5_5];
            suggestionLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_subLabel_text_color"];
            suggestionLabel.text = description;
            [self addSubview:suggestionLabel];
            _subTitle = suggestionLabel;
        }
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(16, frame.size.height-1, frame.size.width-32, 1)];
        bottomLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_line_color"];
        [self addSubview:bottomLine];
        
    }
    
    return self;
}

-(void)refreshWithTitle:(NSString *)title{
    NSAttributedString *attributeString;
    BOOL ifParticipate =[UserDefaultsManager boolValueForKey:have_participated_voip_oversea];
    if (ifParticipate) {
        attributeString = [[NSAttributedString alloc] initWithString: [title substringWithRange:NSMakeRange(6, 8)] attributes:@{NSForegroundColorAttributeName:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"]}];
    }else{
        attributeString = [[NSAttributedString alloc] initWithString: [title substringWithRange:NSMakeRange(6, 8)] attributes:@{NSForegroundColorAttributeName:[TPDialerResourceManager getColorForStyle:@"tp_color_orange_500"]}];
    }
    _attributeLabel.attributedText = attributeString;
}

@end
