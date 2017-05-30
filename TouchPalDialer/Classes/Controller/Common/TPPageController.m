//
//  TPPageController.m
//  TouchPalDialer
//
//  Created by Admin on 8/5/13.
//
//

#import "TPPageController.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
@implementation TPPageController

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    activeImage = [[TPDialerResourceManager sharedManager] getImageByName:@"tools_flash_dot_ht@2x.png"];
    inactiveImage = [[TPDialerResourceManager sharedManager] getImageByName:@"tools_flash_dot_normal@2x.png"];
    return self;
}
-(void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIView* dot = [self.subviews objectAtIndex:i];
        if ([dot isKindOfClass:[UIImageView class]]) {
            if (i == self.currentPage) {
                ((UIImageView *)dot).image = activeImage;
            } else {
                ((UIImageView *)dot).image = inactiveImage;
            }
        } else {
            if (i == self.currentPage) {
                dot.backgroundColor = [[TPDialerResourceManager sharedManager]
                                       getUIColorFromNumberString:@"pageControllerActive_color"];
            } else {
                dot.backgroundColor = [[TPDialerResourceManager sharedManager]
                                       getUIColorFromNumberString:@"pageControllerNormal_color"];
            }
        }
    }
}
-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}
- (id)selfSkinChange:(NSString *)style{
    activeImage = [[TPDialerResourceManager sharedManager] getImageByName:@"tools_flash_dot_ht@2x.png"];
    inactiveImage = [[TPDialerResourceManager sharedManager] getImageByName:@"tools_flash_dot_normal@2x.png"];
    [self updateDots];
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return  toTop;
}

@end

