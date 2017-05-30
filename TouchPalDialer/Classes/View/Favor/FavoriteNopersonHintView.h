//
//  FavoriteNopersonHintView.h
//  TouchPalDialer
//
//  Created by 史玮 阮 on 13-8-19.
//
//

#import <UIKit/UIKit.h>
#import "TPUIButton.h"
#import "UIView+WithSkin.h"

@interface FavoriteNopersonHintView : UIView <SelfSkinChangeProtocol> {
    UIImageView *noFaveView;
    TPUIButton *fav_button;
}
-(id)initWithContactNoUnRegFrame:(CGRect)frame;
@property (nonatomic, retain) UIImageView *noFaveView;
@property (nonatomic, retain) TPUIButton *fav_button;

@end
