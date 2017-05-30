//
//  HeaderBar.m
//  TouchPalDialer
//
//  Created by zhang Owen on 8/20/11.
//  Refactored by Chen Lu 9/6/12.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "HeaderBar.h"
#import "TPDialerResourceManager.h"
@implementation HeaderBar
@synthesize bgView;
@synthesize backView;

- (id)initHeaderBar {
    self = [self initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeaderBarHeight())];
    UIView *viewBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeaderBarHeight())];
    viewBack.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    viewBack.backgroundColor = [UIColor whiteColor];
    self.backView = viewBack;
    
    [self addSubview:viewBack];
    UIImageView *view = [[UIImageView alloc] initWithFrame:self.frame];
    view.backgroundColor = [UIColor clearColor];
    self.bgView = view;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.bgView];
    return self;
}
- (id)initHeaderBarWithTitle:(NSString *)title{
    return [self initHeaderBarWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeaderBarHeight()) title:title];
}

- (id)initHeaderBarWithFrame:(CGRect)frame title:(NSString *)title{
    self = [self initWithFrame:frame];
    UIView *viewBack = [[UIView alloc]initWithFrame:self.frame];
    viewBack.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    viewBack.backgroundColor = [UIColor whiteColor];
    [self addSubview:viewBack];
    UIImageView *view = [[UIImageView alloc] initWithFrame:self.frame];
    self.bgView = view;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.bgView];
    UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    headerTitle.font = [UIFont systemFontOfSize:16];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.text = title;
    headerTitle.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultText_color"];
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    [self addSubview:headerTitle];
    return self;
}
-(id)selfSkinChange:(NSString *)style{
    NSDictionary *property_dic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    NSString* str = [property_dic objectForKey:BACK_GROUND_IMAGE];
    if(str){
        self.bgView.image = [[TPDialerResourceManager sharedManager] getImageByName:str];
    }
    [self setNeedsDisplay];
    NSNumber *toTop = [NSNumber numberWithBool:NO];
    return toTop;
}

- (BOOL) applyDefaultSkinWithStyle :(NSString *) style {
    NSDictionary *property_dic = [[TPDialerResourceManager sharedManager] getPropertyDicInDefaultPackageByStyle:style];
    NSString* str = [property_dic objectForKey:BACK_GROUND_IMAGE];
    if(str){
        self.bgView.image = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:str];
    }
    self.backView.backgroundColor = [UIColor whiteColor];
    [self setNeedsDisplay];
    return YES;
}

- (void) clearColor
{
    self.bgView.backgroundColor = [UIColor clearColor];
    self.backView.backgroundColor = [UIColor clearColor];
    self.bgView.image = nil;
}


@end
