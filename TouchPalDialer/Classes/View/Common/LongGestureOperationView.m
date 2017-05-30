//
//  LongGestureOperationView.m
//  TableViewMultiSelect
//
//  Created by Liangxiu on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LongGestureOperationView.h"
#import "HeaderBar.h"
#import "ImageViewUtility.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "TPHeaderButton.h"
#import "OperationCommandCreator.h"
#import "CommandDataHelper.h"
#import "Favorites.h"
#import "RemoveCallsCommand.h"
#import "FunctionUtility.h"
#import "DialerUsageRecord.h"
#import "UsageConst.h"
#import "AllViewController.h"

@interface LongGestureOperationView()<UIActionSheetDelegate>{
    CGRect originalTableFrame;
    int is_first_loaded;
    BOOL isExecutingCommand;
    CGRect _holderFrame;
}

@property (nonatomic, retain) NSArray *allCurrentCommands;
@property (nonatomic, retain) NSArray *allPopupSheetCommands;
@property (nonatomic, retain) NSDictionary *skinProperties;
@property (nonatomic, retain) NSDictionary *triangleSkinProperties;
@property (nonatomic, retain) TPUIButton *cancelButton;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIScrollView *bottomScrollView;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) id userdata;
@property (nonatomic, retain) UIButton *triangleView;
@property (nonatomic, retain) UIButton *bgView;
@end

@implementation LongGestureOperationView

static NSDictionary *operationsDic;

@synthesize rootViewController;
@synthesize delegate;
@synthesize supportedType;
@synthesize allCurrentCommands;
@synthesize allPopupSheetCommands;
@synthesize skinProperties;
@synthesize triangleSkinProperties;
@synthesize cancelButton;
@synthesize headerView;
@synthesize bottomView;
@synthesize bottomScrollView;
@synthesize textLabel;
@synthesize userdata;
@synthesize triangleView;
@synthesize bgView;

+ (void)initialize
{
    NSDictionary *operDics = [[NSDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"multiSelectOperations.plist"]];
    operationsDic = operDics;
}

- (UIView *)initWithTableName:(NSString *)tableName frame:(CGRect)frame {
    self = [super init];
    if (self) {
        _holderFrame = frame;
        bottomView = [[UIView alloc] initWithFrame:frame];
//        bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [bottomView setNeedsDisplay];
        
    }
    return self;
}

-(void)drawRect: (CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBStrokeColor(context, 0,0,0,0.2);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 3, 3);
    CGContextAddLineToPoint(context, 150, 3);
    CGContextStrokePath(context);
}

- (void) loadOperationForData:(id)data forColorfulCell:(BOOL)isColorfulCell
{
    userdata = data;
    self.allCurrentCommands = [LongGestureOperationView commandsForData:data withLongGestureSupportedType:supportedType];
    isExecutingCommand = NO;
    if  ([self.allCurrentCommands count] == 0) {
        return;
    }
    self.skinProperties = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"longPressView_style"];
    // dimensions
    CGFloat holderHeight = _holderFrame.size.height;
    CGFloat btnWidth = TPScreenWidth() / 5.0 ;
    
    // triangle, by an image
    CGFloat triangleWidth = 8;
    CGFloat triangleX = 40;
    if (_shouldTriangleInMiddle) {
        triangleX = CONTACT_CELL_MARGIN_LEFT / 2 - triangleWidth / 2;
    }
    triangleView = [[UIButton alloc] initWithFrame:CGRectMake(triangleX , -5, triangleWidth, 5)];
    bgView = [[UIButton alloc] initWithFrame:_holderFrame];
    
    if (isColorfulCell) {
        // do not support the colorfull cell now
    } else {
        [triangleView setImage:[[TPDialerResourceManager sharedManager] getImageByName:[skinProperties objectForKey:@"triangle_image"]] forState:UIControlStateNormal];
        
        [bgView setImage:[FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[skinProperties objectForKey:@"bottom_backgroundColor"]] withFrame:CGRectMake(0, 0, TPScreenWidth(), holderHeight)] forState:UIControlStateNormal];
    }
    
    textLabel.text = [CommandDataHelper displayNameFromData:data];
    if(bottomScrollView != nil) {
        [bottomScrollView removeFromSuperview];
    }
    
    // scroll view as a holder for buttons
    bottomScrollView = [[UIScrollView alloc] initWithFrame:_holderFrame];
    bottomScrollView.showsHorizontalScrollIndicator = YES;
    bottomScrollView.bounces = YES;
    bottomScrollView.delegate = self;
    bottomScrollView.scrollEnabled = YES;
    bottomScrollView.backgroundColor = [UIColor clearColor];
    bottomScrollView.contentSize = CGSizeMake( btnWidth *[self.allCurrentCommands count], holderHeight);

    // buttons
    int i = 0;
    
    for(OperationCommandBase* command in self.allCurrentCommands) {
        command.delegate = self;
        command.navController = self.rootViewController;
        NSDictionary* operAttrs = operationsDic[NSStringFromClass([command class])];
        
        TPUIButton *button = [[TPUIButton alloc] initWithFrame:CGRectMake(btnWidth * i, 0, btnWidth, holderHeight)];
        
        [button setBackgroundColor:[UIColor clearColor]];
        [button setImage:[[TPDialerResourceManager sharedManager] getImageByName:[operAttrs objectForKey:@"backGroundImageInNormalState"]] forState:UIControlStateNormal];
        [button setImage:[[TPDialerResourceManager sharedManager] getImageByName:[operAttrs objectForKey:@"backGroundImageInNormalState"]] forState:UIControlStateHighlighted];
        [button setImageEdgeInsets:UIEdgeInsetsMake(-10.0, 0.0, 10.0, 0.0)];
        
        [button setBackgroundImage:[FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"blackWith_0.1_alpha_color"] withFrame:CGRectMake(0, 0, btnWidth, holderHeight)] forState:UIControlStateHighlighted];
        if ([operAttrs[@"displayName"] isEqualToString:@"More"]) {
            self.allPopupSheetCommands = [LongGestureOperationView excutablePopupCommandsForData:data withLongGestureSupportedType:supportedType];
            [button addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:command action:@selector(execute) forControlEvents:UIControlEventTouchUpInside];
        }
        
        NSString *title = NSLocalizedString([operAttrs objectForKey:@"displayName"],@"");
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 37, TPScreenWidth()/5, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = title;
        titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5];
        titleLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[skinProperties objectForKey:@"operationLabel_textColor_color"]];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addSubview:titleLabel];
        if (![command canExecute]) {
            button.enabled = NO;
            titleLabel.alpha = 0.5;
        }
        
        [bottomScrollView addSubview:button];
        i++;
    }
    
    is_first_loaded = NO;
    
    // view tree
    [bottomView addSubview:bgView];
    [bottomView addSubview:triangleView]; //
    [bottomView addSubview:bottomScrollView];
    
}

- (void)showMore {
    [delegate exitLongGestureMode];
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
    NSMutableArray *contentArray = [[NSMutableArray alloc]initWithCapacity:[self.allPopupSheetCommands count]+1];
    for(OperationCommandBase* command in self.allPopupSheetCommands) {
        command.delegate = self;
        command.navController = self.rootViewController;
        NSDictionary* operAttrs = operationsDic[NSStringFromClass([command class])];
        NSString *title;
        if ([[operAttrs objectForKey:@"displayName"] isEqualToString:@"AddToFavorite"]) {
            BOOL isFavorite = [Favorites isExistFavorite:[userdata personID]];
            if (isFavorite) {
                title = NSLocalizedString(@"detail_shortcut_unfavor", @"");
            } else {
                title = NSLocalizedString(@"detail_shortcut_favor", @"");
            }
        } else {
            title = NSLocalizedString([operAttrs objectForKey:@"displayName"],@"");
        }
        [contentArray addObject:title];
    }
    
//    CooTekPopUpSheet *popUpSheet = [[CooTekPopUpSheet alloc] initWithTitle:@"更多功能" content:contentArray type:PopUpsheetTypeMore];
//    popUpSheet.delegate = self;
//    [rootViewController.topViewController.view addSubview:popUpSheet];
//    [popUpSheet release];
//    [contentArray release];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    for (NSString *title in contentArray) {
        [actionSheet addButtonWithTitle:title];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = [contentArray count];
    
    [actionSheet showInView:rootViewController.topViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [self.allPopupSheetCommands count]) {
        OperationCommandBase* command = self.allPopupSheetCommands[0];
        [command notifyCommandExecuted];
    } else {
        OperationCommandBase* command = self.allPopupSheetCommands[buttonIndex];
        command.delegate = self;
        command.navController = self.rootViewController;
        [command performSelector:@selector(execute)];
        
        [command notifyCommandExecuted];
    }
}

//- (void)doClickOnCancelButtonWithTag:(int)tag
//{
//    OperationCommandBase* command = self.allPopupSheetCommands[0];
//    [command notifyCommandExecuted];
//}
//
//- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info {
//    
//    OperationCommandBase* command = self.allPopupSheetCommands[index];
//    command.delegate = self;
//    command.navController = self.rootViewController;
//    [command performSelector:@selector(execute)];
//    
//    [command notifyCommandExecuted];
//}

- (void)cancelPressed
{
    [delegate exitLongGestureMode];
}

- (void)dealloc
{
    [SkinHandler removeRecursively:self.headerView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onLongGesturePressed
{
    UIViewController* tmpController = rootViewController.topViewController;
    [tmpController.view addSubview:bottomView];
}

- (void)removeLongGestureOperationView
{
    [self.bottomView removeFromSuperview];
}

- (void)animatedShow
{
     [UIView animateWithDuration:0.2f
                           delay:0.0f
                         options:UIViewAnimationOptionCurveEaseOut
                      animations:^{
                           
                           self.headerView.frame = CGRectMake(0, 0, TPScreenWidth(), 50);
                           self.bottomView.frame = CGRectMake(0, 50, TPScreenWidth(), 50);
                                       }
                      completion:^(BOOL finished){
                      }];
}
- (void)animatedShow :(TPUIButton *)button andIndex:(int)i 
{
      CGRect originalFrame = [button frame];
     [UIView animateWithDuration:(0.1*i)
                           delay:0.0
                         options:UIViewAnimationOptionCurveEaseOut
                      animations:^{
                           
                           button.frame = CGRectMake(originalFrame.origin.x, 50, originalFrame.size.width, originalFrame.size.height);
                           button.frame = originalFrame;
                      }
                      completion:^(BOOL finished){
                      }];
}

- (void)animatedOut
{
     [UIView animateWithDuration:0.2f
                           delay:0.0f
                         options:UIViewAnimationOptionCurveEaseOut
                      animations:^{
                           
                           self.headerView.frame = CGRectMake(0, -50, TPScreenWidth(), 50);
                           self.bottomView.frame = CGRectMake(0, 0, TPScreenWidth(), 50);
                      }
                      completion:^(BOOL finished){
                           if (finished) {
                                
                                [self.headerView removeFromSuperview];
                                [self.bottomView removeFromSuperview];
                           }
                      }];
}

#pragma mark scrollViewDelegte
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark
- (BOOL)willExecuteCommand
{
    if (isExecutingCommand) {
        return NO;
    }
    
    isExecutingCommand = YES;
    return YES;
}

- (void)didExecuteCommand
{
    [delegate exitLongGestureMode];
    isExecutingCommand = NO;
}

#pragma mark long gesture commands
+ (NSArray *)commandsForData:(id)data withLongGestureSupportedType:(LongGestureSupportedType)supportedType
{
    NSArray *allSupportedCommands = nil;
    int personId = [CommandDataHelper personIdFromData:data];
    NSArray *callTimes = [RemoveCallsCommand getTheFirstANDLastCallTimeWithPersonID:personId orPhoneNumber:[CommandDataHelper phoneNumberFromData:data]];
    switch (supportedType) {
        case LongGestureSupportedTypeAllContact:
        case LongGestureSupportedTypeFilterContactResult:
        case LongGestureSupportedTypeSearchContactResult:
            
            allSupportedCommands = @[@(CommandTypeMakeCall),
                                     @(CommandTypeSendSMS),
                                     @(CommandTypeDeleteContact),
                                     @(CommandTypeEditContact),
                                     @(CommandTypeMore),
                                     ];
            break;
        case LongGestureSupportedTypeDialer:
        case LongGestureSupportedTypeDialerSearch:
            
            if(personId <= 0){
                allSupportedCommands = @[@(CommandTypeAddToContact),
                                         @(CommandTypeRemoveCalls),
                                         @(CommandTypeSendSMS),
                                         @(CommandTypeShareContact),
                                         @(CommandTypeMore),
                                         ];
            }else{
                if ([callTimes count]>0) {
                    allSupportedCommands = @[@(CommandTypeEditContact),
                                             @(CommandTypeCopyPhoneNumber),
                                             @(CommandTypeRemoveCalls),
                                             @(CommandTypeSendSMS),
                                             @(CommandTypeMore),
                                             ];
                }else {
                    allSupportedCommands = @[@(CommandTypeEditContact),
                                             @(CommandTypeCopyPhoneNumber),
                                             @(CommandTypeShareContact),
                                             @(CommandTypeSendSMS),
                                             @(CommandTypeMore),
                                             ];
                }
            }
            break;
        case LongGestureSupportedTypeYellowMainDetail:
            allSupportedCommands = @[@(CommandTypeEditToCall),
            @(CommandTypeShareContact),
            @(CommandTypeReportShop),
            @(CommandTypeCopyPhoneNumber),
            @(CommandTypeMore),
            ];
        default:
            break;
    }
    
    if (allSupportedCommands) {
        return [self excutableCommandsForData:data WithCommandTypes:allSupportedCommands];
    } else {
        return nil;
    }
}

+ (NSArray *)excutableCommandsForData:(id)data WithCommandTypes:(NSArray *)commandTypes
{
    NSMutableArray *commands = [NSMutableArray arrayWithCapacity:[commandTypes count]];
    for (NSNumber* t in commandTypes) {
        OperationCommandBase *command = [OperationCommandCreator commandForType:(CommandType)[t integerValue] withData:data];
        if (YES||command.canExecute) {
            [commands addObject:command];
        }
    }
    
    return commands;
}

+ (NSArray *)excutablePopupCommandsForData:(id)data withLongGestureSupportedType:(LongGestureSupportedType)supportedType{
    NSArray *commandTypes = nil;
    int personId = [CommandDataHelper personIdFromData:data];
    NSArray *callTimes = [RemoveCallsCommand getTheFirstANDLastCallTimeWithPersonID:personId orPhoneNumber:[CommandDataHelper phoneNumberFromData:data]];
    switch (supportedType) {
        case LongGestureSupportedTypeAllContact:
        case LongGestureSupportedTypeFilterContactResult:
        case LongGestureSupportedTypeSearchContactResult:
            commandTypes = @[@(CommandTypeShareContact),
                             @(CommandTypeAddToFavorite),
                             ];
            break;
        case LongGestureSupportedTypeDialer:
        case LongGestureSupportedTypeDialerSearch:
            if(personId <= 0){
                commandTypes = @[@(CommandTypeCopyPhoneNumber),
                                 @(CommandTypeEditToCall),
                                 ];
            } else {
                if ([callTimes count]>0) {
                    commandTypes = @[@(CommandTypeShareContact),
                                     @(CommandTypeEditToCall),
                                     @(CommandTypeDeleteContact),
                                     @(CommandTypeAddToFavorite),
                                     ];
                } else {
                    commandTypes = @[@(CommandTypeEditToCall),
                                     @(CommandTypeDeleteContact),
                                     @(CommandTypeAddToFavorite),
                                     ];
                }
            }
        default:
            break;
    }
    
    NSMutableArray *commands = [NSMutableArray arrayWithCapacity:[commandTypes count]];
    for (NSNumber *t in commandTypes) {
        OperationCommandBase *command = [OperationCommandCreator commandForType:(CommandType)[t integerValue] withData:data];
        if (YES||command.canExecute) {
            [commands addObject:command];
        }
    }
    return commands;
}

@end
