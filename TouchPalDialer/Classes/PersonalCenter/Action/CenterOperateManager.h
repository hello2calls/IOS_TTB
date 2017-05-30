//
//  centerOperateModel.h
//  TouchPalDialer
//
//  Created by game3108 on 15/5/12.
//
//

#import <Foundation/Foundation.h>
#import "NoahManager.h"
#import "CenteroperateInfo.h"

#define GUTTER_LENGTH (20)

@protocol CenterOperateManagerDelegate <NSObject>

- (void)onLogout;

@end

@interface CenterOperateManager : NSObject<UIScrollViewDelegate>
@property (nonatomic,assign) id<CenterOperateManagerDelegate> delegate;
- (id)initWithHostView:(UIView *)view displayArea:(CGRect)frame;
- (CGFloat)contentHeight;
- (void)clearHighlightState;
- (void)refreshSettingData;
- (void)refreshAntiharass;
- (void)askNumbers;
@end
