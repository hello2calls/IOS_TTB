//
//  AntiharassViewManager.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/16.
//
//

#import <Foundation/Foundation.h>
#import "AntiharassUtil.h"

@protocol AntiharassViewManagerDelegate <NSObject>
- (void)finishViewStep:(AntiharassViewStep)step;
@end

@interface AntiharassViewManager : NSObject
@property (nonatomic,assign) id<AntiharassViewManagerDelegate> delegate;
- (void) showView:(AntiharassViewStep)step;
- (void) refreshLoadingViewStage:(AntiharassModelStep)result;
- (void) refreshLoadingViewPercent:(NSInteger)percent;
- (void) clearView;
- (void)clickCancelButton;
@end
