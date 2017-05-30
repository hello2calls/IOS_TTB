//
//  TPUISearchBar.m
//  TouchPalDialer
//
//  Created by 史玮 阮 on 13-8-2.
//
//

#import "TPUISearchBar.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
@implementation TPUISearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if ([ self respondsToSelector : @selector (barTintColor)]) {
            [self setBarTintColor:[ UIColor clearColor ]];
        }
        else{
            self.layer.shadowColor = [UIColor clearColor].CGColor;
            for (UIView *subview in self.subviews) {
                if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
                {
                    [subview removeFromSuperview];
                    continue;
                }
                if ([subview isKindOfClass:[UITextField class]])
                {
                    UITextField *field = (UITextField *)subview;
                    field.background = nil;
                    [field setBorderStyle:UITextBorderStyleNone];
                    field.layer.cornerRadius = 4;
                }
            }
        }
        [self hideBorder];
    }
    return self;
}

- (void)showBorder {
    if ([ self respondsToSelector : @selector (barTintColor)]) {
        UIView *view = (UITextField*)[self.subviews objectAtIndex: 0];
        view.layer.borderColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[TPUISearchBar colorString]].CGColor;
        view.layer.borderWidth = 1.0f;
    }else{
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                subview.layer.borderColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[TPUISearchBar colorString]].CGColor;
                subview.layer.borderWidth = 1.0f;
                
            }
        }
    }
    
}

- (void)hideBorder {
    if ([ self respondsToSelector : @selector (barTintColor)]) {
        UIView *view = (UITextField*)[self.subviews objectAtIndex: 0];
        view.layer.borderColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[TPUISearchBar colorString]].CGColor;
        view.layer.borderWidth = 1.0f;


    }else{
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                subview.layer.borderColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[TPUISearchBar colorString]].CGColor;
                subview.layer.borderWidth = 1.0f;
                [(UITextField *)subview setBackground:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_header_bg@2x.png"]];

            }
        }
    }
}

- (id)selfSkinChange:(NSString *)style {
    if ([ self respondsToSelector : @selector (barTintColor)]) {
        UIView *view = [self.subviews objectAtIndex: 0];
        view.layer.borderColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[TPUISearchBar colorString]].CGColor;
        view.layer.borderWidth = 1.0f;
        [self setBarTintColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[TPUISearchBar colorString]]];
        for ( UIView *subView in [(UITextField*)[self.subviews objectAtIndex: 0] subviews] ){
            if ([subView isKindOfClass:[UITextField class]]){
                UITextField *tempt = ((UITextField *)subView);
                subView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"UITPSearchBarTextField_color"];
                
                tempt.textColor = [TPDialerResourceManager getColorForStyle:@"UITPSearchBar_text_color"];
            }
        }
    }else{
        self.backgroundColor=[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[TPUISearchBar colorString]];
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                UITextField *tempt = ((UITextField *)subview);
                subview.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[TPUISearchBar colorString]];
                tempt.textColor = [TPDialerResourceManager getColorForStyle:@"UITPSearchBar_text_color"];
            }
        }
    }
    [self hideBorder];
    NSNumber * toTop = [NSNumber numberWithBool:YES];
    return toTop;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setPlaceholder:(NSString *)placeholder{
    UITextField *tempt = nil;
    if ([ self respondsToSelector : @selector (barTintColor)]) {
        for ( UIView *subView in [(UITextField*)[self.subviews objectAtIndex: 0] subviews] ){
            if ([subView isKindOfClass:[UITextField class]]){
                tempt = (UITextField *)subView;
                break;
            }
        }
    }else{
        for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:[UITextField class]])
            {
                tempt = (UITextField *)subView;
            }
        }
    }
    [tempt setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:[TPDialerResourceManager getColorForStyle:@"UITPSearchBar_placeholder_color"]}]];
}

+ (NSString *)colorString {
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        return @"skinSectionIndexPopupBackground_color";
    }else{
        return @"UITPSearchBarBackground_color";
    }

}

@end
