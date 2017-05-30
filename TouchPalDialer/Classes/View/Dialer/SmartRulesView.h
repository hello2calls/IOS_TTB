//
//  SmartRulesView.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 11/7/12.
//
//

#import <UIKit/UIKit.h>

@interface SmartRulesView : UIView <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,copy) void(^doWhenPressDoneButtonBlock)(void);
@end
