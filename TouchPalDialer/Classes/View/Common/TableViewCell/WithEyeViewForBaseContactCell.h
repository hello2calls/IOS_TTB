//
//  WityEyeViewForBaceContactCell.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 9/24/12.
//
//

#import "BaseContactCell.h"
#import "LongGestureController.h"
@interface WithEyeViewForBaseContactCell : BaseContactCell<LongGestureCellDelegate>
@property (nonatomic,assign) BOOL ifCalllogCell;
- (BOOL)hasMarkButton;
- (void)showMarkButton;
- (void)hideMarkButton;
- (void)removeMarkButton;
@end
