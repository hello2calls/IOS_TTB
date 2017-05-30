//
//  IconFontImageView.m
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 15/11/24.
//
//

#import <Foundation/Foundation.h>
#import "VerticallyAlignedLabel.h"
#import "TPDialerResourceManager.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "IconFontImageView.h"
#import "IndexJsonUtils.h"
#import "UIDataManager.h"
#import "PublicNumberMessageView.h"
#import "UserDefaultsManager.h"
#import "UpdateService.h"
#import "UIFont+Custom.h"
#import "UIImage+wiRoundedRectImage.h"

@implementation IconFontImageView : UIView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, YP_ICON_TOP_MARGIN, self.frame.size.width, self.frame.size.height - YP_ICON_TOP_MARGIN)];
    self.label = label;
    self.label.hidden = YES;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.verticalAlignment = VerticalAlignmentMiddle;
    self.labelFontSize = 25.0f;
    self.backgroundColor = [UIColor clearColor];

    self.iconFontImageRect = CGRectMake(0, 0 ,0, 0);
    [self addSubview:self.label];
    return self;
}

- (void) resetFrameWithData:(BaseItem *)item
{
    self.icon = nil;
    self.label.text = nil;
    if (item) {
        self.label.text = item.font;
        self.font = [UIFont fontWithName:[UIDataManager instance].indexFontName size:self.labelFontSize];
        if (item.font && item.font.length > 0 && [UIDataManager instance].indexFontName && [UIDataManager instance].indexFontName.length > 0 && [self.font fontContainsString: item.font]) {
            self.label.font = self.font;

            float height = self.frame.size.height - YP_ICON_MARGIN * 2;
            self.iconFontImageRect = CGRectMake(0 , 0, self.frame.size.width, height);
            [self setTextSize];
            self.label.textColor = [ImageUtils colorFromHexString:item.fontColor andDefaultColor:[[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"header_btn_color"]];

        } else {
            if (!self.item || ![item.identifier isEqual:self.item.identifier]) {
                NSString* filePath = nil;
                filePath = [NSString stringWithFormat:@"%@%@", [[UpdateService instance] getWebSearchPath],[item iconPath]];
                self.icon = [ImageUtils getImageFromFilePath:filePath];
            }

            if (self.icon == nil) {
                self.url = item.iconLink;
                self.icon = [ImageUtils getImageFromLocalWithUrl:self.url];
            }
            if (self.icon == nil) {
                [self performSelectorInBackground:@selector(downloadImageFromNetwork) withObject:nil];
            }

            float _scaleRatio = 1;
            self.label.hidden = YES;
            float iconWidth = self.frame.size.width;
            float iconHeight = self.frame.size.height - YP_ICON_MARGIN * 2;
            if (self.icon.size.height >= self.icon.size.width) {
                _scaleRatio = self.icon.size.width / self.icon.size.height;
                iconWidth = _scaleRatio * iconHeight;
            } else {
                _scaleRatio = self.icon.size.height / self.icon.size.width;
                iconHeight = _scaleRatio * iconHeight;
            }

            int startX = (self.frame.size.width - iconWidth) / 2;
            int startY = (self.frame.size.height - iconHeight) / 2 + YP_ICON_TOP_MARGIN;
            self.iconFontImageRect = CGRectMake(startX , startY, iconWidth, iconHeight);
            self.icon = [UIImage createRoundedRectImage:self.icon size:self.icon.size radius:16];

            self.item = item;

        }
    }
    [self setNeedsDisplay];
}

- (void) setTextSize
{
    if (self.label.text) {
        CGSize sizeTitle = [self.label.text  sizeWithFont:self.label.font constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
        while (sizeTitle.height < self.iconFontImageRect.size.height) {
            self.labelFontSize = self.labelFontSize + 1;
            self.label.font = [UIFont fontWithName:[UIDataManager instance].indexFontName size:self.labelFontSize];
            sizeTitle = [self.label.text  sizeWithFont:self.label.font constrainedToSize:CGSizeMake(50, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
        }
        self.labelFontSize = self.labelFontSize - 1;
        self.label.font =[UIFont fontWithName:[UIDataManager instance].indexFontName size:self.labelFontSize];

    }
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    if (self.label.text && [UIDataManager instance].indexFontName && [self.font fontContainsString: self.label.text]) {
        self.label.hidden = NO;
    } else {
        self.label.hidden = YES;
        [self.icon drawInRect:self.iconFontImageRect];
    }
}


- (void)downloadImageFromNetwork
{
    if (self.url) {

        NSString* downloadUrl = self.url;
        BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:self.url] withUrl:self.url];
        if(save){
            dispatch_sync(dispatch_get_main_queue(), ^{
                if ([downloadUrl isEqualToString:self.url]) {
                    self.icon = [ImageUtils getImageFromLocalWithUrl:self.url];
                    [self resetFrameWithData:self.item];
                }
            });
        }
    }

}

@end
