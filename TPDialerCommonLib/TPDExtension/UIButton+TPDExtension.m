//
//  UIButton+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import "UIButton+TPDExtension.h"
#import "TPDExtension.h"
#import <Masonry.h>
#import "TPDLib.h"

@implementation UIButton (TPDExtension)
ADD_DYNAMIC_PROPERTY(UIView*,tpd_icon,setTpd_icon);
ADD_DYNAMIC_PROPERTY(UILabel*,tpd_text1,setTpd_text1);
ADD_DYNAMIC_PROPERTY(UILabel*,tpd_text2,setTpd_text2);
ADD_DYNAMIC_PROPERTY(NSArray*,tpd_subviews,setTpd_subviews);

ADD_DYNAMIC_PROPERTY(void (^)(id sender),tpd_whenClicked,setTpd_whenClicked)


+ (UIButton *)tpd_buttonStyleVerticalImageLabel:(NSArray *)arr withBlock:(void (^)(id sender))block
{
    UIView* ret = [[UIView alloc] init];
    
    UIView *icon = [UIImageView tpd_imageView:arr[0]];
    
    UILabel *label1 = [[UILabel tpd_commonLabel] tpd_withText:arr[1] color:0x000000 font:14];
    label1.numberOfLines = 1;
    label1.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
    label1.textAlignment = NSTextAlignmentCenter;
    
    [ret addSubview:icon];
    [ret addSubview:label1];
    
    [icon makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(ret);
    }];
    
    [label1 makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(icon).offset(30);
        make.centerX.bottom.equalTo(ret);
        
    }];
    
    
    UIButton* button = [[ret tpd_wrapper] tpd_wrapperWithButton];
    button.tpd_icon = icon;
    button.tpd_text1 = label1;
    button.tpd_subviews = @[button.tpd_icon,button.tpd_text1];
    [button tpd_withBlock:^(id sender){
        block(sender);
    }];
    
    return button;
}

+ (UIButton *)tpd_buttonStyleVerticalLabel2:(NSArray *)arr withBlock:(void (^)(id sender))block
{
    UIView* ret = [[UIView alloc] init];
    
    UILabel *label1 = [[UILabel tpd_commonLabel] tpd_withText:arr[0] color:RGB2UIColor(0x111111) font:10];
    label1.numberOfLines = 1;
    label1.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = RGB2UIColor(0x111111);

    
    UILabel *label2 = [[UILabel tpd_commonLabel] tpd_withText:arr[1] color:RGB2UIColor(0x22d18e) font:14];
    label2.numberOfLines = 1;
    label2.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = RGB2UIColor(0x111111);


    
    [ret addSubview:label1];
    [ret addSubview:label2];
    
    [label1 makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(ret);
        make.width.lessThanOrEqualTo(ret);
        
    }];
    
    [label2 makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label1.bottom).offset(10);
        make.centerX.bottom.equalTo(ret);
        make.width.lessThanOrEqualTo(ret);
    }];
    
    UIButton* button = [[ret tpd_wrapper] tpd_wrapperWithButton];
    button.tpd_text1 = label1;
    button.tpd_text2 = label2;
    button.tpd_subviews = @[button.tpd_text1,button.tpd_text2];
    [button tpd_withBlock:^(id sender){
        block(sender);
    }];
    
    
    return button;
}

-(UIButton*)tpd_withBlock:(void (^)(id sender))block{
    WEAK(self)
    [self addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
        block(weakself);
    }];
    return self;
}


-(UIButton*)tpd_withOffset:(NSArray*)offsets{
    for (int i=0; i<offsets.count; i++) {
        UIView* v1 = self.tpd_subviews[i];
        UIView* v2 = self.tpd_subviews[i+1];
        if ([v1 isKindOfClass:[UIImageView class]]) {
            [v2 updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(v1).offset(offsets[i]);
            }];
        }else{
            [v2 updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(v1.bottom).offset(offsets[i]);
            }];
        }
        
    }
    return self;
}

+(UIButton*)tpd_buttonStyleCommon{
    UIButton* ret = [[UIButton alloc] init];
    ret.adjustsImageWhenHighlighted = NO;
    return ret;
}

@end
