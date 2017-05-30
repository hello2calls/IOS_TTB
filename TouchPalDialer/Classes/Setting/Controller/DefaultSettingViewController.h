//
//  SettingViewController.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-19.
//
//

#import "CootekViewController.h"
#import "SettingPageModel.h"

@interface DefaultSettingViewController : CootekViewController <UITableViewDataSource, UITableViewDelegate>
+(DefaultSettingViewController*) controllerWithPageModel:(SettingPageModel*) pageModel;
- (id)initWithPageModel:(SettingPageModel*) pageModel;
- (void)gotoBack;
@end
