//
//  CenterOperateRectSection.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/31.
//
//

#import "CenterOperateRectSectionAction.h"
#import "TPDialerResourceManager.h"
#import "CenterOperateInfo.h"
#import "CenterOperationRectCellAction.h"

#define RECT_HEIGHT (112)

@implementation CenterOperateRectSectionAction {
    UIView *_contentView;
    CGFloat _cellX;
    CGFloat _cellW;
    CGFloat _cellY;
    UIView *_contentBg;
}

- (id)initWithHostView:(UIView *)hostView {
    self = [super init];
    if (self) {
        self.operateArray = [NSMutableArray arrayWithCapacity:3];
        CGFloat height = RECT_HEIGHT;
        CGFloat gap = 20;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), height + gap)];
        [hostView addSubview:_contentView];
        UIView *contentBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), RECT_HEIGHT)];
        contentBg.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        [_contentView addSubview:contentBg];
        _contentBg = contentBg;
        
        CGFloat dividerWidth = (hostView.frame.size.width - 2 *15)/3;
        _cellX = 15;
        _cellW = dividerWidth;
        _cellY = 0;
        CGFloat dividerX1 = _cellX + dividerWidth;
        CGFloat dividerX2 = dividerX1 + dividerWidth;
        [self addDivider:dividerX1];
        [self addDivider:dividerX2];


        UIView *bottomGap = [[UIView alloc]initWithFrame:CGRectMake(0, contentBg.frame.size.height, TPScreenWidth(), gap)];
        [_contentView addSubview:bottomGap];

    }
    return self;
}

- (void)addDivider:(CGFloat)dividerX {
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(dividerX, _cellY + 10, 0.5, RECT_HEIGHT - 2*10)];
    divider.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
    [_contentView addSubview:divider];
}


- (void)addOperateInfo:(CenterOperateInfo *)info {
    if (self.operateArray.count % 3 == 0 && self.operateArray.count > 0) {
        _cellY += RECT_HEIGHT;
        _cellX = 15;
        [self extendContent];
    }
    CenterOperationRectCellAction *actionCell = [[CenterOperationRectCellAction alloc] initWithHostView:_contentView DisplayArea:CGRectMake(_cellX, _cellY, _cellW, RECT_HEIGHT) operateInfo:info];
    _cellX += _cellW;
    [self.operateArray addObject:actionCell];
}


- (void)setOriginY:(CGFloat)originY {
    _contentView.frame = CGRectMake(_contentView.frame.origin.x, originY, _contentView.frame.size.width, _contentView.frame.size.height);
}

- (CGFloat)getSectionHeight {
    return _contentView.frame.size.height;
}

- (void)extendContent {
    
    UIView *horiDivider = [[UIView alloc] initWithFrame:CGRectMake(_cellX, _cellY, _contentView.frame.size.width - 2*_cellX, 0.5)];
    horiDivider.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
    [_contentView addSubview:horiDivider];
    
    CGRect origFrame = _contentView.frame;
    _contentView.frame = CGRectMake(origFrame.origin.x, origFrame.origin.y, origFrame.size.width, origFrame.size.height + RECT_HEIGHT);
    CGRect contentFrame = _contentBg.frame;
    _contentBg.frame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y, contentFrame.size.width, contentFrame.size.height + RECT_HEIGHT);
    CGFloat dividerX1 = _cellX + _cellW;
    CGFloat dividerX2 = dividerX1 + _cellW;
    [self addDivider:dividerX1];
    [self addDivider:dividerX2];
}

- (void)addTopLine {
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(15, 0, _contentView.frame.size.width - 2 *15, 0.5)];
    divider.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
    [_contentView addSubview:divider];
}

@end
