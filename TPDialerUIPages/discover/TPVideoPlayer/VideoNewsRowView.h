//
//  VideoNewsRowView.h
//  TouchPalDialer
//
//  Created by siyi on 2016-11-30.
//
//

#ifndef VideoNewsRowView_h
#define VideoNewsRowView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YPUIView.h"
#import "TPDLib.h"
#import "FindNewsItem.h"

#define VIDEO_LINE_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12]
#define VIDEO_TITLE_COLOR [UIColor blackColor]
#define VIDEO_SUBTITLE_COLOR [UIColor colorWithHexString:@"0Xb3b3b3"]

#define VIDEO_TITLE_FONT_SIZE (18)
#define VIDEO_SUBTITLE_FONT_SIZE (12)

@interface VideoNewsRowView : YPUIView

@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *preivewImageView;
@property (nonatomic, strong) UILabel *videoTimeLabel;

@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, strong) FindNewsItem *item;

- (void) updateUIWithItem:(FindNewsItem *)item;

@end

#endif /* VideoNewsRowView_h */
