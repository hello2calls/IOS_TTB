//
//  ContactsCellStrategy.h
//  TouchPalDialer
//
//  Created by lingmei xie on 12-11-7.
//
//

#import <Foundation/Foundation.h>

typedef enum{
    MoveOrientationTypeUnknow,
    MoveOrientationTypeLeft,
    MoveOrientationTypeRight,
}MoveOrientationType;


@protocol ContactsCellStrategyDelegate
@optional
-(UIImage *)imageForMove:(MoveOrientationType)type isNormalImage:(BOOL)isNormal;
-(void)onClick:(id)data;
-(void)onPanClick:(id)data type:(MoveOrientationType)type;
-(void)createPanGestureFor:(id)target actionMethod:(SEL)method;
-(void)removePanGestureFor:(id)target;
-(void)setPopupSheetBlock:(void(^)())willAppearPopupSheet disappear:(void(^)())willDisappearPopupSheet;
@end

@interface PanContactsCellStrategy :NSObject<ContactsCellStrategyDelegate>
@end