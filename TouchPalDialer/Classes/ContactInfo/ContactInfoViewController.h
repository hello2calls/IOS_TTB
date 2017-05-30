//
//  ContactInfoViewController.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/16.
//
//

#import <UIKit/UIKit.h>
#import "ContactInfoManager.h"
#import "ContactInfoModel.h"
#import "ContactInfoCellModel.h"

@protocol ContactInfoViewControllerDelegate<NSObject>
- (void)popViewController;
- (void)onRightButtonAction;
- (void)onIconButtonAction;
- (void)onButtonPressed:(NSInteger)tag;
- (void)deallocTheController;
- (void)onCellRightButtonPressed:(ContactInfoCellModel *)model;
- (void)onSelectCell:(ContactInfoCellModel *)model;
@end

@interface ContactInfoViewController : UIViewController
@property (nonatomic, assign) id<ContactInfoViewControllerDelegate> delegate;
@property (nonatomic, strong) ContactInfoModel *infoModel;
@property (nonatomic, strong) NSArray *numberArray;
@property (nonatomic, strong) NSArray *subArray;
@property (nonatomic, strong) NSArray *shareArray;
- (void) refreshButtonView;
- (void) refreshView;
- (void) refreshTableView;
@end
