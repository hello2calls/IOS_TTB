//
//  YYCycleViewCell.m
//  YYCycleScrollView
//
//  Created by yuyuan on 15/7/25.
//  Copyright (c) 2015年 yuyuan. All rights reserved.
//

#import "YYCycleViewCell.h"
#import "TPDialerResourceManager.h"
@interface YYCycleScrollContnentCell ()

@property(nonatomic, strong) UILabel *contentLabel;

@end

@implementation YYCycleScrollContnentCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];

  if (self) {
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.backgroundColor = [UIColor clearColor];
    self.contentLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    self.contentLabel.textAlignment = NSTextAlignmentCenter;
    self.contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.contentLabel];
  }

  return self;
}

- (void)setContent:(NSString *)content {
  self.contentLabel.text = content;
  [self setNeedsLayout];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  if (self.contentLabel.text.length > 0) {
    self.contentLabel.hidden = NO;
    [self.contentLabel sizeToFit];
    self.contentLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame),
                                         CGRectGetHeight(self.frame)/2);
  } else {
    self.contentLabel.hidden = YES;
  }
}

@end

@interface YYCycleViewCell()
@property(nonatomic,strong)NSArray *contentArray;

@end

@implementation YYCycleViewCell

- (instancetype)initWithFrame:(CGRect)frame font:(UIFont *)textFont contentArray:(NSArray *)contentArray fullDuriation:(NSTimeInterval)fullDuriation animationDuration:(NSTimeInterval)animationDuration {
  self = [super initWithFrame:frame];
  self.contentArray = [NSMutableArray arrayWithArray:contentArray];
  self.cyclelView = [[YYCycleScrollView alloc] init];
  self.cyclelView.delegate = self;
  self.cyclelView.dataSource = self;
  self.cyclelView.animationDuration = animationDuration;
  self.cyclelView.delayTime = fullDuriation/(contentArray.count);
  self.cyclelView.backgroundColor = [UIColor clearColor];
  self.backgroundColor = [UIColor clearColor];
  self.textFont = textFont;
  [self addSubview:self.cyclelView];
  return self;
}


- (void)layoutSubviews {
  [super layoutSubviews];
  self.cyclelView.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,
                                     CGRectGetHeight(self.frame));
}
#pragma mark - YYCycleScrollViewDataSource
- (YYCycleScrollViewCell *)cycleView:(YYCycleScrollView *)cycleView
               cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellWithIdentifier = @"contentCell";

  YYCycleScrollContnentCell *cell = (YYCycleScrollContnentCell *)[cycleView
      dequeueReusableCellWithIdentifier:cellWithIdentifier];
  if (cell == nil) {
    cell = [[YYCycleScrollContnentCell alloc]
        initWithReuseIdentifier:cellWithIdentifier];
      cell.contentLabel.font = self.textFont;
  }

  cell.content = self.contentArray[indexPath.row];

  return cell;
}

- (NSInteger)rowsOfCycle {
  return self.contentArray.count;
}
@end
