//
//  CallLogTitleView.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CallLogTitleView.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"

#define CALL_LOG_TITLE_TAB_ALL 0
#define CALL_LOG_TITLE_TAB_TYPES 1

@implementation CallLogTitleView
@synthesize titleLabel;
@synthesize delegate;
@synthesize isJBCallog;
@synthesize showSubItemsView;

+ (id)createCallLogTitle:(BOOL)isJB
{
    if (isJB) {
         return [[CallLogTitleView alloc] initWithFrame:CGRectMake((TPScreenWidth() - 172) / 2, TPHeaderBarHeightDiff(), 172, 45)];
    } else {
         return [[CallLogTitleView alloc] initWithFrame:CGRectMake((TPScreenWidth() - 172) / 2, TPHeaderBarHeightDiff(), 172, 45)
                                               withTitle:NSLocalizedString(@"Recent calls", @"")];
    }
}

// for JB
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
        titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
        titleLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Outgoing_logs",@""), @" "];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        showSubItemsView = [[UIImageView alloc]init];
        showSubItemsView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"more_diallog_normal@2x.png"];
        [self addSubview:showSubItemsView];
        
        UIButton *maskBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        maskBtn.backgroundColor = [UIColor clearColor];
        [maskBtn addTarget:self action:@selector(showTypes) forControlEvents:UIControlEventTouchDown];
        [self addSubview:maskBtn];
    }
    return self;
}

// for non-JB
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
        titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
        titleLabel.text = NSLocalizedString(@"Recent calls",@"");
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)clickAll
{
    [titleBar clickTabIndex:CALL_LOG_TITLE_TAB_ALL];
}

#pragma mark HeadTabBarDelegate

- (void)showTypes
{
    [delegate callLogTitleTabTypesClicked];
}

- (void)onClickAtIndexBar:(NSInteger)index{
    switch (index) {
        case CALL_LOG_TITLE_TAB_ALL:
            [delegate callLogTitleTabAllClicked];
            break;
        case CALL_LOG_TITLE_TAB_TYPES:
            [delegate callLogTitleTabTypesClicked];
            break;   
        default:
            break;
    }    
}

- (void)dealloc
{
    [SkinHandler removeRecursively:self];
}

- (id)selfSkinChange:(NSString *)style
{
    if (isJBCallog) {
        [titleBar setSkinStyleWithHost:self forStyle:@"default_headtabbar_style"];
        showSubItemsView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"more_diallog_normal@2x.png"];
    }else {
        NSDictionary *operDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
        if([operDic objectForKey:TEXT_COLOR_FOR_STYLE]){
            textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:TEXT_COLOR_FOR_STYLE]];
        }
        if([operDic objectForKey:BACK_GROUND_COLOR]){
            NSString *colorString = [operDic objectForKey:BACK_GROUND_COLOR];
            if([colorString isEqualToString:CLEAR_COLOR]){
                textLabel.backgroundColor = [UIColor clearColor];
            }else{
                textLabel.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:colorString];
            }
        }
        if([operDic objectForKey:ICON_IMAGE]){
            NSMutableDictionary *customDic = [[NSMutableDictionary alloc] initWithCapacity:1];
            [customDic setValue:[operDic objectForKey:ICON_IMAGE] forKey:BACK_GROUND_IMAGE];
            NSString *styleName = @"Code_ImageUtilityView_style";
            [((TPDialerResourceManager *)[TPDialerResourceManager sharedManager]).codePropertyDic setValue:customDic forKey:styleName];
        }
    }
    
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}
@end
