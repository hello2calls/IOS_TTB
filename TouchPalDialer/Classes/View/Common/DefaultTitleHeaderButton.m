//
//  DefaultTitleHeaderButton.m
//  TouchPalDialer
//
//  Created by game3108 on 15/2/13.
//
//

#import "DefaultTitleHeaderButton.h"
#import "TPDialerResourceManager.h"

@implementation DefaultTitleHeaderButton
- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    if([propertyDic objectForKey:@"textColor_color"]!=nil){
        [self setTitleColor:[TPDialerResourceManager getColorForStyle:[propertyDic objectForKey:@"textColor_color"]] forState:UIControlStateNormal];
    }
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}
@end
