//
//  CommonImageViewWithBlock.h
//  TouchPalDialer
//
//  Created by wen on 16/2/2.
//
//

#import <UIKit/UIKit.h>
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "DialogUtil.h"
#import "UserDefaultsManager.h"
typedef void (^btnBlock)(void);
@interface CommonImageViewWithBlock : UIView

@property(nonatomic,copy)btnBlock rightBlock;
@property(nonatomic,copy)btnBlock leftBlock;
- (instancetype)initWithImage:(UIImage *)image leftTitle:(NSString *)leftTitle leftBlock:(btnBlock)leftBlock rightTitle:(NSString *)rightTitle rightBlock:(btnBlock)rightBlock;
-(void)removeSelf;
-(void)sureToBlock;
@end
