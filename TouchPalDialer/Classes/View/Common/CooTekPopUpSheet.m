//
//  CooTekPopUpSheet.m
//  TouchPalDialer
//
//  Created by Liangxiu on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CooTekPopUpSheet.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"

#define EXCLUDED_FROM_SMART_RULE_CELL_TAG 100
@implementation DefaultPopUpCellButton

+(TPUIButton *)createPopupButton:(CGRect)frame{
    TPUIButton *button = [[TPUIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:@"common_rule_list_button@2x.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:@"common_rule_list_button_ht@2x.png"] forState:UIControlStateHighlighted];
    return button;
}
+(TPUIButton *)createClickIcon:(CGRect)frame withIcon:(UIImage *)icon withHgImage:(UIImage *)hgIcon{
    TPUIButton *button = [[TPUIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:icon forState:UIControlStateNormal];
    [button setBackgroundImage:hgIcon forState:UIControlStateHighlighted];
    return button;
}
+(void)addIcon:(CGRect)frame withIcon:(UIImage *)icon withParent:(id)parent{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.frame = frame;
    [parent addSubview:imageView];
}
+(void)addText:(CGRect)frame withText:(NSString *)text withAlignment:(NSTextAlignment)textAlignment withParent:(id)parent{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:frame];
    textLabel.textAlignment = textAlignment;
    [textLabel setSkinStyleWithHost:parent forStyle:@"PopUpSheetCellLabel_style"];
    textLabel.font = [UIFont systemFontOfSize:CELL_FONT_LARGE];
    textLabel.text = text;
    [parent addSubview:textLabel];
}

+(void)addDetailText:(CGRect)frame withText:(NSString *)text withAlignment:(NSTextAlignment)textAlignment withParent:(id)parent{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:frame];
    textLabel.textAlignment = textAlignment;
    [textLabel setSkinStyleWithHost:parent forStyle:@"PopUpSheetCellDetailLabel_style"];
    textLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
    textLabel.text = text;
    [parent addSubview:textLabel];
}
@end


@interface CooTekPopUpSheet (){
    BOOL isDetailInfo_;
    id<CooTekPopUpSheetDelegate> __unsafe_unretained delegate;
    NSString *title_;
    UIView *cells_;
    NSArray *contentArray_;
    PopUpSheetType type_;
    
    void(^willAppearPopupSheet_)();
    void(^willDisappearPopupSheet_)();
}
- (void)loadContent:(UIScrollView *)scrollView;
- (BOOL)isTwoLineInCell:(PopUpSheetType)type;
- (void)animatedShow;
- (void)animatedOut;
- (void)addCancelButton;
- (void)contractButton:(UIButton *)button;
@end

@implementation CooTekPopUpSheet
@synthesize delegate;
@synthesize title = title_;
@synthesize contentArray = contentArray_;
@synthesize willAppearPopupSheet = willAppearPopupSheet_;
@synthesize willDisappearPopupSheet = willDisappearPopupSheet_;

- (BOOL)isTwoLineInCell:(PopUpSheetType)type{
    if (PopUpSheetTypeShopReport == type ||
        PopUpSheetTypeShowAllNumbers == type ||
        PopUpSheetTypeGroupOperation == type ||
        PopUpsheetTypeMore == type ||
        PopUPsheetTypeVOIPChoice == type) {
        return NO;
    }else{
        return YES;
    }
}
- (id)initWithTitle:(NSString *)title content:(NSArray *)contents type:(PopUpSheetType)type appear:(void(^)())willAppearPopupSheet disappear:(void(^)())willDisappearPopupSheet{
    self = [super initWithFrame:CGRectZero];
    if(self){
        self.title = title;
        self.willAppearPopupSheet = willAppearPopupSheet;
        self.willDisappearPopupSheet = willDisappearPopupSheet;
        self.contentArray = contents;
        type_ = type;
        
        self.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        self.bgView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
        self.bgView.backgroundColor = [UIColor clearColor];
        [self.bgView addTarget:self action:@selector(animatedOut) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bgView];
        
        isDetailInfo_ = [self isTwoLineInCell:type];
        int contentCellNum = [contentArray_ count]/(isDetailInfo_ ? 2:1);
        if(type == PopUpSheetTypeSmartRuleCall){
            contentCellNum++;
        }
        int displayCellNum = contentCellNum > 5 ? 5 : contentCellNum;
        if (type_ == PopUpSheetTypeGroupOperation) {
            displayCellNum = contentCellNum;
        }
        CGSize cells_size = CGSizeMake(TPScreenWidth(), (2+displayCellNum)*50);
        cells_ = [[UIView alloc] initWithFrame:CGRectMake(0, TPAppFrameHeight()-cells_size.height+TPHeaderBarHeightDiff(), TPScreenWidth(), cells_size.height)];
        
        //title
        if (type_ != PopUpSheetTypeGroupOperation && title_) {
            UIImageView *titleBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 50)];
            titleBack.image = [[TPDialerResourceManager sharedManager]
                               getImageByName:@"common_rule_pop_list_header_bg@2x.png"];
            [cells_ addSubview:titleBack];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 50)];
            [titleLabel setSkinStyleWithHost:self forStyle:@"PopUpSheetTitleLabel_style"];
            titleLabel.font = [UIFont systemFontOfSize:CELL_FONT_LARGER];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.numberOfLines =0;
            titleLabel.lineBreakMode = true;
            titleLabel.text = title_;
            [cells_ addSubview:titleLabel];
        }
        //content
        UIScrollView *tmpScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,50, TPScreenWidth(), displayCellNum*50)];
        tmpScrollView.contentSize = CGSizeMake(TPScreenWidth(), contentCellNum*50);
        tmpScrollView.showsHorizontalScrollIndicator = YES;
        tmpScrollView.showsVerticalScrollIndicator = YES;
        tmpScrollView.scrollsToTop = YES;
        tmpScrollView.bounces = NO;
        tmpScrollView.delegate = self;
        tmpScrollView.backgroundColor = [UIColor clearColor];
        if(contentCellNum==displayCellNum){
            tmpScrollView.scrollEnabled = NO;
        }else{
            tmpScrollView.scrollEnabled = YES;
        }
        [cells_ addSubview:tmpScrollView];
        [self loadContent:tmpScrollView];
        [tmpScrollView flashScrollIndicators];
        
        [self addCancelButton];
        [self.bgView addSubview:cells_];
        [self animatedShow];
        if (willAppearPopupSheet_) {
            willAppearPopupSheet_();
        }
    }
    return self;
}
- (id)initWithTitle:(NSString *)title content:(NSArray *)contents type:(PopUpSheetType)type{
    return [self initWithTitle:title content:contents type:type appear:^(){} disappear:^(){}];
}
- (void)addCancelButton{
    TPUIButton *button = [[TPUIButton alloc] initWithFrame:CGRectMake(0, cells_.frame.size.height -50, TPScreenWidth(), 50)];
    button.tag = [contentArray_ count];
    [button addTarget:self action:@selector(didSelectRowAtButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:@"common_rule_pop_list_bt_normal@2x.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:@"common_rule_pop_list_bt_press@2x.png"] forState:UIControlEventTouchDown];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 50)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"defaultCellMainText_color"];
    textLabel.font = [UIFont systemFontOfSize:CELL_FONT_LARGE];
    textLabel.text = NSLocalizedString(@"Cancel", @"");
    [button addSubview:textLabel];
    [cells_ addSubview:button];
}
-(NSArray *)attachInfo:(NSInteger)index{
    NSArray *infoArray = nil;
    if(isDetailInfo_)
    {
        int arrayIndex = index*2;
        infoArray = [NSArray arrayWithObjects:[contentArray_ objectAtIndex:arrayIndex],[contentArray_ objectAtIndex:arrayIndex+1], nil];
    }else{
        infoArray = [NSArray arrayWithObjects:[contentArray_ objectAtIndex:index], nil];
    }
    return infoArray;
}
-(void)didSelectRowAtButton:(id)button
{
    if (willDisappearPopupSheet_) {
        willDisappearPopupSheet_();
    }
    NSInteger index = [(TPUIButton *)button tag];
    if(index < [contentArray_ count]){
        NSArray *infoArray = [self attachInfo:index];
        [delegate doClickOnPopUpSheet:index withTag:type_ info:infoArray];
        [self removeFromSuperview];
    }else if(index == EXCLUDED_FROM_SMART_RULE_CELL_TAG){
        if([delegate respondsToSelector:@selector(doClickOnAddedCell)]){
            [delegate doClickOnAddedCell];
        }
        [self removeFromSuperview];
    }else{
        // clicked on cancel button
        if ([delegate respondsToSelector:@selector(doClickOnCancelButtonWithTag:)]) {
            [delegate doClickOnCancelButtonWithTag:type_];
        }
        [self animatedOut];
    }
}

- (void)animatedShow{
    CGRect oldFrame = cells_.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                         cells_.frame = CGRectMake(0,TPAppFrameHeight()+TPHeaderBarHeightDiff(),oldFrame.size.width,oldFrame.size.height);
                         
                         cells_.frame = CGRectMake(0, TPAppFrameHeight()+TPHeaderBarHeightDiff()-oldFrame.size.height, TPScreenWidth(), oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                         
                     }
                     completion:nil];
}

- (void)animatedOut{
    CGRect oldFrame = cells_.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                         cells_.frame = CGRectMake(0, TPAppFrameHeight()+TPHeaderBarHeightDiff()-oldFrame.size.height, TPScreenWidth(), oldFrame.size.height);
                         
                         cells_.frame = CGRectMake(0,TPAppFrameHeight()+TPHeaderBarHeightDiff(),oldFrame.size.width,oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             [self removeFromSuperview];
                         }
                     }];
}

- (void)loadContent:(UIScrollView *)scrollView{
    int step = isDetailInfo_ ? 2:1;
    int j=0;
    for(int i=0;i<[contentArray_ count];i+=step){
        TPUIButton *button = [DefaultPopUpCellButton createPopupButton:CGRectMake(0, 50*(j++), TPScreenWidth(), 50)];
        [scrollView addSubview:button];
        button.tag = i/(step);
        [button addTarget:self action:@selector(didSelectRowAtButton:) forControlEvents:UIControlEventTouchUpInside];
        [self contractButton:button];
    }
    if(type_ == PopUpSheetTypeSmartRuleCall){
        TPUIButton *button = [DefaultPopUpCellButton createPopupButton:CGRectMake(0, 50*j, TPScreenWidth(), 50)];
        [scrollView addSubview:button];
        button.tag = EXCLUDED_FROM_SMART_RULE_CELL_TAG;
        [button addTarget:self action:@selector(didSelectRowAtButton:) forControlEvents:UIControlEventTouchUpInside];
        [self contractButton:button];
    }
}
- (void)contractButton:(UIButton *)button{
    int index = button.tag;
    switch (type_) {
        case PopUpSheetTypeNumbersSendMessage:
        case PopUpSheetTypeNumbersCall:
        case PopUpSheetTypenumbersPay:
        case PopUpSheetTypeDeleteYellowLogs:
        case PopUpSheetTypeDeleteLogs:
        {
            [DefaultPopUpCellButton addText:CGRectMake(0,0, TPScreenWidth(), 30) withText:[contentArray_ objectAtIndex:2*index] withAlignment:NSTextAlignmentCenter withParent:button];
            [DefaultPopUpCellButton addDetailText:CGRectMake(0,25, TPScreenWidth(), 20) withText:[contentArray_ objectAtIndex:2*index+1] withAlignment:NSTextAlignmentCenter withParent:button];
            break;
        }
        case PopUpSheetTypeShopReport:
        case PopUpsheetTypeMore:
        case PopUPsheetTypeVOIPChoice:
        {
            [DefaultPopUpCellButton addText:CGRectMake(0,0, TPScreenWidth(), 50) withText:[contentArray_ objectAtIndex:index] withAlignment:NSTextAlignmentCenter withParent:button];
            break;
        }
        case PopUpSheetTypeSmartRuleCall:
        {
            
            if(index == EXCLUDED_FROM_SMART_RULE_CELL_TAG){
                [DefaultPopUpCellButton addText:CGRectMake(10,0, TPScreenWidth()-2*10, 50) withText:NSLocalizedString(@"Not apply IP rules for this number", @"") withAlignment:NSTextAlignmentLeft withParent:button];
            }else{
                UIImage *icon = [[TPDialerResourceManager sharedManager] getImageByName:@"common_rule_list_call_icon@2x.png"];
                int width = icon.size.width;
                [DefaultPopUpCellButton addText:CGRectMake(10,0, TPScreenWidth()-width-2*10, 30) withText:[contentArray_ objectAtIndex:2*index] withAlignment:NSTextAlignmentLeft withParent:button];
                [DefaultPopUpCellButton addDetailText:CGRectMake(10,30, TPScreenWidth()-width-2*10, 20) withText:[contentArray_ objectAtIndex:2*index+1] withAlignment:NSTextAlignmentLeft withParent:button];
                [DefaultPopUpCellButton addIcon:CGRectMake(TPScreenWidth()-width,0,width, icon.size.height) withIcon:icon withParent:button];
            }
            
            break;
        }
        case PopUpSheetTypeShowAllNumbers:
        {
            UIImage *icon = [[TPDialerResourceManager sharedManager] getImageByName:@"common_rule_list_call_icon@2x.png"];
            UIImage *iconClickNormal = [[TPDialerResourceManager sharedManager] getImageByName:@"detailbtn_sms_normal@2x.png"];
            UIImage *iconClickHt = [[TPDialerResourceManager sharedManager] getImageByName:@"detailbtn_sms_pressed@2x.png"];
            
            int textwidth = TPScreenWidth() - icon.size.width - iconClickNormal.size.width;
            int left = icon.size.width;
            [DefaultPopUpCellButton addIcon:CGRectMake(0,0,icon.size.width, icon.size.height) withIcon:icon withParent:button];
            [DefaultPopUpCellButton addText:CGRectMake(left,0, textwidth, 50) withText:[contentArray_ objectAtIndex:index] withAlignment:NSTextAlignmentLeft withParent:button];
            
            TPUIButton *iconButton = [DefaultPopUpCellButton createClickIcon:CGRectMake(TPScreenWidth() - iconClickNormal.size.width,0,iconClickNormal.size.width, iconClickNormal.size.height) withIcon:iconClickNormal withHgImage:iconClickHt];
            [iconButton addTarget:self action:@selector(iconClick:) forControlEvents:UIControlEventTouchUpInside];
            [button addSubview:iconButton];
            iconButton.tag = index;
            break;
        }
        default:
            break;
    }
}
- (void)iconClick:(UIButton *)button{
    if (willDisappearPopupSheet_) {
        willDisappearPopupSheet_();
    }
    NSArray *infoArray = [self attachInfo:button.tag];
    [delegate doClickIconButton:button.tag withTag:type_ info:infoArray];
    [self removeFromSuperview];
}
- (void) dealloc{
    [SkinHandler removeRecursively:self];
}
@end

