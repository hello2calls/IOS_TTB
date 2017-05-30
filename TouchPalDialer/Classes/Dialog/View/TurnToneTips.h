//
//  TurnToneTips.h
//  TouchPalDialer
//
//  Created by wen on 15/10/26.
//
//

#import <UIKit/UIKit.h>
#import "UILayoutUtility.h"
#import "DialogUtil.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"

typedef void (^btnBlock)(void);

@interface TurnToneTips : UIView

- (instancetype)initWithFrame:(CGRect)frame titleString:(NSString *)titleString leftString:(NSString *)leftString rightString:(NSString *)rightString sureBlock:(btnBlock)sureBlock;
@property(nonatomic,copy)btnBlock sureBlock;
-(void)removeSelf;
-(void)sureToBlock;

@end
