//
//  HangupMiddleView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/11.
//
//

#import "HangupMiddleView.h"
#import "VoipConsts.h"
#import "TPDialerResourceManager.h"

@implementation HangupMiddleView {
    MiddleViewModel *_model;
    CGFloat _labelHeight;
    CGFloat _altLabelHeight;
    UIFont *_labelFont;
    UIFont *_altLabelFont;
    CGFloat _gap;
    UIColor *_labelTextColor;
    CGFloat _iconWidth;
    CGFloat _iconHeight;
    CGFloat _topGap;
}

- (id)initWithMiddleModel:(MiddleViewModel *)model {
    _model = model;
    CGFloat height = 0;
    CGFloat width = 0;
    _gap = TPScreenHeight() > 500 ? 46 *WIDTH_ADAPT : 15;

    if (model.text) {
        if (_model.isError) {
            _topGap = TPScreenHeight() > 500 ? 100 *WIDTH_ADAPT : 50;
            width =  TPScreenWidth() - 2*50;
            height += model.icon.size.height;
            _iconWidth = model.icon.size.width * WIDTH_ADAPT;
            _iconHeight = model.icon.size.height * WIDTH_ADAPT;
            
            if (TPScreenHeight() < 500) {
                _topGap = 40;
            }
            _labelFont = [UIFont systemFontOfSize:14*WIDTH_ADAPT];
            CGSize size = [model.text sizeWithFont:_labelFont constrainedToSize:CGSizeMake(width, 60)];
            _labelHeight =size.height+2;
            height += _labelHeight;
            _labelTextColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_450"];
        }
        
        else {
            _topGap = TPScreenHeight() > 500 ? 70 *WIDTH_ADAPT : 50;
            width = TPScreenWidth() - 2*30;
            _iconWidth = model.icon.size.width * WIDTH_ADAPT;
            _iconHeight = model.icon.size.height * WIDTH_ADAPT;
            height += _iconHeight;
            _labelFont = [UIFont systemFontOfSize:model.highlightText ? 19 : 17];
            CGSize size = [model.text sizeWithFont:_labelFont constrainedToSize:CGSizeMake(width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
            _labelHeight = size.height;
            height += _labelHeight;
            _labelTextColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_800"];
            if (TPScreenHeight() < 500) {
                _topGap = 25;
            }
        }
    }
    height += _topGap;
    height += _gap;
    if (model.altText) {
        height += 10;
        _altLabelFont = [UIFont systemFontOfSize:16];
        CGSize size = [model.text sizeWithFont:_altLabelFont constrainedToSize:CGSizeMake(width, 60)];
        _altLabelHeight = size.height;
        height += _altLabelHeight;
    }
    return [self initWithFrame:CGRectMake(0, 0, width, height)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (TPScreenHeight()>600) {
            _topGap+=10;
        }else{
            _topGap+=20;
        }
        CGFloat y = _topGap;
        if (_model.icon) {
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - _iconWidth)/2 ,_topGap, _iconWidth, _iconHeight)];
            iconView.image = _model.icon;
            [self addSubview:iconView];
            y = CGRectGetMaxY(iconView.frame)+12;
        }
        if (_model.text) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, frame.size.width, _labelHeight)];
            label.textColor  = _labelTextColor;
            label.backgroundColor = [UIColor clearColor];
            label.font = _labelFont;
            if (_model.isError) {
                label.numberOfLines = 0;
            }
            [self addSubview:label];
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_model.text];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:2];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_model.text length])];
            label.attributedText = attributedString;
            y += (_labelHeight +4);
        }
        
        if (_model.altText) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, frame.size.width, _altLabelHeight)];
            label.textColor  = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];
            label.backgroundColor = [UIColor clearColor];
            label.font = _altLabelFont;
            label.text = _model.altText;
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
        }
        
        
    }
    return self;
}


@end
