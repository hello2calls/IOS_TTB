//
//  FeatureTipsLabel.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    LabelTextAligmentLeft,
    LabelTextAligmentCenter,
    LabelTextAligmentRight,
}TipsLabelTextAligment;

@interface FeatureTipsLabel : UIView{

}

- (id)initWithFrame:(CGRect)frame withLeftImage:(UIImage *)leftImage withRightImage:(UIImage *)rightImage withTitleString:(NSString *) title withUITextAligment:(TipsLabelTextAligment)aligment;

@end
