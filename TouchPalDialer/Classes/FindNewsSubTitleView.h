//
//  FindNewsTitleView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/24.
//
//

#import <UIKit/UIKit.h>
#import "VerticallyAlignedLabel.h"

@interface FindNewsSubTitleView : UIView

@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSArray* hots;
@property(nonatomic, strong) NSArray* highLightFlags;
@property(nonatomic, assign) BOOL isAd;
@property(nonatomic, assign) BOOL isLeft;

+(CGFloat) getHeightByTitle:(NSString *)subTitle withWidth:(CGFloat) width;
@end
