//
//  SearchResultCell.m
//  TouchPalDialer
//
//  Created by zhang Owen on 11/11/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "SearchResultCell.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
// model
#import "ImageCacheModel.h"
#import "Person.h"
#import "consts.h"
#import "SkinHandler.h"
#import "ContactInfoManager.h"
#import "AppSettingsModel.h"
#import "CallLogCell.h"
#import "FunctionUtility.h"
#import "BaseCommonCell.h"

@implementation SearchResultCell {
    CGRect _contentFrame;
}
@synthesize detailButton = _detailButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contentFrame = CGRectMake(0, 0, TPScreenWidth(), CALLLOG_CELL_HEIGHT);
        self.userContentView.frame = _contentFrame;
        
		// detail button
        CGFloat detailWidth = 50;
        _detailButton = [[TPUIButton alloc]initWithFrame:CGRectMake(_contentFrame.size.width - detailWidth, 0, detailWidth,  _contentFrame.size.height)];
        _detailButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_detailButton addTarget:self action:@selector(accessoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //
        PanContactsCellStrategy *tmpActionStragegy = [[PanContactsCellStrategy alloc] init];
        self.actionStrategy = tmpActionStragegy;
        
        if ([[AppSettingsModel appSettings]slide_confirm]) {
            [self openSlideItem];
        }else{
            [self closeSlideItem];
        }
        self.isHighlightedNumber = YES;
        self.isHighlightedName = YES;
        
        // view settings
        [self setLeftMargin:CALLLOG_CELL_MARGIN_LEFT forViews:@[self.numberLabel, self.nameLabel]];
        [self adjustNameAndNumberLabel];
        [FunctionUtility setY:(_contentFrame.size.height - self.bottomLine.frame.size.height) forView:self.bottomLine];
        [FunctionUtility setY:(_contentFrame.size.height - self.partBottomLine.frame.size.height) forView:self.partBottomLine];
        [FunctionUtility setX:CALLLOG_CELL_MARGIN_LEFT forView:self.partBottomLine];
        [FunctionUtility setX:CALLLOG_CELL_MARGIN_LEFT forView:self.bottomLine];
        
        // view tree
        [self.userContentView addSubview:_detailButton];
    }
    return self;
}

- (void)accessoryButtonClicked:(id)sender {
	cootek_log(@"accessoryButtonClicked SearchResultCell*********** go to detail");
    DialResultModel *currentResultData = (DialResultModel *)self.currentData;
    if (currentResultData) {
        if (currentResultData.personID > 0) {
            [[ContactInfoManager instance] showContactInfoByPersonId:currentResultData.personID];
        }else{
            [[ContactInfoManager instance] showContactInfoByPhoneNumber:currentResultData.number];
        } 
        [self goToDetail];
    }
}
- (void)setDataToCell{
    if(self.currentData == nil) {
        return;
    }
    [super setDataToCell];
}
- (NSMutableArray *)getArratFromRange:(NSRange)range{
    return [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:range.location], 
            [NSNumber numberWithInt:range.length],
            nil];
}
- (BOOL)isShowNumberAttr{
    return YES;
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
}

- (id)selfSkinChange:(NSString *)style{
     [super selfSkinChange:style];
     NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
     [_detailButton setImage:[[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:@"detailButton_backgroundImage"]] forState:UIControlStateNormal];
     [_detailButton setImage:[[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:@"detailButton_backgroundImage_ht"]] forState:UIControlStateHighlighted];
     NSNumber * toTop = [NSNumber numberWithBool:YES];
     return toTop;
}
#pragma mark LongGestureCellDelegate

- (void)setLongGestureMode:(BOOL)inLongGesture
{
    [super setLongGestureMode:inLongGesture];
    self.detailButton.enabled = !inLongGesture;
}

#pragma mark helpers
- (void) setLeftMargin:(CGFloat)magin forViews:(NSArray *)views {
    for(UIView *view in views) {
        CGRect frame = view.frame;
        view.frame = CGRectMake(magin, frame.origin.y, frame.size.width, frame.size.height);
    }
}
@end
