    //
//  DialerSearchResultViewController.m
//  TouchPalDialer
//
//  Created by zhang Owen on 11/10/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "DialerSearchResultViewController.h"
#import "SearchResultCell.h"
#import "DialResultModel.h"
#import "Person.h"
#import "NumberPersonMappingModel.h"
#import "PhoneNumber.h"
#import "consts.h"
#import "PhonePadModel.h"
#import "ImageCacheModel.h"
#import "CootekNotifications.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "UITableView+TP.h"
#import "BaseCommonCell.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "FunctionUtility.h"
#import "DialerGuideAnimationUtil.h"
#import "EngineResultModel.h"
#import "ContactSmartSearchDBA.h"
#import "DialerUsageRecord.h"
#import "FunctionUtility.h"

@implementation DialerSearchResultViewController{
//    LongGestureController *longGestureController_;
}
@synthesize result_tableview;
@synthesize shared_phonepadmodel;
@synthesize delegate;
@synthesize tableViewName;
@synthesize CellIdentifier;
@synthesize currentCellName;
@synthesize longGestureController = longGestureController_;
@class BaseCommonCell;
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.shared_phonepadmodel = [PhonePadModel getSharedPhonePadModel];
	// for list view.
	UITableView *tmp_tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(367))];
    [tmp_tableview setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
    [tmp_tableview setExtraCellLineHidden];
	self.result_tableview = tmp_tableview;
	result_tableview.delegate = self;
	result_tableview.dataSource = self;
    result_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:result_tableview];
    CGFloat searchHeight = TPScreenHeight() - TPHeaderBarHeight();
	self.view.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), searchHeight);
    self.CellIdentifier = @"SearchResultCell";
    self.currentCellName =NSStringFromClass([SearchResultCell class]);
    
    longGestureController_ = [[LongGestureController alloc] initWithViewController:((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController
                                                                         tableView:result_tableview
                                                                          delegate:self
                                                                     supportedType:LongGestureSupportedTypeDialerSearch];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    recognizer.delegate = self;
    [result_tableview addGestureRecognizer:recognizer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    cootek_log(@"Received memory warning in DialerSearchResultViewController.");
}

- (void)dealloc {
    for (UITapGestureRecognizer *gesture in [result_tableview gestureRecognizers]) {
        [result_tableview removeGestureRecognizer:gesture];
    }
    [longGestureController_ tearDown];
}

#pragma mark tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare:indexPath] == NSOrderedSame) {
        return CONTACT_CELL_HEIGHT*2;
    } else {
        return CONTACT_CELL_HEIGHT;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([shared_phonepadmodel.input_number isEqualToString:@""]) {
		return 0;
	}
	
	NSString *searchStr=shared_phonepadmodel.calllog_list.searchKey;
	NSString *inputStr=[shared_phonepadmodel getLastestKeyWord];
	if (![searchStr isEqualToString:inputStr]) {
		return 0;	
	}	
    if (0 == [shared_phonepadmodel.calllog_list.searchResults count]) {
        if ([shared_phonepadmodel.input_number isEqualToString:@"*"]||[shared_phonepadmodel.input_number hasSuffix:@"#"]) {
            return CELL_ADD_TO_EXISTING_CONTACT+1;
        }
            return CELL_ADD_TO_EXISTING_CONTACT;
    } else {
        int min_height = TPHeightFit(0);
        int minRows = 0;
        if (min_height == 88)
            minRows = 5;
        else if (min_height == 187)
            minRows = 6;
        else if (min_height == 256)
            minRows = 7;
        else
            minRows = 3;
        if (shared_phonepadmodel.phonepad_show == YES && [shared_phonepadmodel.calllog_list.searchResults count] > minRows) {
            return minRows;
        }else{
            return [shared_phonepadmodel.calllog_list.searchResults count];
       }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = [indexPath row];
    ADDEXTERCELLTYPE type = None;
    if (0 == [shared_phonepadmodel.calllog_list.searchResults count]) {
        NSString *cellIDentifierType = [NSString stringWithFormat:@"%@_%@",CellIdentifier,[CootekTableViewCell class]];
        CootekTableViewCell *cell = [tableView createTableViewCell:NSStringFromClass([CootekTableViewCell class])
                                                      withStyle:UITableViewCellStyleDefault 
                                                reuseIdentifier:cellIDentifierType
                                                   andSkinStyle:@"searchResultView_cell_style"
                                                        forHost:self];
        [FunctionUtility setHeight:CONTACT_CELL_HEIGHT forView:cell.contentView];
        [FunctionUtility setY:(cell.contentView.frame.size.height - 0.5) forView:cell.bottomLine];
        [cell setBottomlineIfHidden:NO];
        if ([shared_phonepadmodel.input_number isEqualToString:@"*"]){
            DailerKeyBoardType preChangedKeyBoardType = [PhonePadModel getSharedPhonePadModel].currentKeyBoard;
            type  = preChangedKeyBoardType == T9KeyBoardType ? ChangeToQWERTYPad :ChangeToNmberPad;
        }else if([shared_phonepadmodel.input_number hasSuffix:@"#"]){
            type = PasteClipBoard;
        }
        
        [cell switchWithADDEXTERCELLTYPE:type NormalCellType:[indexPath row]];
        return cell;
    }else {
        BaseContactCell *cell = [tableView createTableViewCell:currentCellName
                                                      withStyle:UITableViewCellStyleDefault 
                                                reuseIdentifier:CellIdentifier
                                                   andSkinStyle:@"searchResultView_cell_style"
                                                        forHost:self];
        cell.operView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.01);
        int result_count =[shared_phonepadmodel.calllog_list.searchResults count];
        if(result_count<=row) {
            return cell;
        }
        id item = [shared_phonepadmodel.calllog_list.searchResults objectAtIndex:row];  
        if([item isKindOfClass:[SearchItemModel class]]) {
           cell.currentData = (SearchItemModel*)item;
           [cell setDataToCell]; 
            cell.isExcuteAction = ^(){
                BOOL isExcute = ![longGestureController_ inLongGestureMode];
                return isExcute;
            };
            [cell.actionStrategy setPopupSheetBlock:^(){ [self hideKeyBoard];}
                                          disappear:^(){ [self restoreKeyBoard];}];
        }
        [cell showAllBottomLine];
        cell.operView.hidden = YES;
        if ( [longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare: indexPath] == NSOrderedSame) {
            [cell.operView addSubview:longGestureController_.operView.bottomView];
            cell.operView.hidden = NO;
            [cell showAnimation];
            self.longModeCell = cell;
        }
        if ([[AppSettingsModel appSettings]slide_confirm]) {
            [cell openSlideItem];
        }else{
            [cell closeSlideItem];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![longGestureController_ inLongGestureMode]) {
        ADDEXTERCELLTYPE type = None;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (0 == [shared_phonepadmodel.calllog_list.searchResults count]) {
            if ([shared_phonepadmodel.input_number isEqualToString:@"*"]){
                DailerKeyBoardType preChangedKeyBoardType = [PhonePadModel getSharedPhonePadModel].currentKeyBoard;
                type  = preChangedKeyBoardType == T9KeyBoardType ? ChangeToQWERTYPad :ChangeToNmberPad;
            }else if([shared_phonepadmodel.input_number hasSuffix:@"#"]){
                type = PasteClipBoard;
            }
            NSUInteger row  = type == None?[indexPath row]+1:[indexPath row];
                switch (row) {
                    case SPECIALKEY_ACTION_CELL_COUNT:
                        [delegate specailKey:type];
                        break;
                    case CELL_SEND_MESSAGE:
                        [delegate sendMessage];
                        break;
                    case CELL_CREATE_NEW_CONTACT:
                        [delegate addContact];
                        break;
                    case CELL_ADD_TO_EXISTING_CONTACT:
                        [delegate addToExistingContact];
                    default:
                        break;
                }
            return;
        }
        BaseContactCell *cell = (BaseContactCell*)[result_tableview cellForRowAtIndexPath:indexPath];
        if ([cell respondsToSelector:@selector(onClick)]) {
            [DialerGuideAnimationUtil dismissGuideAnimation];
            [cell onClick];
            id currentData = [cell currentData];
            if([currentData isKindOfClass:[EngineResultModel class]]) {
                [DialerUsageRecord recordpath:PATH_DIALER_RESULT_SEARCH kvs:Pair(KEY_START_SEARCH, OK), nil];
                EngineResultModel* item = (EngineResultModel* )currentData;
                NSString* searchKey = shared_phonepadmodel.calllog_list.searchKey;
                [[OrlandoEngine instance] increaseContactClickedTimesToEngine:searchKey recordID:item.personID hitType:item.hitType];
                [ContactSmartSearchDBA increaseContactClickedTimes:searchKey personId:item.personID hitType:item.hitType];
            }
        }
        
    } else {
        [longGestureController_ exitLongGestureMode];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(shared_phonepadmodel.phonepad_show == YES)
    {        
        if ([shared_phonepadmodel.calllog_list.searchResults count]>3) {
            [result_tableview reloadData];
        }
        [shared_phonepadmodel setPhonePadShowingState:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_HIDE_UNREGN_BAR object:nil userInfo:nil];
    }
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewWrapperView"]) {
        return YES;
    }
    return  NO;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)recognizer {
    
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
    
}

#pragma  mark Enter_or_exit_multiselect_mode
- (void)enterLongGestureMode{
    old_phone_pad_state = shared_phonepadmodel.phonepad_show;
    [shared_phonepadmodel setPhonePadShowingState:NO];
    if (longGestureController_.showScrollToShow) {
        longGestureController_.showScrollToShow = NO;
        [result_tableview scrollToRowAtIndexPath:longGestureController_.currentSelectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    [result_tableview reloadData];
}

- (void)exitLongGestureMode{
    [self.longModeCell exitAnimation];
    [shared_phonepadmodel setPhonePadShowingState:old_phone_pad_state];
    [result_tableview reloadData];
}
- (void)exitLongGestureModeWithHintButton{
    [self.longModeCell exitAnimation];
    [result_tableview reloadData];
}

- (void)hideKeyBoard{
    old_phone_pad_state = [shared_phonepadmodel phonepad_show];
    [shared_phonepadmodel setPhonePadShowingState:NO];
}
- (void)restoreKeyBoard{
    [shared_phonepadmodel setPhonePadShowingState:old_phone_pad_state];
}
@end
