//
//  ContactInfoViewCopyController.h
//  TouchPalDialer
//
//  Created by H L on 2016/11/16.
//
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import "ContactInfoManager.h"
#import "ContactInfoModel.h"
#import "ContactInfoCellModel.h"

@protocol TPContactInfoViewControllerDelegate<NSObject>
- (void)popViewController;
- (void)onRightButtonAction;
- (void)onIconButtonAction;
- (void)onButtonPressed:(NSInteger)tag;
- (void)deallocTheController;
- (void)onCellRightButtonPressed:(ContactInfoCellModel *)model;
- (void)onSelectCell:(ContactInfoCellModel *)model;
@end

@interface ContactInfoViewCopyController : UIViewController
@property (nonatomic, assign) id<TPContactInfoViewControllerDelegate> delegate;
@property (nonatomic, strong) ContactInfoModel *infoModel;
@property (nonatomic, strong) NSArray *numberArray;
@property (nonatomic, strong) NSArray *subArray;
@property (nonatomic, strong) NSArray *shareArray;
- (void) refreshButtonView;
- (void) refreshView;
- (void) refreshTableView;
@end
