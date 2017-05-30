//
//  centerOperateSectionModel.h
//  TouchPalDialer
//
//  Created by game3108 on 15/5/12.
//
//

#import <Foundation/Foundation.h>
#import "CenterOperateInfo.h"
@interface CenterOperateSectionAction : NSObject

@property (nonatomic, strong) NSMutableArray *operateArray;

- (id)initWithHostView:(UIView *)view;
- (void)addOperateInfo:(CenterOperateInfo *)info;
- (CGFloat)getSectionHeight;
- (void)setOriginY:(CGFloat)y;
- (void)refreshNoahPush;
- (void)clearHighlightState;
- (CenterOperateInfo *) getInfo;
@end
