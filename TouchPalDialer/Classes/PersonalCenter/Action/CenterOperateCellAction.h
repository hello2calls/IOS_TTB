//
//  centerDefaultOperateModel.h
//  TouchPalDialer
//
//  Created by game3108 on 15/5/12.
//
//

#import <Foundation/Foundation.h>
#import "CenterOperateInfo.h"

@interface CenterOperateCellAction : NSObject
@property (readonly, assign) BOOL ifHidden;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString* guidePointId;
@property (nonatomic,assign) id<CenterOperateDelegate> delegate;
- (id)initWithHostView:(UIView *)view DisplayArea:(CGRect)frame operateInfo:(CenterOperateInfo *)info;
- (void)setOriginY:(CGFloat)y;
- (void)setBottomLineHidden:(BOOL)ifHidden;
- (void)setViewHidden:(BOOL)ifHidden;
- (void)setDotType:(PointType)type withNum:(NSInteger)num;
- (void)setTitle:(NSString*)title;
- (void)setSubTitle:(NSString*)subtitle;
- (void)setSubTitleAlpha:(CGFloat)alpha;
- (void)clearHighlightState;
- (void)setContent;
- (CenterOperateInfo *)getInfo;
@end
