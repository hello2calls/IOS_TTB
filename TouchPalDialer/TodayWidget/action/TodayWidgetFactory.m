//
//  TodayWidgetFactory.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/9.
//
//

#import "TodayWidgetFactory.h"
#import "TodayWidgetNewView.h"
#import "TodayWidgetUtil.h"
#import "TodayWidgetInfo.h"
#import "TodayWidgetInfoView.h"
#import "TodayWidgetErrorView.h"
#import "TodayWidgetNoInfoView.h"
#import "UserDefaultsManager.h"
typedef enum {
    NEWER,
    ERROR,
    NO_INFO,
    HAS_INFO
} TodayWidgetFactoryType;

@interface TodayWidgetFactory()<TodayWidgetMainViewDelegate>{
    TodayWidgetInfo *_info;
    TodayWidgetFactoryType _factoryType;
    NSString *_errorStr;
    NSString *_subTitleText;
    NSString *_normalizeNumber;
    NSString *_number;
    BOOL _ifFreeCall;
}
@end

@implementation TodayWidgetFactory

- (instancetype)init{
    self = [super init];
    
    if ( self ){
        _info = nil;
        _factoryType = NEWER;
        _errorStr = nil;
        _subTitleText = nil;
        _normalizeNumber = nil;
        _number = nil;
    }
    
    return self;
}


- (TodayWidgetMainView *) getTodayWidgetView{
    TodayWidgetMainView *view;
    float height = 0;
    switch (_factoryType) {
        case NEWER:{
            TodayWidgetNewView *temptView = [[TodayWidgetNewView alloc]initWithDelegte:self];
            view = temptView;
            height = temptView.viewButton.frame.size.height;
            break;
        }
        case ERROR:{
            TodayWidgetErrorView *temptView = [[TodayWidgetErrorView alloc]initWithString:_errorStr delegate:self];
            view = temptView;
            height = temptView.viewButton.frame.size.height;
            break;
        }
        case NO_INFO:{
            TodayWidgetNoInfoView *temptView = [[TodayWidgetNoInfoView alloc]initWithNumber:_number andAttr:_subTitleText andIfFreeCall:_ifFreeCall delegate:self];
            view = temptView;
            height = temptView.viewButton.frame.size.height;
            break;
        }
        case HAS_INFO:{
            TodayWidgetInfoView *temptView = [[TodayWidgetInfoView alloc]initWithInfo:_info andAttr:_subTitleText andIfFreeCall:_ifFreeCall delegate:self];
            view = temptView;
            height = temptView.viewButton.frame.size.height;
            break;
        }
        default:
            break;
            
    }
    view.delegate = self;
    [_delegate adjustViewHeight:height];
    return view;
}

- (void)recordTimes{
    NSInteger num = [[TodayWidgetUtil readDataFromNSUserDefaults:@"todayWidgetUsedTimes"] integerValue];
    num += 1;
    [TodayWidgetUtil writeDefaultKeyToDefaults:[NSString stringWithFormat:@"%d",num] andKey:@"todayWidgetUsedTimes"];
}


- (void)onPressBgButton{
    [self generateInfo];
    [_delegate refreshView];
}

- (void)onPressRightButton{
    if ( _ifFreeCall ){
        [_context openURL:[NSURL URLWithString:[NSString stringWithFormat:@"touchpal://callNumber:%@",_number]] completionHandler:^(BOOL success) {
            NSLog(@"open url result:%d",success);
        }];
    }
    else
        [TodayWidgetUtil callNumber:_number];
}
- (void)onPressUpdateButton{
    if ([self ifShowUpdateViewInToday]){
        [_context openURL:[NSURL URLWithString:@"touchpal://update"] completionHandler:^(BOOL success) {
            NSUserDefaults* userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.cootek.Contacts"];
            NSString* urlVersion = [userDefault objectForKey:ANTIHARASS_REMOTE_VERSION];
            [userDefault setObject:urlVersion forKey:ANTIHARASS_TODAYWIDGET_NOT_SHOW_WITH_VERSION];
        }];
      
    }
    [_delegate refreshView];
       
}


- (void)generateInfo{
    if ( [[UIPasteboard generalPasteboard].string length] == 0 )
        return;
    _number = [TodayWidgetUtil getNumberFromPasteboard:[UIPasteboard generalPasteboard].string];
    _normalizeNumber = [TodayWidgetUtil getNormalizePhoneNumber:_number];
    if ( _normalizeNumber.length<3 || _normalizeNumber.length>16 ){
        _factoryType = ERROR;
        _errorStr = @"复制内容中没有号码，请重新复制";
        return;
    }
    _ifFreeCall = [TodayWidgetUtil getIfFreeCall:_normalizeNumber];
    
    _subTitleText = [TodayWidgetUtil getAttr:_normalizeNumber];
    if ( [_subTitleText isEqualToString:@"Local"] || _subTitleText == nil || _subTitleText.length == 0 ){
        _subTitleText = @"查询不到该号码归属地";
    }
    _factoryType = NO_INFO;
    
    NSString *token = [TodayWidgetUtil readDataFromNSUserDefaults:@"touchpalToken"];
    if ( token == nil ){
        _factoryType = ERROR;
        _errorStr = @"请重新激活触宝电话，才能使用本功能";
        return;
    }
    
    NSString *responseStr = [TodayWidgetUtil requestNumberInfo:_normalizeNumber andToken:token];
    if ( responseStr == nil ){
        return;
    }
    [self generateResultInfo:responseStr andNumber:_number addNormalizedNumber:_normalizeNumber];
}

- (void)generateResultInfo:(NSString *)responseStr andNumber:(NSString *)number addNormalizedNumber:(NSString*)normalizedNumber{
    NSDictionary *resultDic = [TodayWidgetUtil getDictionaryFromJsonString:responseStr];
    NSArray *resultArray = [resultDic objectForKey:@"res"];
    if ( resultArray == nil || [resultArray count] == 0 || ![[resultArray objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        return;
    }
    NSDictionary *pairDic = [resultArray objectAtIndex:0];
    if ( pairDic == nil || [pairDic count] == 0 ){
        return;
    }

    NSString *numberType = [pairDic objectForKey:@"classify_type"];
    NSString *shopName = [pairDic objectForKey:@"shop_name"];
    NSInteger markCount = [[pairDic objectForKey:@"mark_count"] integerValue];
    
    NSString *classifyType = [TodayWidgetUtil getClassfyType:numberType];
    
    if ( numberType == nil && shopName == nil ){
        return;
    }
    
    TodayWidgetInfo *info = [[TodayWidgetInfo alloc]init];
    info.generateNumber = number;
    info.normalizedNumber = normalizedNumber;
    info.classifyType = classifyType;
    info.markCount = markCount;
    info.shopName= shopName;
    _info = info;
    
    _factoryType = HAS_INFO;
}

-(BOOL)ifShowUpdateViewInToday{
    NSUserDefaults* userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.cootek.Contacts"];
    if([userDefault boolForKey:ANTIHARASS_IS_ON]){
      if (![userDefault boolForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON]){
        NSString* dbVersion = [userDefault objectForKey:ANTIHARASS_VERSION];
        NSString* urlVersion = [userDefault objectForKey:ANTIHARASS_REMOTE_VERSION];
        NSLog(@"%@=========%@",dbVersion,urlVersion);
        if ((![dbVersion isEqualToString:urlVersion] && [urlVersion integerValue] > [dbVersion integerValue]) && urlVersion!= [userDefault objectForKey:ANTIHARASS_TODAYWIDGET_NOT_SHOW_WITH_VERSION]){
            NSInteger num2 = [[TodayWidgetUtil readDataFromNSUserDefaults:@"todayWidgetUpdateViewTimes"] integerValue];
            num2+= 1;
            [TodayWidgetUtil writeDefaultKeyToDefaults:[NSString stringWithFormat:@"%d",num2] andKey:@"todayWidgetUpdateViewTimes"];
            
            return YES;
        }
      }
    }
    return NO;
}




@end
