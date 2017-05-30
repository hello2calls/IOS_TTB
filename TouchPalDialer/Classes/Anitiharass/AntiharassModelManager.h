//
//  AntiharassModelManager.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/16.
//
//

#import <Foundation/Foundation.h>
#import "AntiharassUtil.h"


@protocol AntiharassModelManagerDelegate <NSObject>
- (void)doModelResult:(AntiharassModelResult)result;
- (void)refreshLoadingViewStage:(AntiharassModelStep)step;
- (void)refreshLoadingViewPercent:(NSInteger)percent;
@end

@interface AntiharassModelManager : NSObject
@property (nonatomic,assign) id<AntiharassModelManagerDelegate> delegate;
- (void) doTask:(AntiharassModelStep)step;
- (void) setLastTask:(AntiharassModelStep)step;
- (void) doLastTask;
@end
