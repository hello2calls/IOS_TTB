//
//  UIView+TPDExtension.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, LooseWrapperStyle) {
    // bit 0 & 1
    WrapperStyleLeftAlignment = 0x0,
    WrapperStyleCenterXAlignment = 0x1,
    WrapperStyleRightAlignment =0x2,
    // bit 2 & 3
    WrapperStyleWidthEqual = 0x00,
    WrapperStyleWidthAny = 0x04,
    WrapperStyleWidthGreater = 0x08,
    // bit 4 & 5
    WrapperStyleTopAlignment = 0x00,
    WrapperStyleCenterYAlignment = 0x10,
    WrapperStyleBottomAlignment =0x20,
    // bit 6 & 7
    WrapperStyleHeightEqual = 0x00,
    WrapperStyleHeightAny = 0x40,
    WrapperStyleHeightGreater = 0x80,
    
    // short cut
    WrapperStyleCenterAlignment = WrapperStyleCenterYAlignment | WrapperStyleCenterXAlignment,
};

#define CAST(TYPE)\
-(TYPE*)cast2##TYPE{\
return ((TYPE*)self);\
}

#define DECLARE_CAST(TYPE)\
@property (nonatomic,readonly) TYPE* cast2##TYPE;\

@interface UIView (TPDExtension)
DECLARE_CAST(UIButton)
DECLARE_CAST(UILabel)
DECLARE_CAST(UITableViewCell)
DECLARE_CAST(UITableView)
DECLARE_CAST(UIImageView)
+(UIView*)tpd_horizontalLinearLayoutWith:(NSArray*)viewArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip;
+(UIView*)tpd_horizontalGroupWith:(NSArray*)viewArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip weightArr:(NSArray*)weightArr;

+(UIView*)tpd_horizontalGroupFullScreenForIOS7:(NSArray*)controlArr horizontalPadding:(double)hp verticalPadding:(double)vp interPadding:(double)ip weightArr:(NSArray*)weightArr;

-(UIView*)tpd_addSubviewsWithVerticalLayout:(NSArray*)controlArr;

-(UIView*)tpd_addSubviewsWithVerticalLayout:(NSArray*)viewArr offsets:(NSArray*)offsetArr;

-(UIView*)tpd_wrapperWithStyle:(LooseWrapperStyle)style;

-(UIView*)tpd_wrapperWithEdgeInsets:(UIEdgeInsets)insets;

-(UIView*)tpd_wrapper;

-(UIView*)tpd_wrapperVertical;

-(UIButton*)tpd_wrapperWithButton;

-(UIScrollView*)tpd_wrapperWithHorizontalScrollView;

-(UIView*)tpd_withHeight:(double)height;

-(UIView*)tpd_withSize:(CGSize)size;

-(UIView*)tpd_withBackgroundColor:(UIColor*)color;

-(UIView*)tpd_withBorderWidth:(double)width color:(UIColor*)color;

-(UIView*)tpd_withCornerRadius:(double)radius;


+ (UIWindow *)tpd_topWindow;
-(UIViewController*)tpd_correspondController;

@property (nonatomic,strong) NSArray* tpd_btnArrInGroup;
+(NSMutableArray*)tpd_buttonGroup:(NSArray*)viewArr whenClick:(void (^)(UIButton*))block;
+(UIView*)tpd_selectionBar1:(NSArray*)viewArr block:(void (^)(UIButton*))block;
+(UIView*)tpd_selectionBar2:(NSArray*)viewArr block:(void (^)(UIButton*))block;

@property (nonatomic) NSInteger currentPage;
@property (nonatomic,strong) UIView* tpd_horizontalTab;
@property (nonatomic,strong) UIScrollView* tpd_horizontalPages;
+(UIView*)tpd_horizontalTabsPagesSuite:(NSArray*)tabArr pages:(NSArray*)pageArr tabSelectBlock:(void (^)(UIButton*))block;
+(UIView*)tpd_horizontalTabsPagesSuite2:(NSArray*)tabArr pages:(NSArray*)pageArr tabSelectBlock:(void (^)(UIButton*))block;
-(UIView*)tpd_horizontalTabsPagesJumpToPage:(NSInteger)pageIndex;

@property (nonatomic,strong) UIView* tpd_maskView;
-(UIView*)tpd_maskViewContainer:(void (^)(id sender))block;
@end
