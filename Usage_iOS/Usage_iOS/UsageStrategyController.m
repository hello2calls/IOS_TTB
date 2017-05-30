//
//  StrategyController.m
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-24.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import "UsageStrategyController.h"

#define  UPLOAD_STRATEGY (@"UploadStrategy")
#define  STRATEGY (@"Strategy")
#define  NAME (@"name")
#define  WIFI (@"wifi")
#define  MOBILE (@"mobile")
#define  ENCRYPT (@"encrypt")
#define  COUNT (@"count")
#define  UPLOAD_CONTROL (@"UploadControl")
#define  DATA (@"data")
#define  PATH (@"path")
#define  SAMPLING (@"sampling")
#define  CONTROL_STRATEGY (@"strategy")
#define  USAGE (@"Usage")
#define  DEFAULT_SAMPLING (100)
#define  DEFAULT_WIFI (15)
#define  DEFAULT_MOBILE (1440)
#define  DEFAULT_STRATEGY (@"default")

static UsageStrategyController *sController;

static NSMutableDictionary *mUploadStrategy;
static NSMutableDictionary *mUploadControl;
static NSMutableArray *mPathNames;

@implementation Strategy
@synthesize name;
@synthesize wifi;
@synthesize mobile;
@synthesize encrypt;
@synthesize count;
@end

@implementation UploadControlItem
@synthesize path;
@synthesize sampling;
@synthesize strategyName;
@end

@implementation UsageStrategyController
{
    Strategy *mStrategy;
    UploadControlItem *mUploadControlItem;
}

- (NSMutableDictionary *)mUploadStrategy
{
    return mUploadStrategy;
}

- (NSMutableDictionary *)mUploadControl
{
    return mUploadControl;
}

+ (UsageStrategyController *)getCurrent
{
    if (sController == nil) {
        @synchronized (self) {
            if (sController == nil) {
                sController = [[UsageStrategyController alloc] init];
                BOOL result = [sController generate];
                if (!result) {
                    [[UsageRecorder sAssist] updateStrategyResult:NO];
                }
            }
        }
    }
    return sController;
}

- (BOOL)generate
{
    #ifdef DEBUG
    NSLog(@"reset strategies & controls");
    #endif
    return [self parseFile];
}

- (BOOL)isPathExist:(NSString *)path
{
    if ([self getMatchPathName:path] != nil) {
        return YES;
    }
    return NO;
}

- (NSString *)getMatchPathName:(NSString *)path {
    for (NSString *pathName in mPathNames) {
        NSError *error = NULL;
        NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:pathName options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *result = [regExp firstMatchInString:path options:0 range:NSMakeRange(0, [path length])];
        if ((BOOL)result) {
            return pathName;
        }
    }
    return nil;
}

- (BOOL)parseFile
{
    BOOL result = YES;
    NSString *fPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[[UsageRecorder sAssist] strategyFileName]];
    #ifdef DEBUG
    if (fPath!=nil) {
        NSLog(@"The strategy file path is: %@", fPath);
    } else {
        NSLog(@"Can't find the strategy file");
    }
    #endif
    //打开文件并转换为NSData。why：parser接受的是NSData格式。
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:fPath];
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    //解析文件内容
    result = [self parseXML:data];
    
    //判断解析结果，如果没有‘default’策略，则判定策略文件错误
    if (![[mUploadStrategy allKeys] containsObject:DEFAULT_STRATEGY]) {
        result = NO;
    }
    //如果解析失败，则给一个default的strategy，保证可以运行。
    if (result == NO) {
        mUploadStrategy = [[NSMutableDictionary alloc] init];
        Strategy *tmpStrategy= [[Strategy alloc] init];
        tmpStrategy.name = DEFAULT_STRATEGY;
        tmpStrategy.wifi  = DEFAULT_WIFI;
        tmpStrategy.mobile = DEFAULT_MOBILE;
        tmpStrategy.count = -1;
        tmpStrategy.encrypt = NO;
        [mUploadStrategy setValue:tmpStrategy forKey:DEFAULT_STRATEGY];
        #ifdef DEBUG
        NSLog(@"parser failed. support a default strategy to keep the program.");
        #endif
    }
    return result;
}

- (BOOL)parseXML:(NSData *)data
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    return [parser parse];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSMutableDictionary *)attributeDict {
    if ([elementName isEqualToString:USAGE]) {
        //Do nothing.
    } else if ([elementName isEqualToString:UPLOAD_STRATEGY]) {
        mUploadStrategy = [[NSMutableDictionary alloc] init];
        #ifdef DEBUG
        NSLog(@"---------------------------------");
        NSLog(@"---------UploadStrategy----------");
        #endif
    } else if ([elementName isEqualToString:STRATEGY]) {
        mStrategy = [[Strategy alloc] init];
        mStrategy.name = [attributeDict objectForKey:NAME];
        mStrategy.wifi  = [[attributeDict objectForKey:WIFI] intValue];
        mStrategy.mobile = [[attributeDict objectForKey:MOBILE] intValue];
        if ([attributeDict objectForKey:ENCRYPT]) {
            mStrategy.encrypt = [[attributeDict objectForKey:ENCRYPT] boolValue];
        } else {
            mStrategy.encrypt = NO;
        }
        if ([attributeDict objectForKey:COUNT]) {
            mStrategy.count = [[attributeDict objectForKey:COUNT] intValue];
        } else {
            mStrategy.count = -1;
        }
        //Add the time to the Strategy if the time of Strategy is nil.
        if ([[UsageSettings getInst] getLastSuccess:mStrategy.name] == 0) {
            [[UsageSettings getInst] updateLastSuccess:mStrategy.name];
        }
        #ifdef DEBUG
        NSLog(@"******Strategy******");
        NSLog(@"name    : %@", mStrategy.name);
        NSLog(@"wifi    : %d", mStrategy.wifi);
        NSLog(@"mobi    : %d", mStrategy.mobile);
        NSLog(@"encrypt : %d", mStrategy.encrypt);
        NSLog(@"count   : %d", mStrategy.count);
        NSLog(@"LastSuccessTime : %lf", [[UsageSettings getInst] getLastSuccess:mStrategy.name]);
        #endif
        //Append it to UploadStrategy in the end tag method.
    } else if ([elementName isEqualToString:UPLOAD_CONTROL]) {
        mUploadControl = [[NSMutableDictionary alloc] init];
        mPathNames = [[NSMutableArray alloc] init];
        #ifdef DEBUG
        NSLog(@"---------------------------------");
        NSLog(@"----------UploadControl----------");
        #endif
    } else if ([elementName isEqualToString:DATA]) {
        mUploadControlItem = [[UploadControlItem alloc] init];
        mUploadControlItem.path = [attributeDict objectForKey:PATH];
        [mPathNames addObject:mUploadControlItem.path];
        mUploadControlItem.sampling = ([attributeDict objectForKey:SAMPLING] != nil) ?
            [[attributeDict objectForKey:SAMPLING] intValue] : DEFAULT_SAMPLING;
        mUploadControlItem.strategyName = ([attributeDict objectForKey:CONTROL_STRATEGY] != nil) ?
            [attributeDict objectForKey:CONTROL_STRATEGY] : DEFAULT_STRATEGY;
        #ifdef DEBUG
        NSLog(@"********data********");
        NSLog(@"path     : %@", mUploadControlItem.path);
        NSLog(@"sampling : %d", mUploadControlItem.sampling);
        NSLog(@"strategy : %@", mUploadControlItem.strategyName);
        #endif
        //Append it to UploadControl in the end tag method.
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:STRATEGY]) {
        [mUploadStrategy setValue:mStrategy forKey:mStrategy.name];
    } else if ([elementName isEqualToString:DATA]) {
        [mUploadControl setValue:mUploadControlItem forKey:mUploadControlItem.path];
    } else if ([elementName isEqualToString:USAGE]) {
        //Do nothing
    } else if ([elementName isEqualToString:UPLOAD_STRATEGY]) {
        //Do nothing
    }
}

+ (volatile UsageStrategyController *)sController {
    return sController;
}

- (int)getSampling:(NSString *)path {
    NSString *pathName = [self getMatchPathName:path];
    UploadControlItem *item = [mUploadControl objectForKey:pathName];
    return item.sampling;
}

- (NSString *)getStrategy:(NSString *)path {
    NSString *pathName = [self getMatchPathName:path];
    UploadControlItem *item = [mUploadControl objectForKey:pathName];
    return item.strategyName;
}

- (int)getWifi:(NSString *)name {
    Strategy *strategy = [mUploadStrategy objectForKey:name];
    return strategy.wifi;
}

- (int)getMobile:(NSString *)name {
    Strategy *strategy = [mUploadStrategy objectForKey:name];
    return strategy.mobile;
}

- (int)getCount:(NSString *)name {
    Strategy *strategy= [mUploadStrategy objectForKey:name];
    return strategy.count;
}

- (BOOL)getEncrypt:(NSString *)name {
    Strategy *strategy= [mUploadStrategy objectForKey:name];
    return strategy.encrypt;
}

@end
