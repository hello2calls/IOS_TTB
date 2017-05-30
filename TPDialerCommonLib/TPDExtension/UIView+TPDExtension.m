//
//  UIView+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import "UIView+TPDExtension.h"
#import <Masonry.h>
#import <BlocksKit+UIKit.h>
#import "TPDLib.h"
#import "CootekNotifications.h"

@implementation UIView (TPDExtension)

#pragma mark - 布局相关
-(UIView*)tpd_addSubviewsWithVerticalLayout:(NSArray*)controlArr{
    NSMutableArray* offsetArr = [NSMutableArray array];
    for (int i=0; i<controlArr.count; i++) {
        [offsetArr addObject:@0];
    }
    return [self tpd_addSubviewsWithVerticalLayout:controlArr offsets:offsetArr];
}

-(UIView*)tpd_addSubviewsWithVerticalLayout:(NSArray*)controlArr offsets:(NSArray*)offsetArr{
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger n = controlArr.count;
    if (n > 0) {
        UIView* lastView = controlArr[0];
        for (int i=0; i<n; i++) {
            UIView* v = controlArr[i];
            [self addSubview:v];
            double offset = [offsetArr[i] doubleValue];
            
            [v makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                if (i==0) {
                    make.top.equalTo(self).offset(offset);
                }else{
                    
                    make.top.equalTo(lastView.bottom).offset(offset);
                }
                if (i==n-1){
                    make.bottom.equalTo(self);
                }
            }];
            
            lastView = v;
        }
    }
    
    
    return self;
}

+(UIView*)tpd_horizontalGroupWith:(NSArray*)controlArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip weightArr:(NSArray*)weightArr{
    
    UIView* ret = [[UIView alloc] init];
    UIView* lastView = controlArr[0];
    [ret addSubview:lastView];
    [lastView makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.height.equalTo(ret);
    }];
    
    double vWidth = [weightArr[0] doubleValue];
    
    for (int i=1; i<controlArr.count; i++) {
        double proportion = [weightArr[i] doubleValue] / vWidth;
        UIView* v = controlArr[i];
        [ret addSubview:v];
        [v makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastView.right).offset(ip);
            make.width.equalTo(((UIView*)controlArr[0]).width).multipliedBy(proportion);
            make.height.centerY.equalTo(ret);
        }];
        
        lastView = v;
    }
    
    [lastView updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ret);
    }];
    
    ret = [ret tpd_wrapperWithEdgeInsets:UIEdgeInsetsMake(vp, hp, vp, hp)];
    
    return ret;
}


+(UIView*)tpd_horizontalGroupFullScreenForIOS7:(NSArray*)controlArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip weightArr:(NSArray*)weightArr{
    
    UIView* ret = [[UIView alloc] init];
    UIView* lastView = controlArr[0];
    [ret addSubview:lastView];
    
    double totalWeight = 0;
    for (NSNumber* weight in weightArr) {
        totalWeight += [weight doubleValue];
    }
    
    double width = [UIScreen mainScreen].bounds.size.width;
    double totalWidthAfterMinusPadding = width-2*hp - ip*(controlArr.count-1);
    [lastView makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.height.equalTo(ret);
        make.width.equalTo(totalWidthAfterMinusPadding / totalWeight * [weightArr[0] doubleValue]);
    }];
    
    for (int i=1; i<controlArr.count; i++) {
        UIView* v = controlArr[i];
        [ret addSubview:v];
        
        [v makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastView.right).offset(ip);
            if (i!=controlArr.count-1) {
                make.width.equalTo(totalWidthAfterMinusPadding / totalWeight * [weightArr[i] doubleValue]);
            }else{
                make.right.equalTo(ret);
            }
            make.height.centerY.equalTo(ret);
        }];
        
        lastView = v;
    }
    
    ret = [ret tpd_wrapperWithEdgeInsets:UIEdgeInsetsMake(vp, hp, vp, hp)];
    
    return ret;
}

+(UIView*)tpd_horizontalLinearLayoutWith:(NSArray*)viewArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip{
    
    UIView* ret = [[UIView alloc] init];
    
    UIView* lastView = viewArr[0];
    [ret addSubview:lastView];
    [lastView makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.height.equalTo(ret);
    }];
    
    for (int i=1; i<viewArr.count; i++) {
        UIView* v = viewArr[i];
        [ret addSubview:v];
        [v makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastView.right).offset(ip);
            make.height.centerY.equalTo(ret);
        }];
        
        lastView = v;
    }
    
    [lastView updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ret);
    }];
    
    ret = [ret tpd_wrapperWithEdgeInsets:UIEdgeInsetsMake(vp, hp, vp, hp)];
    
    return ret;
}


#pragma mark - 松弛wrapper
CAST(UIButton)
CAST(UILabel)
CAST(UITableViewCell)
CAST(UITableView)
CAST(UIImageView)

-(UIView*)tpd_wrapperWithStyle:(LooseWrapperStyle)style{
    UIView* ret = [[UIView alloc] init];
    [ret addSubview:self];
    ret.userInteractionEnabled = NO;
    
    NSInteger horizontalAlign = style & 0x03;
    NSInteger horizontalConstraint = style & 0x0c;
    NSInteger verticalAlign = style & 0x30;
    NSInteger verticalConstraint = style & 0xc0;
    
    switch (horizontalAlign) {
        case WrapperStyleLeftAlignment:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(ret);
            }];
            break;
        }
        case WrapperStyleRightAlignment:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(ret);
            }];
            break;
        }
        case WrapperStyleCenterXAlignment:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(ret);
            }];
            break;
        }
        default:
            break;
    }
    
    switch (horizontalConstraint) {
        case WrapperStyleWidthAny:
        {
            break;
        }
        case WrapperStyleWidthGreater:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.width.lessThanOrEqualTo(ret);
            }];
            break;
        }
        case WrapperStyleWidthEqual:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(ret);
            }];
            break;
        }
        default:
            break;
    }
    
    switch (verticalAlign) {
        case WrapperStyleTopAlignment:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(ret);
            }];
            break;
        }
        case WrapperStyleBottomAlignment:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(ret);
            }];
            break;
        }
        case WrapperStyleCenterYAlignment:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(ret);
            }];
            break;
        }
        default:
            break;
    }
    
    switch (verticalConstraint) {
        case WrapperStyleHeightAny:
        {
            break;
        }
        case WrapperStyleHeightGreater:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.height.lessThanOrEqualTo(ret);
            }];
            break;
        }
        case WrapperStyleHeightEqual:
        {
            [self makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(ret);
            }];
            break;
        }
        default:
            break;
    }
    
    return ret;
}

-(UIView*)tpd_wrapperWithEdgeInsets:(UIEdgeInsets)insets{
    UIView* ret = [[UIView alloc] init];
    [ret addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ret).with.insets(insets);
    }];
    return ret;
}

-(UIView*)tpd_wrapper{
    return [self tpd_wrapperWithStyle:WrapperStyleCenterXAlignment | WrapperStyleCenterYAlignment | WrapperStyleHeightGreater | WrapperStyleWidthGreater];
}


-(UIView*)tpd_wrapperVertical{
    return [self tpd_wrapperWithStyle:WrapperStyleCenterXAlignment | WrapperStyleCenterYAlignment | WrapperStyleHeightGreater | WrapperStyleWidthEqual];
}

-(UIButton*)tpd_wrapperWithButton{
    UIButton* btn = [UIButton tpd_buttonStyleCommon];
    [btn addSubview:self];
    [self updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(btn);
    }];
    return btn;
}

-(UIScrollView*)tpd_wrapperWithHorizontalScrollView{
    UIScrollView* scroll = [[UIScrollView alloc] init];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.bounces = YES;
    
    [scroll addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.height.right.equalTo(scroll);
    }];
    return scroll;
}

#pragma mark - 属性设定
-(UIView*)tpd_withHeight:(double)height{
    [self updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(height);
    }];
    return self;
}

-(UIView*)tpd_withSize:(CGSize)size{
    [self updateConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(size);
    }];
    return self;
}

-(UIView*)tpd_withBackgroundColor:(UIColor*)color{
    self.backgroundColor = color;
    return self;
}

-(UIView*)tpd_withBorderWidth:(double)width color:(UIColor*)color{
    self.layer.borderWidth = width;
    self.layer.borderColor = [color CGColor];
    return self;
}

-(UIView*)tpd_withCornerRadius:(double)radius{
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
    return self;
}

#pragma mark - 帮助方法
+ (UIWindow *)tpd_topWindow
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        
        if ([window isKindOfClass:[UIWindow class]] &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            
            return window;
    }
    return nil;
}

#pragma mark - 单选控件组
ADD_DYNAMIC_PROPERTY(NSArray*,tpd_btnArrInGroup,setTpd_btnArrInGroup)

+(NSMutableArray*)tpd_buttonGroup:(NSArray*)viewArr whenClick:(void (^)(UIButton*))block{

    void (^dummy)(UIButton*) = block;
    
    NSMutableArray* btnArr = [NSMutableArray array];
    for (int i=0; i<viewArr.count; i++) {
        UIView* v = viewArr[i];
        
        UIButton* btn = [v tpd_wrapperWithButton];
        v.userInteractionEnabled = NO;
        btn.tag = i;

        [btn setTpd_whenClicked:^(id sender) {
            UIButton* theBtn = sender;
            for (UIButton* tmp in btnArr) {
                tmp.selected = NO;
                dummy(tmp);
            }
            theBtn.selected = YES;
            dummy(theBtn);
        }];
        [btn tpd_withBlock:^(id sender) {
            UIButton* theBtn = sender;
            EXEC_BLOCK(theBtn.tpd_whenClicked,sender);
        }];
        [btnArr addObject:btn];
    }
    
    return btnArr;
}

+(UIView*)tpd_selectionBar1:(NSArray*)viewArr block:(void (^)(UIButton*))block{
    NSMutableArray* wrapperArr = [NSMutableArray array];
    for (UIView* tag in viewArr) {
        UIView* wrap = [tag tpd_wrapper];
        [wrapperArr addObject:wrap];
    }
    
    void (^dummy)(UIButton*) = block;
    
    NSArray* btnArr = [UIButton tpd_buttonGroup:wrapperArr whenClick:^(UIButton* btn) {
        dummy(btn);
    }];
    
    NSMutableArray* weightArr = [NSMutableArray array];
    for (int i=0; i<btnArr.count; i++) {
        [weightArr addObject:@1];
    }
    UIView* ret = [UIView tpd_horizontalGroupWith:btnArr horizontalPadding:0 verticalPadding:0 interPadding:0 weightArr:weightArr] ;
    ret.tpd_btnArrInGroup = btnArr;
    
    return ret;
}


// 可滚动的tab条
+(UIView*)tpd_selectionBar2:(NSArray*)viewArr block:(void (^)(UIButton*))block{
    NSMutableArray* wrapperArr = [NSMutableArray array];
    for (UIView* tag in viewArr) {
        UIView* wrap = [tag tpd_wrapper];
        [wrapperArr addObject:wrap];
    }
    
    void (^dummy)(UIButton*) = block;
    
    NSArray* btnArr = [UIButton tpd_buttonGroup:wrapperArr whenClick:^(UIButton* btn) {
        dummy(btn);
    }];
    
    NSMutableArray* weightArr = [NSMutableArray array];
    for (int i=0; i<btnArr.count; i++) {
        [weightArr addObject:@1];
    }
    
    UIView* ret = [[UIView tpd_horizontalLinearLayoutWith:btnArr horizontalPadding:0 verticalPadding:0 interPadding:0] tpd_wrapperWithHorizontalScrollView];
    ret.tpd_btnArrInGroup = btnArr;
    
    return ret;
}


ADD_DYNAMIC_PRIMITIVE_PROPERTY(NSInteger, currentPage, setCurrentPage)
ADD_DYNAMIC_PROPERTY(UIView*,tpd_horizontalTab,setTpd_horizontalTab)
ADD_DYNAMIC_PROPERTY(UIScrollView*,tpd_horizontalPages,setTpd_horizontalPages)

+(UIView*)tpd_horizontalTabsPagesSuite:(NSArray*)tabArr pages:(NSArray*)pageArr tabSelectBlock:(void (^)(UIButton*))block{
    UIView* ret = [[UIView alloc] init];
    
    UIView* tmp = [[UIView tpd_selectionBar1:tabArr block:^(UIButton* btn) {
        EXEC_BLOCK(block,btn);
        if (btn.selected) {
            ret.tpd_horizontalPages.contentOffset = CGPointMake(btn.tag*[UIScreen mainScreen].bounds.size.width, 0);
            ret.currentPage = btn.tag;
        }
    }] tpd_withBackgroundColor:[UIColor clearColor]];
    ret.tpd_horizontalTab = tmp;
    

    UIScrollView* pageScroll = [[UIScrollView alloc] init];
    pageScroll.pagingEnabled = YES;
    pageScroll.delegate = ret;
    pageScroll.bounces = NO;
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = NO;
    pageScroll.directionalLockEnabled = YES;
    ret.tpd_horizontalPages = pageScroll;
    double width = [UIScreen mainScreen].bounds.size.width;
    UIView* lastItem = nil;
    for (int i=0; i<pageArr.count; i++) {
        UIView* item = pageArr[i];
        [ret.tpd_horizontalPages addSubview:item];
        [item makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(ret.tpd_horizontalPages);
            make.height.bottom.equalTo(ret.tpd_horizontalPages);
            make.left.equalTo(ret.tpd_horizontalPages).offset(i*width);
            make.width.equalTo(width);
        }];
        lastItem = item;
    }
    [lastItem updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ret.tpd_horizontalPages);
    }];
    
    
    return ret;
}

+(UIView*)tpd_horizontalTabsPagesSuite2:(NSArray*)tabArr pages:(NSArray*)pageArr tabSelectBlock:(void (^)(UIButton*))block{
    UIView* ret = [[UIView alloc] init];
    
    UIView* tmp = [[UIView tpd_selectionBar2:tabArr block:^(UIButton* btn) {
        EXEC_BLOCK(block,btn);
        if (btn.selected) {
            ret.tpd_horizontalPages.contentOffset = CGPointMake(btn.tag*[UIScreen mainScreen].bounds.size.width, 0);
            ret.currentPage = btn.tag;
        }
    }] tpd_withBackgroundColor:[UIColor clearColor]];
    ret.tpd_horizontalTab = tmp;
    
    
    UIScrollView* pageScroll = [[UIScrollView alloc] init];
    pageScroll.pagingEnabled = YES;
    pageScroll.delegate = ret;
    pageScroll.bounces = NO;
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = NO;
    pageScroll.directionalLockEnabled = YES;
    ret.tpd_horizontalPages = pageScroll;
    double width = [UIScreen mainScreen].bounds.size.width;
    UIView* lastItem = nil;
    for (int i=0; i<pageArr.count; i++) {
        UIView* item = pageArr[i];
        [ret.tpd_horizontalPages addSubview:item];
        [item makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(ret.tpd_horizontalPages);
            make.height.bottom.equalTo(ret.tpd_horizontalPages);
            make.left.equalTo(ret.tpd_horizontalPages).offset(i*width);
            make.width.equalTo(width);
        }];
        lastItem = item;
    }
    [lastItem updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ret.tpd_horizontalPages);
    }];
    
    
    return ret;
}


-(UIView*)tpd_horizontalTabsPagesJumpToPage:(NSInteger)pageIndex{
    UIButton* b = self.tpd_horizontalTab.tpd_btnArrInGroup[pageIndex];
    EXEC_BLOCK(b.tpd_whenClicked,b)
    self.currentPage = pageIndex;
    return self;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    static BOOL lock = NO;
    CGFloat w = scrollView.frame.size.width;
    CGFloat x = scrollView.contentOffset.x;
    NSInteger page = (x + 0.5*w)/w;
    if (scrollView == self.tpd_horizontalPages && w > 0.001 && page!=self.currentPage) {
        @synchronized(self) {
            if (!lock) {
                lock = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self tpd_horizontalTabsPagesJumpToPage:page];
                    
                    lock = NO;
                });
            }
            
        }
        
    }
    
}


#pragma mark 常用的widget
ADD_DYNAMIC_PROPERTY(UIScrollView*,tpd_maskView,setTpd_maskView)
-(UIView*)tpd_maskViewContainer:(void (^)(id sender))block{
    UIView* container = [[UIView alloc] init];
    
    UIButton* maskView = [[[UIButton alloc] init] tpd_withBlock:^(id sender) {
        container.hidden = YES;
        [container removeFromSuperview];
        EXEC_BLOCK(block, container);
    }];
    
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = .4f;
    
    [container addSubview:maskView];
    [container addSubview:self];
    
    [maskView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container);
    }];
    

    
    self.tpd_maskView = maskView;
    
    return container;
    
}


#pragma mark helpers

-(UIViewController*)tpd_correspondController{
    id responder = self.nextResponder;
    while (![responder isKindOfClass: [UIViewController class]] && ![responder isKindOfClass: [UIWindow class]])
    {
        responder = [responder nextResponder];
    }
    if ([responder isKindOfClass: [UIViewController class]])
    {
        return responder;
    }else{
        return nil;
    }
}


@end
