//
//  LongGestureController.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-8.
//
//

#import "LongGestureController.h"
#import "TouchPalDialerAppDelegate.h"
#import "LongGestureOperationView.h"
#import "CootekTableViewCell.h"
#import "RootScrollViewController.h"
#import "CommandDataHelper.h"
#import "WithEyeViewForBaseContactCell.h"
#import "AllViewController.h"


@interface LongGestureController() {
    __weak UINavigationController *navController_;
    __weak UITableView *tableView_;
    __weak id<LongGestureStatusChangeDelegate> delegate_;
    __weak id<UITableViewDataSource> originalDatasource_;
    __weak id<UITableViewDelegate> originalTableViewDelegate_;
}

@property (nonatomic, retain) UILongPressGestureRecognizer *recognizer;

@end

@implementation LongGestureController

@synthesize longGestureSupportedType;
@synthesize inLongGestureMode;
@synthesize currentSelectIndexPath = currentSelectIndexPath_;
@synthesize recognizer;
@synthesize operView;
@synthesize enableLongGesture = enableLongGesture_;
@synthesize showScrollToShow;

#pragma mark lifecycle
- (id)initWithViewController:(UINavigationController *)navController
                   tableView:(UITableView *)tableView
                    delegate:(id<LongGestureStatusChangeDelegate>)delegate
               supportedType:(LongGestureSupportedType)type
{
    self = [super init];
    if (self) {
        longGestureSupportedType = type;
        enableLongGesture_ = YES;
        inLongGestureMode = NO;
        navController_ = navController;
        tableView_ = tableView;
        delegate_ = delegate;
        
        originalDatasource_ = tableView_.dataSource;
        originalTableViewDelegate_ = tableView_.delegate;
        tableView_.dataSource = self;
        tableView_.delegate = self;
        
        self.recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureHandler:)];
        recognizer.minimumPressDuration = 0.6;
        [tableView_ addGestureRecognizer:recognizer];
    }
    
    return self;
}

- (void)tearDown
{
    [tableView_ removeGestureRecognizer:recognizer];
    tableView_.dataSource = originalDatasource_;
    tableView_.delegate = originalTableViewDelegate_;
    [self exitLongGestureMode];
    navController_ = nil;
    tableView_ = nil;
    delegate_ = nil;
    self.recognizer = nil;
}

#pragma mark long gesture handler

- (void)setEnableLongGesture:(BOOL)enable
{
    enableLongGesture_ = enable;
    if (!enable) {
        [self exitLongGestureMode];
    }
}

- (void)longGestureHandler:(UILongPressGestureRecognizer *)gesture{
    if (!self.enableLongGesture) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UITableView *t = (UITableView *)gesture.view;
        CGPoint p = [gesture locationInView:t];
        NSIndexPath *index = [t indexPathForRowAtPoint:p];
        if ([self cellSupportLongGesture:index]) {
            
            if ([self inLongGestureMode]) {
                [self exitLongGestureMode];
//                return;
            }
            // The tableview's indexPathForRowAtPoint might return the cell below the section header,
            // if the point is in the section header.
            // This might be by design of the UITableView, but we don't like the behavior
            // which user press the section header but the row below it get selected.
            // Compare the point and frame's value to know if the cell is really selected.
            CGRect frame = [[t cellForRowAtIndexPath:index] frame];
//            if (p.y < frame.origin.y || p.y > (frame.origin.y + frame.size.height)) {
            if (p.y < frame.origin.y){
                gesture.cancelsTouchesInView = NO;
                [self exitLongGestureMode];
                return;
            }
            NSArray *indexPathArray = [t indexPathsForVisibleRows];
            for (int i = [indexPathArray count]-1; i >= [indexPathArray count]-2; i --) {
                if ([index compare:indexPathArray[i]] == NSOrderedSame) {
                    showScrollToShow = YES;
                    break;
                }
            }
            gesture.cancelsTouchesInView = YES;
            self.currentSelectIndexPath = index;
            [self enterLongGestureMode];
            [t deselectRowAtIndexPath:index animated:YES];
//            [t selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            [self exitLongGestureMode];
            gesture.cancelsTouchesInView = NO;
        }
    }
}

- (void)enterLongGestureMode
{
    if (enableLongGesture_) {
        cootek_log(@"enter long gesture mode");
        if (!inLongGestureMode) {
            inLongGestureMode = YES;
            CGRect cellFrame = [tableView_ rectForRowAtIndexPath:currentSelectIndexPath_];
            CGRect frame = CGRectMake(0, 0, TPScreenWidth(), cellFrame.size.height);
            self.operView = [[LongGestureOperationView alloc] initWithTableName:@"test" frame:frame];
            operView.rootViewController = navController_;
            operView.delegate = self;
            operView.supportedType = self.longGestureSupportedType;
            operView.shouldTriangleInMiddle = [originalTableViewDelegate_ isKindOfClass:[AllViewController class]];
            [self selectItem:currentSelectIndexPath_];
            [tableView_ reloadData];
            [delegate_ enterLongGestureMode];
        }
        
    }
}

- (void)exitLongGestureMode
{
    cootek_log(@"exit long gesture mode");
    if (inLongGestureMode) {
        inLongGestureMode = NO;
        self.currentSelectIndexPath = nil;
        [operView removeLongGestureOperationView];
        [tableView_ selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
        [tableView_ reloadData];
        [delegate_ exitLongGestureMode];
    }
}

- (void)exitLongGestureModeWithHintButton
{
    cootek_log(@"exit long gesture mode");
    if (inLongGestureMode) {
        inLongGestureMode = NO;
        self.currentSelectIndexPath = nil;
        [operView removeLongGestureOperationView];
        [tableView_ selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
        [tableView_ reloadData];
        [delegate_ exitLongGestureModeWithHintButton];
    }
}

- (void)exitLongGestureModeWhenScrollView
{
    cootek_log(@"exit long gesture mode");
    if (inLongGestureMode) {
        inLongGestureMode = NO;
        self.currentSelectIndexPath = nil;
        [operView removeLongGestureOperationView];
        [tableView_ selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
        [delegate_ exitLongGestureMode];
    }
}

#pragma mark cell selection
- (NSIndexPath *)willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(inLongGestureMode) {
        [self exitLongGestureMode];
        return nil;
//        if(self.currentSelectIndexPath != nil && [indexPath isEqual:self.currentSelectIndexPath]) {
//            [self exitLongGestureMode];
//            return nil;
//        } else {
//            if ([self cellSupportLongGesture:indexPath]) {
//                self.currentSelectIndexPath = indexPath;
//                [self selectItem:indexPath];
//            } else {
//                [self exitLongGestureMode];
//                return nil;
//            }
//        }
    } else {
        // Not in long gesture mode, remove the operview to dealloc resources
        // Refactoring notes: ideally the view should get removed while exit long gesture mode,
        // however currently we need to hold this until all commands done to avoid regression bugs.
        if (self.operView) {
            self.operView = nil;
        }
    }
    
    return indexPath;
}

- (BOOL)cellSupportLongGesture:(NSIndexPath *)indexPath
{
    if (!indexPath) {
        return NO;
    }
    
    UITableViewCell *cell = [tableView_ cellForRowAtIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(LongGestureCellDelegate)]) {
        id<LongGestureCellDelegate> item = (id<LongGestureCellDelegate>)cell;
        return [item supportLongGestureMode];
    } else {
        return NO;
    }
}

- (void)setCurrentSelectIndexPath:(NSIndexPath *)indexPath
{
    if(self.currentSelectIndexPath == indexPath) {
        return;
    }
    
    currentSelectIndexPath_ = indexPath;
}

- (void)selectItem:(NSIndexPath *)indexPath
{
    if ([self cellSupportLongGesture:indexPath]) {
        UITableViewCell *cell = [tableView_ cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:([WithEyeViewForBaseContactCell class])]) {
            [operView loadOperationForData:((id<LongGestureCellDelegate>)cell).currentData forColorfulCell:NO];
        } else {
            [operView loadOperationForData:((id<LongGestureCellDelegate>)cell).currentData forColorfulCell:NO];
        }
    } else {
        [self exitLongGestureMode];
    }
}

-(void) forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    if ([originalDatasource_ respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:originalDatasource_];
        return;
    }
    
    if ([originalTableViewDelegate_ respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:originalTableViewDelegate_];
        return;
    }
    
    @throw [[NSException alloc] initWithName:@"not recoginze exception" reason:@"not recognize exception" userInfo:nil];
    
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [(NSObject *)originalDatasource_ methodSignatureForSelector:selector];
        
        if (!signature) {
            signature = [(NSObject *)originalTableViewDelegate_ methodSignatureForSelector:selector];
        }
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    if ([originalDatasource_ respondsToSelector:aSelector]) {
        return YES;
    }
    
    if ([originalTableViewDelegate_ respondsToSelector:aSelector]) {
        return YES;
    }
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [originalDatasource_ tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(LongGestureCellDelegate)]) {
        [(id<LongGestureCellDelegate>)cell setLongGestureMode:inLongGestureMode];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([originalDatasource_ respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        return [originalDatasource_ tableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([originalTableViewDelegate_ respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        indexPath = [originalTableViewDelegate_ tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return [self willSelectRowAtIndexPath:indexPath];
}
@end

