//
//  CommonTipsWithBolckView.h
//  TouchPalDialer
//
//  Created by wen on 15/11/30.
//
//

#import <UIKit/UIKit.h>
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "DialogUtil.h"
#import "UserDefaultsManager.h"
typedef void (^btnBlock)(void);
@interface CommonTipsWithBolckView : UIView



@property(nonatomic,copy)btnBlock rightBlock;
@property(nonatomic,copy)btnBlock leftBlock;
@property(nonatomic,retain)UILabel *titleLable;
@property(nonatomic,retain)UILabel *lable1;
@property(nonatomic,retain)UILabel *lable2;
@property(nonatomic,retain)UILabel *lable3;
@property(nonatomic,retain)UILabel *lable4;
@property(nonatomic,retain)UILabel *lable5;
@property(nonatomic,retain)UIButton* rightBtn;
@property(nonatomic,retain)UIButton* leftBtn;
@property(nonatomic,retain)UILabel* checkImageLable;
@property(nonatomic,retain)NSMutableString *userDefaultString;
@property(nonatomic,assign)BOOL ifCheckSure;
- (instancetype)initWithtitleString:(NSString *)titleString lable1String:(NSString *)lable1String  lable1textAlignment:(NSTextAlignment)textAlignment1 lable2String:(NSString *)lable2String lable2textAlignment:(NSTextAlignment)textAlignment2 leftString:(NSString *)leftString  rightString:(NSString *)rightString rightBlock:(btnBlock)rightBlock leftBlock:(btnBlock)leftBlock;
- (instancetype)initWithGreyButtonWithtitleString:(NSString *)titleString lable1String:(NSString *)lable1String  lable1textAlignment:(NSTextAlignment)textAlignment1 lable2String:(NSString *)lable2String lable2textAlignment:(NSTextAlignment)textAlignment2 leftString:(NSString *)leftString  rightString:(NSString *)rightString rightBlock:(btnBlock)rightBlock leftBlock:(btnBlock)leftBlock;
-(void)removeSelf;
-(void)sureToBlock;
+(void)showTipsWithTitle:(NSString *)titleString leftString:(NSString *)leftString rightString:(NSString *)rightString rightBlock:(btnBlock)rightBlock leftBlock:(btnBlock)leftBlock  checkString:(NSString *)checkString ifCheckSure:(BOOL)ifCheckSure lableStringArg:(NSString *)firstString, ...NS_REQUIRES_NIL_TERMINATION;


@end
