//
//  TPButtonColorManager.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/14.
//
//

#import "TPButtonColorManager.h"
#import "TPDialerResourceManager.h"

@implementation TPButtonColorManager

@synthesize layerNormalColor;
@synthesize layerHightlightColor;
@synthesize layerDisabledColor;
@synthesize bodyNormalColor;
@synthesize bodyHightlightColor;
@synthesize bodyDisabledColor;
@synthesize titleNormalColor;
@synthesize titleHightlightColor;
@synthesize titleDisabledColor;
@synthesize subtitleNormalColor;
@synthesize subtitleHightlightColor;
@synthesize subtitleDisableColor;

- (instancetype)initWithType:(ButtonType)type {
    self = [super init];
    if (self) {
        switch (type) {
            case GRAY_LINE:
                self.layerNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
                self.layerHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
                self.layerDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
                self.bodyNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
                self.bodyHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
                self.bodyDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
                self.titleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                self.titleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                self.titleDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
                self.subtitleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                self.subtitleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                self.subtitleDisableColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
                break;
            case BLUE_LINE:
                self.layerNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
                self.layerHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
                self.layerDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_50"];
                self.bodyNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
                self.bodyHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_50"];
                self.bodyDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
                self.titleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
                self.titleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
                self.titleDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_50"];
                self.subtitleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
                self.subtitleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
                self.subtitleDisableColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
                break;
            case GREEN_SOLID:
                self.layerNormalColor = [UIColor clearColor];
                self.layerHightlightColor = [UIColor clearColor];
                self.layerDisabledColor = [UIColor clearColor];
                self.bodyNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
                self.bodyHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_700"];
                self.bodyDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_50"];
                self.titleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
                self.titleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
                self.titleDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
                self.subtitleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_600"];
                self.subtitleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_600"];
                self.subtitleDisableColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
                break;
            case BLUE_SOLID:
                self.layerNormalColor = [UIColor clearColor];
                self.layerHightlightColor = [UIColor clearColor];
                self.layerDisabledColor = [UIColor clearColor];
                self.bodyNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
                self.bodyHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_700"];
                self.bodyDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_50"];
                self.titleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
                self.titleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
                self.titleDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
                self.subtitleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_600"];
                self.subtitleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_600"];
                self.subtitleDisableColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
                break;
            case ORANGE_SOLID:
                self.layerNormalColor = [UIColor clearColor];
                self.layerHightlightColor = [UIColor clearColor];
                self.layerDisabledColor = [UIColor clearColor];
                self.bodyNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_500"];
                self.bodyHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_700"];
                self.bodyDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_50"];
                self.titleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
                self.titleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
                self.titleDisabledColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
                self.subtitleNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_600"];
                self.subtitleHightlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_600"];
                self.subtitleDisableColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
                break;
            default:
                break;
        }

    }
    return self;
}

@end
