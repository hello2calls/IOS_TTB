//
//  SearchView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#import <Foundation/Foundation.h>
#import "SearchCellView.h"
#import "IndexConstant.h"
#import "SectionSearch.h"
#import "UIDataManager.h"
#import "ImageUtils.h"
#import "CTUrl.h"
#import "NSString+TPHandleNil.h"
#import "LocalStorage.h"
#import "UserDefaultKeys.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "TPDialerResourceManager.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "YellowPageMainTabController.h"
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"

@interface SearchCellView()
    @property(nonatomic, retain)NSString* inputText;
    @property(nonatomic, assign)CGRect selfFrame;
@end

@implementation SearchCellView

- (id) initWithFrame:(CGRect)frame andData:(SectionSearch*)data
{
    self = [super initWithFrame:frame];
    self.selfFrame = frame;
    
    if ([ self respondsToSelector : @selector (barTintColor)]) {
        UITextField *temptField = (UITextField*)[self.subviews objectAtIndex: 0];
        temptField.layer.borderColor = [ImageUtils colorFromHexString:SEARCH_BAR_BG_COLOR andDefaultColor:nil].CGColor;
        temptField.layer.borderWidth = SEARCH_BAR_BORDER_WIDTH;
        [self setBarTintColor:[ImageUtils colorFromHexString:SEARCH_BAR_BG_COLOR andDefaultColor:nil]];
        for ( UIView *subView in [(UITextField*)[self.subviews objectAtIndex: 0] subviews] ){
            if ([subView isKindOfClass:[UITextField class]]){
                subView.backgroundColor = [ImageUtils colorFromHexString:SEARCH_BAR_TEXT_FIELD_COLOR andDefaultColor:nil];
            }
        }
    }else{
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                continue;
            }
            if ([subview isKindOfClass:[UITextField class]])
            {
                ((UITextField *)subview).background = nil;
                [((UITextField *)subview) setBorderStyle:UITextBorderStyleNone];
            }
        }
        
        self.backgroundColor = [ImageUtils colorFromHexString:SEARCH_BAR_BG_COLOR andDefaultColor:nil];
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                subview.backgroundColor = [ImageUtils colorFromHexString:SEARCH_BAR_TEXT_FIELD_COLOR andDefaultColor:nil];
            }
        }
    }
    
    [self hideBorder];
    
    self.item = data;
    self.delegate = self;
    
    [self setPlaceholder:data.tips];
    [UIDataManager instance].searchBar = self;
    
    return self;
}

- (void)showBorder {
    if ([ self respondsToSelector : @selector (barTintColor)]) {
        UITextField *temptField = (UITextField*)[self.subviews objectAtIndex: 0];
        temptField.layer.borderColor = [ImageUtils colorFromHexString:SEARCH_BAR_BG_COLOR andDefaultColor:nil].CGColor;
        temptField.layer.borderWidth = 1.0f;
    }else{
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                subview.layer.borderColor = [ImageUtils colorFromHexString:SEARCH_BAR_BG_COLOR andDefaultColor:nil].CGColor;
                subview.layer.borderWidth = 1.0f;
            }
        }
    }
    
}

- (void)hideBorder {
    if ([ self respondsToSelector : @selector (barTintColor)]) {
        UITextField *temptField = (UITextField*)[self.subviews objectAtIndex: 0];
        temptField.layer.borderColor = [ImageUtils colorFromHexString:SEARCH_BAR_BG_COLOR andDefaultColor:nil].CGColor;
        temptField.layer.borderWidth = 1.0f;
        
    }else{
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                subview.layer.borderColor = [ImageUtils colorFromHexString:SEARCH_BAR_BG_COLOR andDefaultColor:nil].CGColor;
                subview.layer.borderWidth = 1.0f;
            }
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self resignFirstResponder];
    if (USE_DEBUG_SERVER){
        NSString *text = self.inputText;
        NSString *backDoorRe = @"^##(-?\\d{1,3}(\\.\\d{1,10})?),(-?\\d{1,3}(\\.\\d{1,10})?),(\\D+)##$";
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:backDoorRe options:0  error:&error];
        NSTextCheckingResult *result = [regex firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
        if (result)
        {
            NSString *newString = [text substringWithRange:NSMakeRange(2, text.length - 4)];
            NSArray *array = [newString componentsSeparatedByString:@","];
            if ([array[2] isEqualToString: @"恢复"])
            {
                [LocalStorage setItemForKey:YP_BACKDOOR_LOCATION andValue: @"NO"];
            }
            else if ([array[2] isEqualToString: @"无定位"])
            {
                [LocalStorage setItemForKey:YP_BACKDOOR_LOCATION andValue: @"YES"];
                [LocalStorage setItemForKey:NATIVE_PARAM_LOCATION andValue:[NSString stringWithFormat:@"[%@,%@]", @"", @""]];
                [LocalStorage setItemForKey:NATIVE_PARAM_CITY andValue:@"全国"];
                [LocalStorage setItemForKey:QUERY_PARAM_CITY andValue:@"全国"];
            }
            else
            {
                [LocalStorage setItemForKey:YP_BACKDOOR_LOCATION andValue: @"YES"];
                [LocalStorage setItemForKey:NATIVE_PARAM_LOCATION andValue:[NSString stringWithFormat:@"[%@,%@]", array[1], array[0]]];
                [LocalStorage setItemForKey:QUERY_PARAM_CITY andValue:array[2]];
                [LocalStorage setItemForKey:NATIVE_PARAM_CITY andValue:array[2]];
            }
        }
        else
        {
            [LocalStorage setItemForKey:@"search_term" andValue:self.inputText];
            [self.item.ctUrl startWebView];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_SEARCH_ITEM kvs:Pair(@"action", @"selected"),Pair(@"input", self.inputText), nil];
        }
    }
    else
    {
        //for enable log to file :
        // step 1: enter text "start log" in search text input.
        // step 2: restart app.
        // step 3: do just you want
        // step 4: enter text "end log" in search text input;
        // step 5: open file cootek_log.txt in app document folder
        if ([self.inputText isEqualToString:@"start log"]) {
            [UserDefaultsManager setBoolValue:YES forKey:COLLECT_AND_UPLOAD_LOG];
        } else if ([self.inputText isEqualToString:@"end log"]){
            [UserDefaultsManager setBoolValue:NO forKey:COLLECT_AND_UPLOAD_LOG];
        }
        
        if (searchBar.text != nil && searchBar.text.length > 0) {
            [LocalStorage setItemForKey:@"search_term" andValue:self.inputText];
            [self.item.ctUrl startWebView];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_SEARCH_ITEM kvs:Pair(@"action", @"selected"),Pair(@"input", self.inputText), nil];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.inputText = [NSString nilToEmptyTrimmed:searchText];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self showBorder];
    self.frame = [self superview].bounds;
    [[self superview] viewWithTag:99].hidden = YES;
    [self setAlpha:0.3f];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self hideBorder];
    [[self superview] viewWithTag:99].hidden = NO;
    self.frame = self.selfFrame;
    [self setAlpha:0];
    return YES;
}

- (void) setAlpha:(CGFloat)alpha {
    id controller = [[UIDataManager instance] viewController];
    if ([controller respondsToSelector:@selector(controlAccessoryView:)]) {
        [controller performSelector:@selector(controlAccessoryView:) withObject:@(alpha)];
    }
}

- (void) drawView
{
    [self setNeedsDisplay];
}

- (void)dealloc
{
    if ([UIDataManager instance].searchBar == self) {
        [UIDataManager instance].searchBar = nil;
    }
}

@end
