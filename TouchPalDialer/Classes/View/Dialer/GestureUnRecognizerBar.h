//
//  GestureUnRecognizerBar.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-6-21.
//  Copyright (c) 2012å¹?__MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WithSkin.h"

#import "TPUIButton.h"

typedef enum {
    ButtonModeTypeLabelLeft,
    ButtonModeTypeLabelRight,
    ButtonModeTypeLabelTop,
    ButtonModeTypeLabelBottom,
    ButtonModeTypeLabelCustom,
}ButtonModeType;

@interface TPLabelUIButton : TPUIButton{
    UILabel *iconString;
    UIImageView *iconImageView;
    CGSize customImageSize;
}
@property(nonatomic, retain) UILabel *iconString;
@property(nonatomic, retain) UIImageView *iconImageView;
@property(nonatomic, assign) CGSize customImageSize;

- (void)resetIconString:(NSString *)str;
- (void)resetButton:(UIImage *)icon withTitile:(NSString *)title withModel:(ButtonModeType)type;
@end

@interface GestureUnRecognizerBar : UIView <SelfSkinChangeProtocol>{
    TPLabelUIButton *gestureBtn;
    NSString *keyName;
    TPLabelUIButton *leftBtn;
}
@property(nonatomic, retain) UIImageView * backGroundImage;
@property(nonatomic,retain)TPLabelUIButton *gestureBtn;
@property(nonatomic,retain)NSString *keyName;
-(void)disAppearBar;
@end
