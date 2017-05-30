//
//  DefaultSettingPageView.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-19.
//
//

#import <UIKit/UIKit.h>
#import "SettingPageModel.h"

@protocol SettingPageViewDelegate <NSObject>
-(void)refreshPage;
@end

@interface DefaultSettingPageView : UIView<SettingPageViewDelegate>
+(DefaultSettingPageView*) pageViewWithFrame:(CGRect) frame controller:(id<UITableViewDataSource, UITableViewDelegate>)controller andPageModel:(SettingPageModel *)pageModel;
- (id)initWithFrame:(CGRect)frame controller:(id<UITableViewDataSource, UITableViewDelegate>)controller andPageModel:(SettingPageModel *)pageModel;
@end
