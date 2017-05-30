//
//  CooTekPopUpSheet.h
//  TouchPalDialer
//
//  Created by Liangxiu on 5/30/12.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPUIButton.h"

@protocol CooTekPopUpSheetDelegate<NSObject>
- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info;
@optional
- (void)doClickOnCancelButtonWithTag:(int)tag;
- (void)doClickIconButton:(int)index withTag:(int)tag info:(NSArray *)info;
- (void)doClickOnAddedCell;
@end

typedef enum {
    PopUpSheetTypeNumbersSendMessage = 0,
    PopUpSheetTypeNumbersCall,
    PopUpSheetTypenumbersPay,
    PopUpSheetTypeDeleteLogs,
    PopUpSheetTypeDeleteYellowLogs,
    PopUpSheetTypeSmartRuleCall,
    PopUpSheetTypeShopReport,
    PopUpSheetTypeShowAllNumbers,
    PopUpSheetTypeGroupOperation,
    PopUpsheetTypeMore,
    PopUPsheetTypeVOIPChoice,
}PopUpSheetType;

@interface DefaultPopUpCellButton : NSObject
+(TPUIButton *)createPopupButton:(CGRect)frame;
+(TPUIButton *)createClickIcon:(CGRect)frame withIcon:(UIImage *)icon withHgImage:(UIImage *)hgIcon;
+(void)addIcon:(CGRect)frame withIcon:(UIImage *)icon withParent:(id)parent;
+(void)addText:(CGRect)frame withText:(NSString *)text withAlignment:(NSTextAlignment)textAlignment withParent:(id)parent;
+(void)addDetailText:(CGRect)frame withText:(NSString *)text withAlignment:(NSTextAlignment)textAlignment withParent:(id)parent;
@end
@interface CooTekPopUpSheet : UIView <UIScrollViewDelegate>{
}
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSArray *contentArray;
@property (nonatomic,assign) id<CooTekPopUpSheetDelegate> delegate;
@property(nonatomic,copy) void(^willAppearPopupSheet)();
@property(nonatomic,copy) void(^willDisappearPopupSheet)();
@property(nonatomic, retain) UIButton *bgView;
- (id)initWithTitle:(NSString *)title content:(NSArray *)contents type:(PopUpSheetType)type appear:(void(^)())willAppearPopupSheet disappear:(void(^)())willDisappearPopupSheet;
- (id)initWithTitle:(NSString *)title content:(NSArray *)contents type:(PopUpSheetType)type;
@end
