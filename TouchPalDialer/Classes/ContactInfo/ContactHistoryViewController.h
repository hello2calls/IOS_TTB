//
//  ContactHistoryViewController.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/23.
//
//

#import <UIKit/UIKit.h>
#import "ContactInfoModel.h"
#import "CallLogDataModel.h"

@protocol ContactHistoryViewControllerDelegate <NSObject>
- (void) headerLeftButtonAction:(ContactHeaderMode)model;
- (void) headerRightButtonAction:(ContactHeaderMode)model;
- (void) deallocHistoryViewController;
- (void) deleteCallLog:(CallLogDataModel *)model;
- (void) onSelectHistoryCell:(CallLogDataModel *)model;
@end

@interface ContactHistoryViewController : UIViewController
@property (nonatomic,assign) id<ContactHistoryViewControllerDelegate> delegate;
@property (nonatomic,strong) ContactInfoModel *infoModel;
@property (nonatomic,strong) NSArray *callList;
- (void) refreshHeaderMode:(ContactHeaderMode)mode;
- (void) refreshView;
- (void) showEditingMode;
- (void) exitEditingMode;
@end
