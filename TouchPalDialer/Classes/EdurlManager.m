//
//  EdurlManager.m
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 15/12/18.
//
//

#import <Foundation/Foundation.h>
#import "EdurlManager.h"
#import "NetworkUtil.h"
#import "UIDataManager.h"
#import "Reachability.h"
#import "UserDefaultsManager.h"
#import "IndexConstant.h"
#import "TouchPalVersionInfo.h"
#import "CTUrl.h"
#import "SSPStat.h"
#import "UpdateService.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"

#define IS_VISIBLE @"isVisible"
#define POSITIVE @"positive"
#define BEGIN_TIME @"beginTime"
#define END_TIME @"endTime"
#define QUERY_ID @"s"
#define NEWS_ID @"ct_id"
#define AD_ID @"ad_id"
#define IS_AD @"is_ad"
#define TU @"tu"


EdurlManager *ed_instance_ = nil;

@interface EdurlManager()
{
    NSMutableSet* sspsEds;
    NSMutableSet* transformSet;
}

@end
@implementation EdurlManager

+ (void)initialize
{
    if (self == [EdurlManager class]) {
        ed_instance_ = [EdurlManager new];
        
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        sspsEds = [NSMutableSet new];
        transformSet = [NSMutableSet new];
    }
    return self;
}

+ (id)instance
{
    return ed_instance_;
}

- (void)requestEdurl:(NSArray *)edurlArray
{
    if (!edurlArray || edurlArray.count <= 0) {
        return;
    }
    
    //get date like 2015-12-25
    NSDate* today = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSMutableString* dateStr = [NSMutableString stringWithString:[dateFormatter stringFromDate:today]];
    [dateStr deleteCharactersInRange:NSMakeRange(dateStr.length-1, 1)];
    NSMutableSet* edurlSendSet = [[NSMutableSet alloc]init];
    //get userDefault for send-edurl
    NSDictionary* edurlSendDic = [UserDefaultsManager dictionaryForKey:EDURL_SEND_DIC];
    if ([edurlSendDic count] > 0) {
        if (![edurlSendDic.allKeys containsObject:dateStr] || ![[edurlSendDic objectForKey:dateStr]containsObject:edurlArray])
        {//!contain today dic and today dic contain edurlStr
            if (![edurlSendDic.allKeys containsObject:dateStr])
            {
                edurlSendDic = [NSMutableDictionary new];
            }
            else
            {
                edurlSendSet = [edurlSendDic objectForKey:dateStr];
            }
            
            for (NSString* edurl in edurlArray) {
                if (![edurlSendSet containsObject:edurl]) {
                    [edurlSendSet addObject:edurl];
                    cootek_log(@"edurl=1=%@",edurl);
                    [NetworkUtil executeWithUrlRequest:[self urlRequest:edurl] success:^(NSData *sucess) {
                    } failure:^(NSData *errorResult) {
                        [NetworkUtil executeWithUrlRequest:[self urlRequest:edurl] success:^(NSData *sucess) {
                        } failure:^(NSData *errorResult) {
                            [edurlSendSet removeObject:edurl];
                            [edurlSendDic setValue:edurlSendSet forKey:dateStr];
                            [UserDefaultsManager setObject:edurlSendDic forKey:EDURL_SEND_DIC];
                        }];
                    }];
                }
            }
            
            [edurlSendDic setValue:edurlSendSet forKey:dateStr];
            [UserDefaultsManager setObject:edurlSendDic forKey:EDURL_SEND_DIC];
        }
    } else if ([edurlSendDic count]==0 || edurlSendDic == nil ) {
        edurlSendDic = [NSMutableDictionary new];
        //确保edurl发送成功才加到set里面
        for (NSString* edUrl in edurlArray) {
            if (![edurlSendSet containsObject:edUrl]) {
                [edurlSendSet addObject:edUrl];
                cootek_log(@"edurl=2=%@",edUrl);
                [NetworkUtil executeWithUrlRequest:[self urlRequest:edUrl] success:^(NSData *sucess) {
                } failure:^(NSData *errorResult) {
                    [NetworkUtil executeWithUrlRequest:[self urlRequest:edUrl] success:^(NSData *sucess) {
                    } failure:^(NSData *errorResult) {
                        [edurlSendSet removeObject:edUrl];
                        [edurlSendDic setValue:edurlSendSet forKey:dateStr];
                        [UserDefaultsManager setObject:edurlSendDic forKey:EDURL_SEND_DIC];
                    }];
                }];
            }
        }
        [edurlSendDic setValue:edurlSendSet forKey:dateStr];
        [UserDefaultsManager setObject:edurlSendDic forKey:EDURL_SEND_DIC];
    }
}

- (void)requestSSps:(FindNewsItem *)item
{
    if (!item.isAd ||[sspsEds containsObject:item.adid]) {
        return;
    }
    
    int sspid;
    NSString* title = item.title;
    NSString* desc = @"";
    int ftu = 0;
    switch (item.category) {
        case CategoryUpdateRec:
            return;
        case CategoryVideo:
        case CategoryNews: {
            break;
        }
        case CategoryADDavinci: {
            sspid = SSPID_DAVINCI;
            ftu = item.ftu.integerValue;
            break;
        }
        case CategoryADBaidu: {
            sspid = SSPID_BAIDU;
            title = item.title;
            desc = item.subTitle;
            ftu = item.ftu.integerValue;
            break;
        }
        case CategoryADGDT: {
            sspid = SSPID_GDT;
            title = item.title;
            desc = item.subTitle;
            ftu = item.ftu.integerValue;
            break;
        }
    }
    
    [sspsEds addObject:item.adid];
    [[SSPStat instance] edWithSSPid:sspid andTu:TU_FEEDS andRank:[item.rank integerValue] andExpId:[item.expid integerValue] andTitle:title andDesc:desc andS:item.sspS andFtu:ftu];
}

- (NSURLRequest *)urlRequest:(NSString *)url
{
    NSString *parseUrl = [CTUrl encodeRequestUrl:url];
    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc]initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    return httpRequest;
}

-(void)addNewsRecord:(NSIndexPath *)indexPath andNewsInfo:(FindNewsItem *)newsInfo
{
    
    //return nil if showedNewsDic do not contains key of index
    NSString *tu = newsInfo.tu ? newsInfo.tu : @"";
    if (newsInfo.isAd) {
        tu = newsInfo.ftu ? newsInfo.ftu : @"";
    }
    
    NSMutableDictionary* newsDic = [[UIDataManager instance].showedNewsDic objectForKey:tu];
    if (!newsDic) {
        newsDic = [NSMutableDictionary new];
        [[UIDataManager instance].showedNewsDic setObject:newsDic forKey:tu];
    }
    
    if (!newsInfo.isAd && ![newsDic objectForKey:indexPath]) {
        NSString *queryId = newsInfo.queryId ? newsInfo.queryId : @"";
        NSString *newsId = newsInfo.newsId ? newsInfo.newsId : @"";
        
        NSMutableDictionary *news = [[NSMutableDictionary alloc]init];
        [news setObject:queryId forKey:QUERY_ID];
        [news setObject:newsId forKey:NEWS_ID];
        [news setObject:tu forKey:TU];
        [news setObject:@"NO" forKey:IS_AD];
        [newsDic setObject:news forKey:indexPath];
    }
    
    //发送edrul
    [self requestEdurl:newsInfo.edMonitorUrl];
    
    //发送ssps
    [self requestSSps:newsInfo];
}

-(void)removeNewsRecord:(UITableView *)tableView tu:(NSString *)tu
{
    @try {
        NSMutableDictionary* newsDic = [[UIDataManager instance].showedNewsDic objectForKey:tu];
        if (!newsDic) {
            newsDic = [NSMutableDictionary new];
            [[UIDataManager instance].showedNewsDic setObject:newsDic forKey:tu];
        }
        if (newsDic.count > 0) {
            NSString* endTime = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
            for (int i = 0; i < newsDic.count; i++) {
                NSIndexPath *indexPath = [[newsDic allKeys] objectAtIndex:i];
                NSMutableDictionary *newsInfo = [newsDic objectForKey:indexPath];
                BOOL halfVisible = [self isVisible:tableView andIndexPath:indexPath];
                if (!halfVisible) {
                    NSString *tu = [newsInfo objectForKey:TU];
                    NSString *key = [NSString stringWithFormat:@"%@-%@",[newsInfo objectForKey:NEWS_ID], tu];
                    
                    //判断当前的key对应的visible是否是true，如果不是，不做删除处理
                    if ([POSITIVE isEqualToString:[newsInfo objectForKey:IS_VISIBLE]] && ![transformSet containsObject:key]) {
                        [transformSet addObject:key];
                        [newsInfo setObject:endTime forKey:END_TIME];
                        
                        //send url request to server
                        TransformType transformType = ED_SHOW;
                        CTCloseType closeType = PASS_THROUGH;
                        [self requestWithNewsInfo:newsInfo andTransformType:transformType andCloseType:closeType];
                        
                        [newsDic removeObjectForKey:indexPath];
                        i--;
                        
                    }
                } else {
                    //判断当前的key对应的visible是否是true，如果不是，设置为true
                    if (![[newsInfo objectForKey:IS_VISIBLE] isEqualToString:POSITIVE]) {
                        [newsInfo setObject:POSITIVE forKey:IS_VISIBLE];
                        NSString *beginTime = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
                        [newsInfo setObject:beginTime forKey:BEGIN_TIME];
                        [newsDic setObject:newsInfo forKey:indexPath];
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        [DialerUsageRecord recordYellowPage:EV_EDURL_SCROLL_REMOVE kvs:Pair(@"action", @"crash"), Pair(@"tu",tu), Pair(@"msg", exception.reason), nil];
    }
    
}

- (BOOL)isVisible:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath
{
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    CGFloat margin = 1.0f;
    CGFloat middleYStart = cellRect.origin.y + cellRect.size.height / 2 - margin;
    CGRect middleRect = CGRectMake(cellRect.origin.x, middleYStart, cellRect.size.width, margin * 2);
    return CGRectContainsRect(tableView.bounds, middleRect);
}

-(void)removeAllNewsRecordWithCloseType:(CTCloseType)closeType
{
    NSString *endTime = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
    
    
    for (NSString *key in [UIDataManager instance].showedNewsDic) {
        NSMutableDictionary *newsDic = [[UIDataManager instance].showedNewsDic objectForKey:key];
        if(newsDic.count > 0) {
            for (int i = 0; i < newsDic.count; i++) {
                NSIndexPath *indexPath = [[newsDic allKeys] objectAtIndex:i];
                NSMutableDictionary *newsInfo = [newsDic objectForKey:indexPath];
                //将所有的newsInfo拼装成url发送给服务器，需要统一endTime
                TransformType transformType = ED_SHOW;
                NSString *tu = [newsInfo objectForKey:TU];
                NSString *key = [NSString stringWithFormat:@"%@-%@",[newsInfo objectForKey:NEWS_ID], tu];
                if ([POSITIVE isEqualToString:[newsInfo objectForKey:IS_VISIBLE]] && ![transformSet containsObject:key]) {
                    [transformSet addObject:key];
                    [newsInfo setObject:endTime forKey:END_TIME];
                    [self requestWithNewsInfo:newsInfo andTransformType:transformType andCloseType:closeType];
                }
                
            }
        }

    }
    
    [self clear];
}

- (void) clear {
    [UIDataManager instance].showedNewsDic =  [[NSMutableDictionary alloc]init];;
}

-(void)requestWithNewsInfo:(NSMutableDictionary *)newsInfo andTransformType:(TransformType)transformType andCloseType:(CTCloseType)closeType
{
    //send url request to server
    NSString *sId = [newsInfo objectForKey:QUERY_ID];
    NSString *ctId = [newsInfo objectForKey:NEWS_ID];
    NSString *beginTime = [newsInfo objectForKey:BEGIN_TIME];
    NSString *endTime = [newsInfo objectForKey:END_TIME];
    NSString *tu = [newsInfo objectForKey:TU];
    BOOL isAd = [@"YES" isEqualToString:[newsInfo objectForKey:IS_AD]];
    if (!isAd) {
        if (sId.length > 0 && ctId.length > 0 && beginTime.length > 0 && endTime.length > 0) {
            NSString *requestUrl = [NSString stringWithFormat:@"%@?type=%@&s=%@&%@=%@&tsin=%@&tsout=%@&closetype=%@&tu=%@",isAd ? PREFIX_URL_AD : PREFIX_URL_NEWS, [NSString stringWithFormat:@"%d", transformType], sId, isAd ? @"adid" : @"ctid", ctId, beginTime, endTime, [NSString stringWithFormat:@"%d", closeType], tu];
            [NetworkUtil executeWithUrlRequest:[self urlRequest:requestUrl] success:^(NSData *sucess){
            } failure:^(NSData *errorResult){
                [NetworkUtil executeWithUrlRequest:[self urlRequest:requestUrl] success:^(NSData *sucess){
                } failure:^(NSData *errorResult){
                    
                }];
            }];
        }
    }
    
}

- (void) sendCMonitorUrl:(BaseItem*) item
{
    for (NSString* localUrl in item.cMonitorUrl) {
        [[UpdateService instance] requestForCUrl:localUrl];
    }
}

@end
