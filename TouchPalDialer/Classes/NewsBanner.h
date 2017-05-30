//
//  NewsBanner.h
//  NewsBannerDemo
//
//  Created by sunhao－iOS on 16/4/28.
//  Copyright © 2016年 ssyzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAutoUpTextLable.h"
#import "UIView+TPDExtension.h"
@class NewsBanner;
@protocol NewsBannerDelegate<NSObject>

- (void)NewsBanner:(NewsBanner *)newsBanner didSelectIndex:(NSInteger)selectIndex;

@end
@interface NewsBanner : UIView

@property (nonatomic ,strong) CustomAutoUpTextLable *textView;

@property (nonatomic ,strong) UILabel *leftLabelView;
@property (nonatomic ,strong) UILabel *rightLabelView;
@property(nonatomic,assign)NSTimeInterval pushDuration;
@property(nonatomic,assign)NSTimeInterval lableDuration;
@property (nonatomic ,strong) NSArray *leftAndNumberStringList;
- (void)star;
- (void)stop;
@end
