//
//  centerOperateSectionModel.m
//  TouchPalDialer
//
//  Created by game3108 on 15/5/12.
//
//

#import "CenterOperateSectionAction.h"
#import "CenterOperateCellAction.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"

#define RECT_CELL_HEIG

@interface CenterOperateSectionAction(){
    UIView *bgView;
    UIView *topLine;
    UIView *bottomLine;
    CenterOperateInfo *_info;
}

@end

@implementation CenterOperateSectionAction

- (id)initWithHostView:(UIView *)view{
    self = [super init];
    
    if ( self ){
        self.operateArray = [NSMutableArray array];
        
        bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 0.5)];
        bgView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        [view addSubview:bgView];
    }
    return self;
}

- (void)addOperateInfo:(CenterOperateInfo *)info{
    _info = info;
    CenterOperateCellAction *model = [[CenterOperateCellAction alloc]initWithHostView:bgView DisplayArea:CGRectMake(bgView.frame.origin.x, bgView.frame.size.height, bgView.frame.size.width, CELL_HEIGHT) operateInfo:info];
    [model setViewHidden:info.ifHidden];
    CGRect oldFrame = bgView.frame;
    bgView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height+CELL_HEIGHT);
    [_operateArray addObject:model];
}

- (CGFloat)getSectionHeight{
    return bgView.frame.size.height;
}

- (void)clearHighlightState {
    for ( CenterOperateCellAction *action in _operateArray ){
        [action clearHighlightState];
    }
}

- (void)setOriginY:(CGFloat)y{
    CGRect oldFrame = bgView.frame;
    bgView.frame = CGRectMake(oldFrame.origin.x, y, oldFrame.size.width, oldFrame.size.height);
}

- (void)adjustHeight{
    NSInteger pos = 0;
    CenterOperateCellAction *lastModel = nil;
    for ( CenterOperateCellAction *model in _operateArray ){
        if ( !model.ifHidden ){
            [model setOriginY:pos*CELL_HEIGHT];
            pos += 1;
            lastModel = model;
            [lastModel setBottomLineHidden:NO];
        }
    }
    CGRect oldFrame = bgView.frame;
    bgView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, pos*CELL_HEIGHT);
    bgView.hidden = pos == 0;
    [bgView bringSubviewToFront:topLine];
    [bgView bringSubviewToFront:bottomLine];
    [lastModel setBottomLineHidden:YES];
}

- (void)setOperateHidden:(BOOL)ifHidden operateType:(OperationCellType)type{
    for ( CenterOperateCellAction *action in _operateArray ){
        if ( action.type == type ){
            [action setViewHidden:ifHidden];
            break;
        }
    }
}

- (void)setDotType:(PointType)dotType withNum:(NSInteger)num operateType:(OperationCellType)type{
    for ( CenterOperateCellAction *action in _operateArray ){
        if ( action.type == type ){
            [action setDotType:dotType withNum:num];
            break;
        }
    }
}

- (void)setTitle:(NSString *)title operatonType:(OperationCellType)type {
    for ( CenterOperateCellAction *action in _operateArray ){
        if ( action.type == type ){
            [action setTitle:title];
            break;
        }
    }
}

- (void)setSubTitle:(NSString *)subtitle operationType:(OperationCellType)type {
    for ( CenterOperateCellAction *action in _operateArray ){
        if ( action.type == type ){
            [action setSubTitle:subtitle];
            break;
        }
    }
}

- (void)setSubTitleAlpha:(CGFloat)alpha operationType:(OperationCellType)type {
    for ( CenterOperateCellAction *action in _operateArray ){
        if ( action.type == type ){
            [action setSubTitleAlpha:alpha];
            break;
        }
    }
}

- (void)refreshNoahPush {
    for (CenterOperateCellAction *action in _operateArray) {
        if (action.type == HELP_INFO) {
            NSInteger num = [UserDefaultsManager intValueForKey:UMFEEDBACK_MESSAGE_COUNT defaultValue:0];
            if (num > 0) {
                [action setDotType:PTNum withNum:num];
            }
        } else {
            PointType type = [[NoahManager sharedPSInstance]getGuidePointType:action.guidePointId];
            if (type > PTHide) {
                [action setDotType:type withNum:0];
                [[NoahManager sharedPSInstance]getGuidePointShown:action.guidePointId];
            }
        }
    }
}

- (NSString *)getGuidePointId:(OperationCellType)type {
    for ( CenterOperateCellAction *action in _operateArray ){
        if ( action.type == type ){
            return action.guidePointId;
        }
    }
    return nil;
}

- (CenterOperateInfo *) getInfo {
    return _info;
}

@end
