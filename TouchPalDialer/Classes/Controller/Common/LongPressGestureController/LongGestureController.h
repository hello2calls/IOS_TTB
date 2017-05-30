//
//  LongGestureController.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-8.
//
//

#import <Foundation/Foundation.h>
#import "SearchResultModel.h"
#import "OperationCommandBase.h"
@class LongGestureOperationView;
typedef enum {
    LongGestureSupportedTypeDialer,
    LongGestureSupportedTypeDialerSearch,
    LongGestureSupportedTypeAllContact,
    LongGestureSupportedTypeFilterContactResult,
    LongGestureSupportedTypeSearchContactResult,
    LongGestureSupportedTypeYellowMainDetail,
} LongGestureSupportedType;

@protocol LongGestureCellDelegate
- (id)currentData;
- (void)setLongGestureMode:(BOOL)inLongGesture;
- (BOOL)supportLongGestureMode;
@end

@protocol LongGestureStatusChangeDelegate <NSObject>
- (void)enterLongGestureMode;
- (void)exitLongGestureMode;
@optional
- (void)exitLongGestureModeWithHintButton;
@end

@interface LongGestureController : NSObject<LongGestureStatusChangeDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) LongGestureSupportedType longGestureSupportedType;
@property (nonatomic, assign) BOOL inLongGestureMode;
@property (nonatomic, retain) NSIndexPath *currentSelectIndexPath;
@property (nonatomic, assign) BOOL enableLongGesture;
@property (nonatomic, assign) BOOL showScrollToShow;
@property (nonatomic, retain) LongGestureOperationView *operView;

- (id)initWithViewController:(UINavigationController *)navController
                   tableView:(UITableView *)tableView
                    delegate:(id<LongGestureStatusChangeDelegate>)delegate
               supportedType:(LongGestureSupportedType)type;
- (void)tearDown;
- (NSIndexPath *)willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)exitLongGestureModeWhenScrollView;
@end
