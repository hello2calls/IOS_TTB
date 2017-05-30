//
//  PhonePadModel.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/26/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchEngineThread.h"
#import "SearchEngineInputSource.h"
#import "AppSettingsModel.h"
#import "SearchResultModel.h"
#import "GestureUtility.h"
#import "PhonePadKeyProtocol.h"
#import "CallerIDInfoModel.h"

#define N_REDRAW_PHONE_NUMBER_INPUT_VIEW @"N_REDRAW_PHONE_NUMBER_INPUT_VIEW"

@interface PhonePadModel : NSObject

@property(nonatomic,assign) BOOL isCommitCalllog;
@property(nonatomic,retain) NSString *input_number;
@property(nonatomic,retain) NSString *number_attr;
@property(nonatomic,retain) CallerIDInfoModel* caller_id_info;
@property(nonatomic,retain) SearchResultModel *calllog_list;
@property(nonatomic,assign) DailerKeyBoardType currentKeyBoard;
@property bool phonepad_show;
@property PhonePadLanguage c_phonepad_language;
@property(readonly)  NSDictionary *ABC2Num_dic;

+ (PhonePadModel *)getSharedPhonePadModel;
+ (NSString *)ABC2Num:(NSString *)dialString;
- (void)loadInitialData;
- (void)setInputNumber:(NSString *)input_num;
- (void)setPhonePadShowingState:(bool)show_state;
- (void)searchDidFinish:(id)resultList;
- (void)queryCallLogList;
- (void)setFilterType:(CalllogFilterType)type;
- (void)resetPhonePadLanguage:(PhonePadLanguage)language;
- (NSString *)getLastestKeyWord;
- (BOOL)excuteGestureAction:(NSString *)name;
- (void)setInputNumberAndNoScrollWhenEmpty:(NSString *)input_num;
- (BOOL)phonePadShow;
@end
