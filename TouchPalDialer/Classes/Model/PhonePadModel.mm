//
//  PhonePadModel.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/26/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "PhonePadModel.h"
#import "CallLog.h"
#import "WhereDataModel.h"
#import "LabelDataModel.h"
#import "DataBaseModel.h"
#import "TouchPalDialerAppDelegate.h"
#import "OrlandoEngine+Contact.h"
#import "PhoneNumber.h"
#import "CallerIDModel.h"
#import "FunctionUtility.h"
#import "TPMFMessageActionController.h"
#import "TPCallActionController.h"
#import "TPDailerSearch.h"
#import "DialResultModel.h"
#import "DefaultUIAlertViewHandler.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"

#define CURRENT_YELLOW_CITY_KEY @"CURRENT_YELLOW_CITY_KEY"

static PhonePadModel *sharedPhonePadModel = nil;
@interface PhonePadModel(){
    NSString *input_number;
    SearchResultModel *calllog_list;
	
	bool phonepad_show;
	PhonePadLanguage c_phonepad_language;
    
	SearchEngineThread *searchEngineThread;
    TPDailerSearch *searchEngine_;
    BOOL dialerViewNeedScrollToTop_;

}
@end
@implementation PhonePadModel
@synthesize input_number;
@synthesize number_attr;
@synthesize caller_id_info;
@synthesize calllog_list;
@synthesize phonepad_show;
@synthesize c_phonepad_language;

@synthesize currentKeyBoard = currentKeyBoard_;
@synthesize isCommitCalllog;
@synthesize ABC2Num_dic;


+ (PhonePadModel *)getSharedPhonePadModel {
	if(sharedPhonePadModel)
		return sharedPhonePadModel;
	
    @synchronized(self)
	{
		if (sharedPhonePadModel == nil)
		{
            sharedPhonePadModel = [[self alloc] init];
        }
    }
	return  sharedPhonePadModel;
}
+ (NSString *)ABC2Num:(NSString *)dialString{
     if(dialString ==nil)
          return nil;
     NSMutableArray *indexs = [[NSMutableArray alloc] init];
     for(int i=0;i<dialString.length;i++){
          if(('A'<=[dialString characterAtIndex:i] && [dialString characterAtIndex:i]<='Z') || ('a'<=[dialString characterAtIndex:i] && [dialString characterAtIndex:i]<='z')){
               [indexs addObject:[NSNumber numberWithInt:i]];
          }
     }
     NSMutableString *changeNum = [NSMutableString stringWithString:dialString];
     if([indexs count]>0){
          NSDictionary *abc2Num = [PhonePadModel getSharedPhonePadModel].ABC2Num_dic;
          for(int i=0;i<[indexs count];i++){  
               NSRange range = NSMakeRange([[indexs objectAtIndex:i] intValue], 1);
               [changeNum replaceCharactersInRange:range withString:[abc2Num objectForKey:[[dialString substringWithRange:range] uppercaseString]]];
          }
     }
     return changeNum;
}
- (id)init {
	self = [super init];
    if (self) {
        currentKeyBoard_ = T9KeyBoardType;
		phonepad_show = YES;
		self.input_number = @"";
		AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
		c_phonepad_language = appSettingsModel.secondary_language;
         NSArray *keys = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",
                          @"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
         NSArray *nums = [NSArray arrayWithObjects:@"2",@"2",@"2",@"3",@"3",@"3",@"4",@"4",@"4",@"5",@"5",@"5",@"6",@"6",@"6",@"7",@"7",@"7",@"7",
                          @"8",@"8",@"8",@"9",@"9",@"9",@"9",nil];
         ABC2Num_dic = [[NSDictionary alloc] initWithObjects:nums forKeys:keys];
        dialerViewNeedScrollToTop_ = YES;

    }
    return self;
}
- (void) loadInitialData {
    searchEngine_ = [[TPDailerSearch alloc] initWithKeyBoard:currentKeyBoard_
                                                      calllog:AllCallLogFilter];
    searchEngineThread = [[SearchEngineThread alloc] initWithEngine:searchEngine_
                                                            respone:self];
    [searchEngineThread start];
  
}
- (void)setFilterType:(CalllogFilterType)type{
    [searchEngine_ setTPQueryCallog:type];
    [self setInputNumber:@""];
}
- (void)setCurrentKeyBoard:(DailerKeyBoardType)currentKeyBoard{
    currentKeyBoard_ = currentKeyBoard;
    [searchEngine_ setKeyBoradType:currentKeyBoard_];
    [UserDefaultsManager setIntValue:currentKeyBoard_ forKey:KEYBOARD_TYPE_RESTORE];
}
- (void)queryCallLogList {
	[searchEngineThread addQueryContent:@""];
}

- (void)setInputNumberAndNoScrollWhenEmpty:(NSString *)input_num{
    dialerViewNeedScrollToTop_ = NO;
    [self setInputNumber:input_num];
}

- (void)setInputNumber:(NSString *)input_num {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(setInputNumber:) withObject:input_num waitUntilDone:NO];
        return;
    }
    
    if (input_num.length > SEARCH_INPUT_MAX_LENGTH) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Ooops, the input is too long.", @"")
                                                  message:nil];
        return;
    }
    
	self.input_number = input_num;
	if (self.input_number) {
        [searchEngineThread addQueryContent:self.input_number];
	}else {
        self.number_attr = @"";
        self.caller_id_info = nil;
		[searchEngineThread cleanAllContent];
	}
	if ([input_num isEqualToString:@""]) {
        self.number_attr = @"";
        self.caller_id_info = nil;
		[[NSNotificationCenter defaultCenter] postNotificationName:N_DIALER_INPUT_EMPTY object:nil userInfo:nil];
	} else {
        NSString* normalizedPhoneNumber = [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:input_num];
        if ([normalizedPhoneNumber hasPrefix:@"+86"]) {
            self.number_attr = [[PhoneNumber sharedInstance] getNumberAttribution_WithOutConsideringPersonExist:input_num
                                                                                                       withType:attr_type_normal];
        } else {
            self.number_attr = [[PhoneNumber sharedInstance] getNumberAttribution_WithOutConsideringPersonExist:input_num
                                                                                                       withType:attr_type_short];
        }
        self.caller_id_info = nil;
        
        if([[OrlandoEngine instance] queryNumberToContact:input_num] < 0){
            [CallerIDModel queryCallerIDWithNumber:normalizedPhoneNumber callBackBlock:^(CallerIDInfoModel *callerID){
                if([callerID.number isEqualToString:self.input_number] ||
                   [FunctionUtility string:callerID.number sharesSuffixWithString:self.input_number suffixLength:7]){
                    self.caller_id_info = callerID;
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_REDRAW_PHONE_NUMBER_INPUT_VIEW object:nil userInfo:nil];
                }
                
            }];
        }
		[[NSNotificationCenter defaultCenter] postNotificationName:N_DIALER_INPUT_NOT_EMPTY object:nil userInfo:nil];
	}
}

- (void)searchDidFinish:(SearchResultModel *)resultList {
    self.calllog_list = resultList;
	[[NSNotificationCenter defaultCenter] postNotificationName:N_CALL_LOG_LIST_CHANGED object:@(dialerViewNeedScrollToTop_) userInfo:nil];
    dialerViewNeedScrollToTop_ = YES;
}

- (NSString *)getLastestKeyWord{
	return [searchEngineThread currentQueryContent];
}

- (void)setPhonePadShowingState:(bool)show_state {
    if (phonepad_show == show_state) {
        return;
    }
	phonepad_show = show_state;
	if (phonepad_show) {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_PHONE_PAD_SHOW object:nil userInfo:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_PHONE_PAD_HIDE object:nil userInfo:nil];
	}
}

- (void)resetPhonePadLanguage:(PhonePadLanguage)language {
	cootek_log(@"init lng is %d", c_phonepad_language);
	if (c_phonepad_language != language) {
		c_phonepad_language = language;
		[[NSNotificationCenter defaultCenter] postNotificationName:N_PHONE_PAD_LANGUAGE_CHANGED object:nil userInfo:nil];
	}
}

- (BOOL)excuteGestureAction:(NSString *)name{
    BOOL isEndSignalUnRecoginer = NO;
    GestureActionType type = [GestureUtility getActionType:name];
    if (type == ActionCall) {
        //打电话
        NSInteger personId = -1;
        NSString* phoneNumber = @"";
        if ([GestureUtility getGestureItemType:name] == FirstItemType) {
            cootek_log(@"*******gesture recoginer *********%@,%d",self.calllog_list.searchKey,self.calllog_list.searchType);
            NSArray *personList = [NSArray arrayWithArray:self.calllog_list.searchResults];
            if ([personList count] > 0){
                id item = [personList objectAtIndex:0];
                if (item) {
                    if ([item isKindOfClass:[CallLogDataModel class]]) {
                        CallLogDataModel *tmp = (CallLogDataModel *)item;
                        phoneNumber =[tmp number];
                        personId = [tmp personID];
                    }else if([item isKindOfClass:[DialResultModel class]]){
                        DialResultModel *tmp = (DialResultModel *)item;
                        phoneNumber =[tmp number];
                        personId = [tmp personID];
                    }
                }else {
                    cootek_log(@"*******gesture recoginer *********%@",self.calllog_list.searchResults);
                }
            }else {
                isEndSignalUnRecoginer = YES;
            }
            
        }else{
            phoneNumber = [GestureUtility getNumber:name withAction:type];
            personId  = [GestureUtility getPersonID:name withAction:type];
        }
        CallLogDataModel *call_log=[[CallLogDataModel alloc] initWithPersonId:personId 
                                                                  phoneNumber:phoneNumber
                                                                loadExtraInfo:YES];
        
        if (!isEndSignalUnRecoginer) {
            [TPCallActionController logCallFromSource:@"GestureDialing"];
            [[TPCallActionController controller] makeGestureCall:call_log];
        }
    }else if(type == ActionSMS){
        NSString *phoneNumber = @"";
        if ([GestureUtility getGestureItemType:name] == FirstItemType) {
            NSArray *personList = [NSArray arrayWithArray:self.calllog_list.searchResults];
            if ([personList count] > 0){
                id item = [personList objectAtIndex:0];
                if (item) {
                    if ([item isKindOfClass:[CallLogDataModel class]]) {
                        CallLogDataModel *tmp = (CallLogDataModel *)item;
                        phoneNumber = [tmp number];
                    }else if([item isKindOfClass:[DialResultModel class]]){
                        DialResultModel *tmp = (DialResultModel *)item;
                        phoneNumber =[tmp number];
                    }
                }else {
                    cootek_log(@"*******gesture recoginer *********%@",self.calllog_list.searchResults);
                }
            }else {
                isEndSignalUnRecoginer = YES;
            }
        }else {
            phoneNumber  = [GestureUtility getNumber:name withAction:type];;
        }
        if (!isEndSignalUnRecoginer) {
            UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
            [TPMFMessageActionController sendMessageToNumber:phoneNumber
                                                              withMessage:@""
                                                              presentedBy:aViewController];
        }
    }
    return isEndSignalUnRecoginer;
}
- (void)dealloc {
    [searchEngineThread stopRunLoop];
}

- (BOOL)phonePadShow{
    return phonepad_show;
}

@end
