//
//  AntiharassLoadingView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/16.
//
//

#import "AntiharassStepView.h"

@interface AntiharassLoadingView : AntiharassStepView
- (instancetype)initWithStep:(AntiharassViewStep)step;
- (void)refreshPercent:(NSInteger)percent;
- (void)refreshStep:(AntiharassModelStep)step;
@end
