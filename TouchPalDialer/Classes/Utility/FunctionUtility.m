//
//  FunctionUtility.m
//  TouchPalDialer
//
//  Created by zhang Owen on 8/22/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "FunctionUtility.h"
#import "TouchPalDialerAppDelegate.h"
#import "LangUtil.h"
#import "ImageCacheModel.h"
#import "SmartDailerSettingModel.h"
#import "CooTekServerDef.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "UserDefaultsManager.h"
#import "NetworkUtility.h"
#import "OpenUDID.h"
#import "SeattleFeatureExecutor.h"
#import "ScheduleInternetVisit.h"
#import "Reachability.h"
#import <sys/utsname.h>
#import "TouchPalVersionInfo.h"
#import "DeviceSim.h"
#import "DefaultUIAlertViewHandler.h"
#import "DialerUsageRecord.h"
#import "TPMFMessageActionController.h"
#import "TPShareController.h"
#import "QQShareController.h"
#import "HandlerWebViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "DialerGuideAnimationManager.h"
#import "RootScrollViewController.h"
#import "TPDialerResourceManager.h"
#import "CTUrl.h"
#import "FLWebViewProvider.h"
#import "TPAnalyticConstants.h"
#import "DateTimeUtil.h"
#import "NSString+TPHandleNil.h"
#import "VoipCallPopUpView.h"
#import "LocalStorage.h"
#import "PersonInfoDescViewController.h"
#import "AllViewController.h"
#import "VoipUtils.h"
#import "PhoneNumber.h"
#define sinaWeiboOAuthConsumerKey		@"1142947862"
#define debugLogFloder		@"debugLogFloder"
#define defaultLogTxt              @"defultLog.txt"

@implementation FunctionUtility

/* DATETIME UTILITY BEGINS */
+ (NSString *)timeFormat:(NSInteger)time
{
    if (time<10) {
        return [NSString stringWithFormat:@"0%d",time];
    }else {
        return [NSString stringWithFormat:@"%d",time];
    }
}

+ (NSString *)getTimeString:(NSInteger)seconds
{
    int hours = seconds/3600;
    int minutes = (seconds%3600)/60;
    int second = (seconds%3600)%60;
    NSString *timeString = @"";
    if (hours != 0) {
        timeString = [NSString stringWithFormat:@"%@:",[FunctionUtility timeFormat:hours]];
    }
    timeString = [NSString stringWithFormat:@"%@%@:%@",timeString,[FunctionUtility timeFormat:minutes],[FunctionUtility timeFormat:second]];
    return timeString;
}

+ (NSString *)getLocalShortTimeString:(NSTimeInterval)intervalFrom1970
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:intervalFrom1970];
    NSDateFormatter *formatter	=  [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:date];
}

+ (NSString *)dateString:(NSTimeInterval)time
{
    NSString *dateString = nil;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | 
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    // now
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
    int nowSecond = [comps second]; 
    int nowMinute = [comps minute];
    int nowHour = [comps hour];
    
    NSDateFormatter *formatter	=  [[NSDateFormatter alloc] init];
    NSTimeInterval nowSinceToday0Clock = (nowHour * 60 + nowMinute) * 60 + nowSecond;
    NSTimeInterval nowSince1970 = [now timeIntervalSince1970];
    NSTimeInterval delta = nowSince1970 - time;
    if (delta < nowSinceToday0Clock && delta >= 0) {
        dateString =[NSString stringWithFormat:@"%@", 
                     NSLocalizedString(@"Today", "")];
    }else {
        [formatter setDateFormat:@"MM-dd"];
        dateString = [formatter stringFromDate:date];
    }
    return dateString;
}

+ (NSString *)getSystemFormatDateString:(NSTimeInterval)time
{
	return [FunctionUtility getSystemFormatDateString:time dateOnly:NO timeOnly:NO];
}

+ (NSString *)getSystemFormatDateString:(NSTimeInterval)time dateOnly:(BOOL)dateOnly timeOnly:(BOOL)timeOnly
{
    NSString *paraTimeString = nil;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | 
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    // now
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
    int nowSecond = [comps second]; 
    int nowMinute = [comps minute];
    int nowHour = [comps hour];
    // time
    NSDate *paraDate = [NSDate dateWithTimeIntervalSince1970:time];
    //comps = [calendar components:unitFlags fromDate:paraDate];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

    NSTimeInterval nowSince1970 = [now timeIntervalSince1970];
    NSTimeInterval oneDayInterval = 24 * 60 * 60;
    NSTimeInterval nowSinceToday0Clock = (nowHour * 60 + nowMinute) * 60 + nowSecond;

    NSString* dateFormatString = @"HH:mm";
    NSString* dateFormat24String = @"yyyy-MM-dd HH:mm";
    if (time < nowSince1970) {
        NSTimeInterval delta = nowSince1970 - time;
        if (delta < nowSinceToday0Clock && delta >= 0 ) {
			[dateFormat setDateFormat:dateFormatString];
			if(dateOnly)
			{
				return [NSString stringWithFormat:@"%@", 
								  NSLocalizedString(@"Today", "")];
			}
			else if(timeOnly)
			{
				paraTimeString = [NSString stringWithFormat:@"%@", 
								  [dateFormat stringFromDate:paraDate]];
			}
			else
			{
				paraTimeString = [NSString stringWithFormat:@"%@ %@", 
								  NSLocalizedString(@"Today", ""), 
								  [dateFormat stringFromDate:paraDate]];
			}
        } else if (delta < (nowSinceToday0Clock + oneDayInterval) && delta >= 0 ) {
			[dateFormat setDateFormat:dateFormatString];
			if(dateOnly)
			{
				return [NSString stringWithFormat:@"%@", 
								  NSLocalizedString(@"Yesterday", "")];
			}
			else if(timeOnly)
			{
				paraTimeString = [NSString stringWithFormat:@"%@", 
								  [dateFormat stringFromDate:paraDate]];
			}
			else
			{
				paraTimeString = [NSString stringWithFormat:@"%@ %@", 
								  NSLocalizedString(@"Yesterday", ""), 
								  [dateFormat stringFromDate:paraDate]];
			}
        } else {
			if(dateOnly)
			{
				[dateFormat setDateStyle:NSDateFormatterMediumStyle];
				[dateFormat setTimeStyle:kCFDateFormatterNoStyle];
			}
			else if(timeOnly)
			{
				[dateFormat setDateFormat:dateFormatString];
			}
			else {
				[dateFormat setDateStyle:NSDateFormatterMediumStyle];
				[dateFormat setTimeStyle:NSDateFormatterShortStyle];
                [dateFormat setDateFormat:dateFormat24String];
			}

            paraTimeString = [dateFormat stringFromDate:paraDate];
        }
    } else {
		if(dateOnly)
		{
			[dateFormat setDateStyle:NSDateFormatterMediumStyle];
			[dateFormat setTimeStyle:kCFDateFormatterNoStyle];
		}
		
		else if(timeOnly)
		{
			[dateFormat setDateFormat:dateFormatString];
		}
		else {
			[dateFormat setDateStyle:NSDateFormatterMediumStyle];
			[dateFormat setTimeStyle:NSDateFormatterShortStyle];
            [dateFormat setDateFormat:dateFormat24String];
		}
		
		paraTimeString = [dateFormat stringFromDate:paraDate];
    }
    return paraTimeString;
}

+ (NSString *)getWeekdayDescription:(NSInteger)weekday
{
    switch (weekday) {
        case 1:
            return NSLocalizedString(@"Sunday", @"");
        case 2:
            return NSLocalizedString(@"Monday", @"");
        case 3:
            return NSLocalizedString(@"Tuesday", @"");
        case 4:
            return NSLocalizedString(@"Wednesday", @"");
        case 5:
            return NSLocalizedString(@"Thursday", @"");
        case 6:
            return NSLocalizedString(@"Friday", @"");
        case 7:
            return NSLocalizedString(@"Satuday", @"");
        default:
            cootek_log(@"getWeekDayDescription: bad week day:%d", weekday);
            break;
    }
    return @"";
}


+ (BOOL)isMoreThanOneDay:(int)newTime oldTime:(int)oldTime
{
    int hours24 = 24*60*60;
    return (newTime-oldTime)>hours24;
}

/* DATETIME UTILITY ENDS */
////////////////////////////////////////////////////////////////////////////////


/* IMAGE UTILITY BEGINS */
void addRoundedRectTooPath(CGContextRef context, CGRect rect, float ovalWidth,
						  float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+ (UIImage *)createRoundedRectImage:(UIImage*)image withSize:(CGSize)size
{
    // the size of CGContextRef
    int w = size.width*2;
    int h = size.height*2;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectTooPath(context, rect, 4, 4);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	UIImage *retimg = [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
    return retimg;
}

//resize
+ (UIImage *)imageWithResize:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

//矩形，正方形
+ (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();	
    return image;
}

//rect with board
+ (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)rect withBoardColor:(UIColor *)boardColor andBoardWidth:(int)width
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, [boardColor CGColor]);
    CGContextSetLineWidth(context, width);
    
    CGFloat minx = CGRectGetMinX(rect)+width , maxx = CGRectGetMaxX(rect)-width;
    CGFloat miny = CGRectGetMinY(rect)+width , maxy = CGRectGetMaxY(rect)-width ;
    
    CGContextMoveToPoint(context, minx, miny);
    CGContextAddLineToPoint(context, maxx, miny);
    CGContextAddLineToPoint(context, maxx, maxy);
    CGContextAddLineToPoint(context, minx, maxy);
    
    CGContextClosePath(context);
    // Fill & stroke the path
    CGContextDrawPath(context, kCGPathFillStroke);

    //CGContextSetFillColorWithColor(context, [color CGColor]);
    //CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//圆，椭圆
+ (UIImage *)imageWithColor:(UIColor *)color withOval:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();	
    return image;
}

+ (UIImage *)circleImageWithColor:(UIColor *)color withOval:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextAddArc(context, rect.size.width/2, rect.size.width/2, rect.size.width/2, 0, 2*3.14159265358979323846, 0);
    CGContextDrawPath(context, kCGPathFill);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*) getGradientImageFromStartColor:(UIColor*)startColor endColor:(UIColor*)endColor forSize:(CGSize) size
{
    UIColor* colors[2] = {startColor, endColor};
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colorComponents[8];  
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(0, size.height);
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (int i = 0; i < 2; i++) {  
        UIColor *color = colors[i];  
        CGColorRef temcolorRef = color.CGColor;
        
        const CGFloat *components = CGColorGetComponents(temcolorRef);  
        for (int j = 0; j < 4; j++) {  
            colorComponents[i * 4 + j] = components[j];  
        }         
    }  
    
    CGGradientRef gradient =  CGGradientCreateWithColorComponents(rgb, colorComponents, NULL, 2);  
    
    CGColorSpaceRelease(rgb);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage *)captureImage:(UIImage *)sourceImage
{
    float scale = [self imageScale];
    CGSize newSize = CGSizeMake(sourceImage.size.width * scale,sourceImage.size.height*scale);
    UIGraphicsBeginImageContext(newSize);
    CGRect rect =CGRectMake(0, 0,newSize.width ,newSize.height);
    //UIGraphicsBeginImageContext(rect.size);
    [sourceImage drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage*)getImageFromColorRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef cgContextRef = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(cgContextRef, red, green, blue, 1.0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage*)getImageFromUIColor:(UIColor *)color andFrame:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef cgContextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(cgContextRef, [color CGColor]);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/* IMAGE UTILITY ENDS */
////////////////////////////////////////////////////////////////////////////////

/* NSSTRING UTILITY BEGINS */
+ (BOOL)string:(NSString *)string1 sharesSuffixWithString:(NSString *)string2 suffixLength:(int)suffixLength
{
    NSInteger startIndex1 = string1.length - suffixLength;
    NSInteger startIndex2 = string2.length - suffixLength;
    
    if (startIndex1 < 0 || startIndex2 < 0) {
        return NO;
    }
    
    NSString *prefix1 = [string1 substringFromIndex:startIndex1];
    NSString *prefix2 = [string2 substringFromIndex:startIndex2];
    
    return [prefix1 isEqualToString:prefix2];
}

+ (BOOL)isNilOrEmptyString:(NSString*)string
{
    if (nil == string || [string isEqualToString:@""]) {
        return YES;
    }
    return NO;
}
/* NSSTRING UTILITY ENDS*/
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)getYellowPublicNumberPath{
    NSString *fileName=NSLocalizedString(@"yellowPublicNumber.plist", @"国家列表文件");
	return  [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
}

+ (float)imageScale {
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        return [[UIScreen mainScreen] scale];
    }
    return 1.0f;
}

+ (BOOL)is3x{
    return [[UIScreen mainScreen] scale] == 3.0f;
}

+ (void)image:(UIImage *)image drawInRect:(CGRect)rect {
    float scale = [FunctionUtility imageScale];
    float width = image.size.width/scale;
    float height = image.size.height/scale;
    if (image != nil) {
        [image drawInRect:CGRectMake((rect.size.width-width)/2, (rect.size.height-height)/2,width,height)];
    }
}

+ (BOOL)isPageActive:(NSString *)pageName {
    BOOL ret = false;
    NSArray *controllers = ((UINavigationController*)[[[UIApplication sharedApplication]delegate]window].rootViewController).viewControllers;
    for (UIViewController *ctl in controllers)
    {
        NSString *clz = NSStringFromClass(ctl.class);
        cootek_log(@"at page: %@", clz);
        if ([pageName isEqualToString:clz]) {
            ret = true;
            break;
        }
    }
    return ret;
}

+ (NSString *)currentWifiBase{
    NSString *bssid = @"";
    CFArrayRef cfArrayRef = CNCopySupportedInterfaces();
    NSArray *ifs = (__bridge id)cfArrayRef;
    for (NSString *ifnam in ifs) {
        CFStringRef cfStringRef = (CFStringRef)CFBridgingRetain(ifnam);
        CFDictionaryRef cfDicRef = CNCopyCurrentNetworkInfo(cfStringRef);
        if (cfDicRef != NULL) {
            NSDictionary *info = [(__bridge id)cfDicRef copy];
            cootek_log(@"wifi info:%@",info);
            CFRelease(cfDicRef);
            CFRelease(cfStringRef);
            if (info[@"BSSID"]) {
                bssid = info[@"BSSID"];
                break;
            }
        }
    }
    if (cfArrayRef != NULL) {
        CFRelease(cfArrayRef);
    }
    return bssid;
}

+ (BOOL)isTimeUpForEvent:(NSString *)event withSchedule:(double)schedule firstTimeCount:(BOOL)firstTimeCount persistCheck:(BOOL)persist{
    NSDate *lastUpdateDate = [UserDefaultsManager dateForKey:event
                                                defaultValue:nil];
    if ((lastUpdateDate == nil && firstTimeCount) || [lastUpdateDate compare:[NSDate date]] == NSOrderedDescending) {
        if (persist) {
            [UserDefaultsManager setObject:[NSDate date] forKey:event];
        }
        return YES;
    } else if (lastUpdateDate == nil) {
        return NO;
    }
    NSTimeInterval actualTimeInterval = [[NSDate date] timeIntervalSinceDate:lastUpdateDate];
    if (actualTimeInterval < schedule) {
        return NO;
    }
    if (persist) {
        [UserDefaultsManager setObject:[NSDate date] forKey:event];
    }
    return YES;
}

+ (NSString*)documentFile:(NSString*)file
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:file];
}

+ (NSData *)getRemoteData:(NSString *)url {
    NSURL *urlRequest=[[NSURL alloc] initWithString:url];
    NSMutableURLRequest *httpVersionRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    NSHTTPURLResponse *urlResponse=[[NSHTTPURLResponse alloc] init];
    NSData *result = [NetworkUtility sendSafeSynchronousRequest:httpVersionRequest returningResponse:&urlResponse error:nil];
    int status=[urlResponse statusCode];
    NSString *responseString=[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    cootek_log(@"response: %@", responseString);
    if (status == 200) {
        return result;
    }
    return nil;
}

+ (void) asyncVisitUrl:(NSString *)url {
    NSString *newUrl = [NSString  stringWithFormat:@"%@", url];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [FunctionUtility visitUrl:newUrl];
    });
}

+ (void)visitUrl:(NSString *)url {
    cootek_log(@"request: %@", url);
    NSURL *urlRequest=[[NSURL alloc] initWithString:url];
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [request setValue:[NSString stringWithFormat:@"auth_token=%@", [SeattleFeatureExecutor getToken]] forHTTPHeaderField:@"Cookie"];
    NSHTTPURLResponse *urlResponse=[[NSHTTPURLResponse alloc] init];
    [NetworkUtility sendSafeSynchronousRequest:request returningResponse:&urlResponse error:nil];
    int status=[urlResponse statusCode];
    cootek_log(@"response: %d", status);
}

+ (void)asyncWithUAVisitUrl:(NSString *)url tryTime:(NSUInteger)time{
    cootek_log(@"request: %@", url);
    if (url.length==0) {
        return;
    }
    __block NSInteger status = 0;
    __block NSUInteger maxTime = time;
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSURL *urlRequest=[[NSURL alloc] initWithString:url];
        NSMutableURLRequest *request= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
        [request setValue:[NSString stringWithFormat:@"auth_token=%@", [SeattleFeatureExecutor getToken]] forHTTPHeaderField:@"Cookie"];
        [request setValue:[FunctionUtility getWebViewUserAgent] forHTTPHeaderField:@"User-Agent"];
        NSHTTPURLResponse *urlResponse=[[NSHTTPURLResponse alloc] init];
        while(status!=200 && maxTime >0) {
            [NetworkUtility sendSafeSynchronousRequest:request returningResponse:&urlResponse error:nil];
            status = [urlResponse statusCode];
            maxTime--;
            cootek_log(@"response: %d", status);

        }

    });
}


+ (void)visitUrl:(NSString *)url param:(NSDictionary *)param {
    if ( !url || url.length == 0) {
        return;
    }
    
    NSMutableString *paramString = [NSMutableString stringWithString:@""];
    if (param && [param count]) {
        NSArray *keyList = [param allKeys];

        for (id key in keyList) {
            id value = param[key];

            if ( !([key isKindOfClass:NSString.class]) || !([value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class])) {
                continue; // only handle string and number
            }
            
            if ([value isKindOfClass:NSNumber.class]) {
                value = [(NSNumber *)value stringValue];
            }

            [paramString appendFormat:@"%@=%@&", key, value];
        }

        if (paramString.length > 0) {
            [paramString replaceCharactersInRange:NSMakeRange(paramString.length - 1, 1) withString:@""];
        }
    }

    NSString    *connectMark = ([url rangeOfString:@"?"].length > 0) ? @"&" : @"?";
    NSString    *requestUrl = [NSString stringWithFormat:@"%@%@%@", url, connectMark, paramString];
    [self visitUrl:requestUrl];
}

+ (NSString *)getRemoteTxtContent:(NSString *)url {
    NSData *data = [self getRemoteData:url];
    NSString *responseString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return responseString;
}

+ (NSDictionary *)getDictionaryFromJsonString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error =nil;
    NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
    if (error) {
        cootek_log(@"%@",error);
    }
    return returnData;
}

+ (NSString *)generateUUID {
    // debugging for activating problem
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSString * UUID = (__bridge NSString *)string;
    cootek_log(@"UUID: %@", UUID);
    CFRelease(theUUID);
    CFRelease(string);
    return UUID;
}


+ (NSString *)GetUUID
{
    // debugging for activating problem
    @synchronized(self) {
        NSString *guids = [UserDefaultsManager stringForKey:GLOBALLY_UNIQUE_ID];
        if (!guids || [guids length] == 0) {
            NSString * UUID = [OpenUDID value];//[[UIDevice currentDevice] uniqueIdentifier];
            if (!UUID||[UUID length] == 0) {
                UUID = [self generateUUID];
                [UserDefaultsManager setObject:UUID forKey:GLOBALLY_UNIQUE_ID];
            } else {
                [UserDefaultsManager setObject:UUID forKey:GLOBALLY_UNIQUE_ID];
            }
        }
    }
    return [UserDefaultsManager stringForKey:GLOBALLY_UNIQUE_ID];;
}

+ (void)shortenUrl:(NSString*)url andBlock:(void (^)(NSString *url))block{
    NSMutableDictionary *urlDic = (NSMutableDictionary*)[UserDefaultsManager objectForKey:VOIP_SHORT_URL_DIC defaultValue:[NSMutableDictionary dictionary]];
    NSString *dicUrl = [urlDic objectForKey:url];
    if ( dicUrl ){
        block(dicUrl);
        return;
    }
    NSString *encodeUrl = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil,(CFStringRef)url, nil,(CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSString *requestUrl = [NSString stringWithFormat:@"https://api.weibo.com/2/short_url/shorten.json?source=%@&url_long=%@",sinaWeiboOAuthConsumerKey,encodeUrl];
        NSString *resultJson = [FunctionUtility getRemoteTxtContent:requestUrl];
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *resultUrl = url;
            if (resultJson != nil) {
                NSDictionary *dic = [FunctionUtility getDictionaryFromJsonString:resultJson];
                if ( dic ){
                    NSDictionary *dicResult = [[dic objectForKey:@"urls"] objectAtIndex:0];
                    if ( dicResult && [dicResult count] > 0){
                        if ( [[dicResult objectForKey:@"result"] integerValue] == 1){
                            resultUrl = [dicResult objectForKey:@"url_short"];
                            [urlDic setValue:resultUrl forKey:url];
                            [UserDefaultsManager setObject:urlDic forKey:VOIP_SHORT_URL_DIC];
                        }
                    }
                }
            }
            block(resultUrl);
        });
    });
    
}

+ (BOOL)isCurrentBetweenDate:(NSString *)date1 andDate:(NSString *)date2 {
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formater stringFromDate:[NSDate date]];
    NSComparisonResult c1 = [dateString compare:date1];
    NSComparisonResult c2 = [dateString compare:date2];
    return  c1 >= NSOrderedSame &&  c2 <= NSOrderedSame;
}

+ (NSString*)networkType
{
    NSString *type = @"";
    switch([[Reachability shareReachability] networkStatus]) {
        case network_wifi:
            type = @"wifi";
            break;
        case network_2g:
            type = @"2g";
            break;
        case network_3g:
            type = @"3g";
            break;
        case network_none:
            type = @"none";
            break;
        case network_4g:
            type = @"4g";
            break;
        case network_lte:
            type = @"lte";
            break;
        default:
            break;
    }
    return type;
}

+ (NSString*) deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString*) generateWechatMessage:(NSString *)tempId andFrom:(NSString *)from{
    NSString* inviteCode = [UserDefaultsManager stringForKey:VOIP_INVITATION_CODE];
    NSString* versionCode = CURRENT_TOUCHPAL_VERSION;
    NSString* channel = IPHONE_CHANNEL_CODE;
    NSString* resultURL = [NSString stringWithFormat:@"http://dialer.cdn.cootekservice.com/web/external/dec2/index.html?inviteCode=%@&versionCode=%@&channel=%@&tempId=%@&share=%@",inviteCode,versionCode,channel,tempId,from];
    return resultURL;
}

+ (NSString*) generateUrlMessage:(NSString *)url andTemptId:(NSString *)tempId andFrom:(NSString *)from{
    NSString* inviteCode = [UserDefaultsManager stringForKey:VOIP_INVITATION_CODE];
    NSString* versionCode = CURRENT_TOUCHPAL_VERSION;
    NSString* channel = IPHONE_CHANNEL_CODE;
    NSString* resultURL;
    if ([url rangeOfString:@"?"].length == 0) {
        resultURL = [NSString stringWithFormat:@"%@?inviteCode=%@&versionCode=%@&channel=%@&tempId=%@&share=%@",url,inviteCode,versionCode,channel,tempId,from];
    }else{
        resultURL = [NSString stringWithFormat:@"%@&inviteCode=%@&versionCode=%@&channel=%@&tempId=%@&share=%@",url,inviteCode,versionCode,channel,tempId,from];
    }
    return resultURL;
}

+ (NSString *)getTagString:(NSString *)tag inString:(NSString *)string {
    if ([string rangeOfString:tag].length <= 0) {
        return nil;
    }
    NSRange range = [string rangeOfString:tag];
    int i = range.location + range.length;
    for (; i<string.length; i++) {
        if ([string characterAtIndex:i] == ';') {
            break;
        }
    }
    NSRange targetRange;
    targetRange.length = i - (range.location + range.length);
    targetRange.location = range.location + range.length;
    return [string substringWithRange:targetRange];
}

+ (void)screenShot:(UIView*)view name:(NSString *)name{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height) , YES, 4);

    //设置截屏大小
    
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect = CGRectMake(0, 0, view.frame.size.width * 4, view.frame.size.height * 4);//这里可以设置想要截图的区域
    
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    
    
    //以下为图片保存代码
    
    UIImageWriteToSavedPhotosAlbum(sendImage, nil, nil, nil);//保存图片到照片库
    
    NSData *imageViewData = UIImagePNGRepresentation(sendImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pictureName= name;
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:pictureName];
    [imageViewData writeToFile:savedImagePath atomically:YES];//保存照片到沙盒目录
    
    CGImageRelease(imageRefRect);
    
    cootek_log(@"picture has shotted!");
    
//    //从手机本地加载图片
//    
//    UIImage *bgImage2 = [[[UIImage alloc]initWithContentsOfFile:savedImagePath] autorelease];//
    
}

+ (UIImage *)addTwoImageToOne:(UIImage *)oneImg
                     twoImage:(UIImage *)twoImg
                    xposition:(NSInteger)xpos
                    yposition:(NSInteger)ypos

{
    
    UIGraphicsBeginImageContext(oneImg.size);
    
    [oneImg drawInRect:CGRectMake(0, 0, oneImg.size.width, oneImg.size.height)];
    
    //*scale这个是临时处理，因为oneImg是从摄像头来的，是实际的大小，twoImg不是
    [twoImg drawInRect:CGRectMake(xpos, ypos, oneImg.size.width-xpos, oneImg.size.height-ypos)];
    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImg;
    
}

+ (UIImage *)addLabelToImage:(UIImage *)image
                    andTitle:(NSString *)title
                     andRect:(CGRect)titleRect
                     andFont:(UIFont *)titleFont
                    andColor:(UIColor *)textColor
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, textColor.CGColor);
    [title drawInRect:titleRect withFont:titleFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImg;
}

+ (BOOL)isInChina {
    if (HARD_CODE_C2C_SUPORT) {
        if ([UserDefaultsManager boolValueForKey:@"test_c2c_support"]) {
            return NO;
        }
        NSString *timeZone = [NSTimeZone localTimeZone].description.lowercaseString;
        dispatch_async(dispatch_get_main_queue(), ^{
            [DefaultUIAlertViewHandler showAlertViewWithTitle:@"请把这个框截图发给我们吧" message:[NSString stringWithFormat:@"当前时区:%@", timeZone]];
        });
        [UserDefaultsManager setBoolValue:YES forKey:@"test_c2c_support"];
        return NO;
    }
    if ([UserDefaultsManager boolValueForKey:@"inter_roaming"]) {
        return NO;
    }
    NSString *timeZone = [NSTimeZone localTimeZone].description.lowercaseString;
    if ( ([timeZone rangeOfString:@"gmt+8"].length > 0 || [timeZone rangeOfString:@"gmt+08"].length > 0) && [timeZone rangeOfString:@"asia/"].length > 0) {
        //still may some country that is not China, but we try the best
        return YES;
    }
    if (![UserDefaultsManager boolValueForKey:HAS_RECORD_USER_INTER_ROMAING]) {
        [DialerUsageRecord recordpath:USER_INTERNATIONAL_ROAMING kvs:Pair(@"intl-roaming", @(YES)), nil];
        [UserDefaultsManager setBoolValue:YES forKey:HAS_RECORD_USER_INTER_ROMAING];
    }
    return NO;
}

+ (NSString *)saveImage:(NSData *)imageData withImageName:(NSString*)imageName{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = imageName;
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    BOOL ret = [imageData writeToFile:filePath atomically:YES];
    if (ret) {
        return fileName;
    } else {
        return nil;
    }
}

+ (BOOL)removeDocumentFile:(NSString *)path {
    NSString *fullPath = [self documentFile:path];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([manager fileExistsAtPath:fullPath]) {
        [manager removeItemAtPath:fullPath error:&error];
    }
    if (error) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSString *)simpleEncodeForString:(NSString *)string {
    if (string.length == 0) {
        return nil;
    }
    //1 round
    int middle = string.length/7;
    NSString *prefix = [string substringToIndex:middle];
    NSString *suffix = [string substringFromIndex:middle];
    NSString *mix = [NSString stringWithFormat:@"%@%@", suffix, prefix];
    //second round
    middle = mix.length/4;
    prefix = [mix substringToIndex:middle];
    suffix = [mix substringFromIndex:middle];
    mix = [NSString stringWithFormat:@"%@%@", suffix, prefix];
    //map
    NSMutableString *mapString = [NSMutableString stringWithString:@""];
    for (int i = 0; i<mix.length; i++) {
        unichar e = [mix characterAtIndex:i];
        unichar newchar = 3*e + 33;
        [mapString appendString:[NSString stringWithCharacters:&newchar length:1]];
    }
    return mapString;
}

+ (NSString *)simpleDecodeForString:(NSString *)string {
    if (string.length == 0) {
        return nil;
    }
    //unmap
    NSMutableString *unmapString = [NSMutableString stringWithString:@""];
    for (int i = 0; i < string.length; i ++) {
        unichar e = [string characterAtIndex:i];
        unichar c = (e - 33)/3;
        [unmapString appendString:[NSString stringWithCharacters:&c length:1]];
    }
    //second round
    int middle = unmapString.length - unmapString.length/4;
    NSString *prefix = [unmapString substringToIndex:middle];
    NSString *suffix = [unmapString substringFromIndex:middle];
    NSString *unmix = [NSString stringWithFormat:@"%@%@", suffix, prefix];
    //first round
    middle = unmix.length - unmix.length/7;
    prefix = [unmix substringToIndex:middle];
    suffix = [unmix substringFromIndex:middle];
    return [NSString stringWithFormat:@"%@%@", suffix, prefix];
}

+ (void)writeDefaultKeyToDefaults:(NSString *)name andObject:(id)object andKey:(NSString *)key{
    if ( [[UIDevice currentDevice].systemVersion intValue] > 7){
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:name];
        [shared setObject:object forKey:key];
        [shared synchronize];
    }
}

+ (void)writeDefaultKeyToDefaults:(NSString *)name andBoolValue:(BOOL)value andKey:(NSString *)key{
    if ( [[UIDevice currentDevice].systemVersion intValue] > 7){
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:name];
        [shared setBool:value  forKey:key];
        [shared synchronize];
    }
}

+ (id)readDataFromNSUserDefaults:(NSString *)name andKey:(NSString *)key
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:name];
    id value = [shared valueForKey:key];
    return value;
}
+ (BOOL)readBoolValueFromNSUserDefaults:(NSString *)name andKey:(NSString *)key
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:name];
    BOOL value = [shared boolForKey:key];
    return value;
}

+ (void)shareSMS:(NSString *)smsUrl andNeedDefault:(BOOL)needDefault andMessage:(NSString *)msg andNumber:(NSString *)phoneNumber andFromWhere:(NSString *)fromWhere{
    [FunctionUtility shortenUrl:smsUrl andBlock:^(NSString *url){
        if ( needDefault && [smsUrl isEqualToString:url ]){
            url = @"http://t.cn/Rz2PYLn";
        }
        NSString *message = [NSString stringWithFormat:@"%@%@",msg,url];
        UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
        [TPMFMessageActionController sendMessageToNumber:phoneNumber
                                             withMessage:message
                                             presentedBy:aViewController];
        [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_SINGLE_SMS, fromWhere), nil];
    }];
}

+ (void)sharePasteboard:(NSString *)smsUrl andNeedDefault:(BOOL)needDefault andFromWhere:(NSString *)fromWhere title:(NSString *)title{
    [FunctionUtility shortenUrl:smsUrl andBlock:^(NSString *url){
        if ((needDefault && [smsUrl isEqualToString:url])){
            url = @"http://t.cn/Rzt2p5m";
        }
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];

        
        if (title==nil){
            pasteboard.string = [NSString stringWithFormat:NSLocalizedString(@"voip_copy_share_message", @""),  [UserDefaultsManager stringForKey:VOIP_INVITATION_CODE] ,url];
            cootek_log(pasteboard.string);
        }
        else{
            pasteboard.string = [NSString stringWithFormat:@"%@%@",title,url];
        }
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_copy_success", @"") message:nil];
        [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_SINGLE_COPY, fromWhere), nil];
    }];
}

+ (void)shareByWeixin:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andResultCallback:(id)resultCallback{
    [self downloadImage:imageUrl usingBlock:^(UIImage *downloadImage){
        [[TPShareController controller] voipWechatShare:title andDescription:msg andUrl:url andImage:downloadImage andIfTimeLine:NO resultCallback:resultCallback];
        [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_SINGLE_WECHAT, fromWhere), nil];
    }];
}

+ (void)shareByWeixinTimeline:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andResultCallback:(id)resultCallback{
    [self downloadImage:imageUrl usingBlock:^(UIImage *downloadImage){
        [[TPShareController controller] voipWechatShare:title andDescription:msg andUrl:url andImage:downloadImage andIfTimeLine:YES resultCallback:resultCallback];
        [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_TIMELINE_WECHAT, fromWhere), nil];
    }];
    
}
+ (void)shareByWeixinImage:(UIImage *)image andFromWhere:(NSString *)fromWhere andIfTimeLine:(BOOL)TimeLine{
    [[TPShareController controller] voipWechatSharePic:image andIfTimeLine:TimeLine];
    [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_TIMELINE_WECHAT, fromWhere), nil];
}

+ (void)shareByQQ:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andResultCallback:(id)resultCallback{
    [[QQShareController instance] shareQQMessage:title andDescription:msg andUrl:url andImageUrl:imageUrl andIfQQZone:NO resultCallback:resultCallback];
    [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_SINGLE_QQ, fromWhere), nil];
}

+ (void)shareByQQZone:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andResultCallback:(id)resultCallback{
    [[QQShareController instance] shareQQMessage:title andDescription:msg andUrl:url andImageUrl:imageUrl andIfQQZone:YES resultCallback:resultCallback];
    [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_QZONE_QQ, fromWhere), nil];
    
}

+ (void)shareByWeixinImageByImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andIfTimeLine:(BOOL)timeline{
    [self downloadImage:imageUrl usingBlock:^(UIImage *downloadImage){
        if ( downloadImage == nil ){
            cootek_log(@"shareByWeixinImageByImageUrl error imageUrl: %@", imageUrl);
            return;
        }
        [[TPShareController controller] voipWechatSharePic:downloadImage andIfTimeLine:timeline];
        [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_TIMELINE_WECHAT, fromWhere), nil];
    }];
    
}

+ (void)shareTextByWeixin:(NSString *)text andThumbImage:(UIImage *)image andSuccesBlock:(void (^)())block {
    [[TPShareController controller] voipWechatShareText:text andImage:image andBlock:block];
}

+ (UIViewController *)openUrl:(NSString *)url withTitle:(NSString *)title {
    UIViewController *controller = nil;
    if ([url hasPrefix:@"http"]) {
        CTUrl *ctUrl = [[CTUrl alloc] initWithUrl:url];
        [ctUrl addOtherParams];
        controller = [ctUrl startWebView];
    } else {
        controller =  [[NSClassFromString(url) alloc] init];
        if (controller) {
            [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
        }
    }
    
    return controller;
}

+ (NSString *)getIpAddress {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (BOOL)judgeContactAccessFail{
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] ){
        NSString *showString = nil;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
            showString = @"该功能无法正常使用，请在「设置-通通宝」中允许通通宝访问您的通讯录";
        }else{
            showString = @"该功能无法正常使用，前往「设置-隐私-通讯录」中允许通通宝访问您的通讯录";
        }
        
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"未开启联系人权限" message:showString cancelTitle:@"取消" okTitle:@"立即设置" okButtonActionBlock:^(){
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
        return YES;
    }
    return NO;
}



+ (UILabel *)labelNoBgWithRect:(CGRect)frame font:(UIFont *)font align:(NSTextAlignment)align textColor:(UIColor *)textColor andText:(NSString *)text{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.textAlignment = align;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
    return label;
}

+ (void)setAppHeaderStyle {
    NSString *flag = (NSString *) [[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"statusBar_isDefaultStyle"];
    if ([flag isEqualToString:@"1"]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

+ (void)removeFromStackViewController:(UIViewController *)controller {
    if (controller == nil) {
        return;
    }
    UINavigationController *navi = [TouchPalDialerAppDelegate naviController];
    NSMutableArray *array = [NSMutableArray arrayWithArray:navi.childViewControllers];
    unsigned tag = 0;
    for (UIViewController *child in array) {
        if (child == controller) {
            break;
        }
        tag ++;
    }
    if (tag >= array.count) {
        return;
    }
    [array removeObjectAtIndex:tag];
    [controller removeFromParentViewController];
    [navi setViewControllers:array];
}

+ (void)executeJavaScript:(UIView<FLWebViewProvider> *)webview withScript:(NSString* )script{
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [webview evaluateJavaScript:script completionHandler:nil];
        });
    } else {
        [webview evaluateJavaScript:script completionHandler:nil];
    }
}

+ (void)downloadImage:(NSString *)imageUrl usingBlock:(void(^)(UIImage *image)) block{
    if ( !imageUrl ){
        block(nil);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [indicator setCenter:CGPointMake(TPScreenWidth()/2, TPScreenHeight()/2)];
        [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.hidesWhenStopped = YES;
        [indicator startAnimating];
        UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [uiWindow addSubview:indicator];
        [uiWindow bringSubviewToFront:indicator];
        __block UIImage *resultImage = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *urlRequest=[[NSURL alloc] initWithString:imageUrl];
            NSMutableURLRequest *httpVersionRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                              timeoutInterval:5];
            NSHTTPURLResponse *urlResponse=[[NSHTTPURLResponse alloc] init];
            NSData *result = [NSURLConnection sendSynchronousRequest:httpVersionRequest returningResponse:&urlResponse error:nil];
            
            int status=[urlResponse statusCode];
            if (status == 200) {
                resultImage = [UIImage imageWithData:result];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block){
                    block(resultImage);
                }
                [indicator stopAnimating];
            });
        });
        
    });
    
}

+ (float)systemVersionFloat {
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}
+(void)popToRootViewWithIndex:(NSInteger)index{
    UINavigationController *navigationController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    [navigationController popToRootViewControllerAnimated:YES];
    RootScrollViewController *root = [[TouchPalDialerAppDelegate naviController].viewControllers objectAtIndex:0];
    [root selectTabIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PHONE_PAD_SHOW object:nil userInfo:nil];
}
+(BOOL)arc4randomIfmMorePersent:(NSInteger)persent{
    int random = arc4random()%100;
        return random>persent;
}

+(void)popViewController{
    UINavigationController *navigationController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    [navigationController popViewControllerAnimated:YES];
}


+(BOOL)checkIfNot138testNumber{
    NSString  *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:@""];
    if (accountName.length>0 && [accountName isEqualToString:@"+8613800000000"]){
        return NO;
    }
    return YES;
}
+(BOOL)checkIfVIPNull{
    NSInteger registerIntTime = [UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME defaultValue:0];
    BOOL ifVIP = [UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO];
    BOOL ifNextDay = [self judgeTimeAfterNatureDayWithID:CHECK_ID_VIP_NULL_DAY];
    if (registerIntTime>3 && !ifVIP && ifNextDay) {
        [UserDefaultsManager setBoolValue:YES forKey:VIP_NULL_DAY_SHOW];
        return  YES;
    }else{
        return NO;
    }
    
    
}
+ (BOOL)judgeTimeAfterNatureDayWithID:(NSString *)ID{
    NSDateComponents *eventLastCom = (NSDateComponents *)[UserDefaultsManager objectForKey:ID];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *today = [calendar components:unitFlags fromDate:[NSDate date]];
    BOOL ifNextDay = NO;
    if ( today.year > eventLastCom.year ){
        ifNextDay = YES;
    }else{
        if ( today.month > eventLastCom.month ){
                ifNextDay = YES;
        }else{
            if ( today.day > eventLastCom.day){
                [UserDefaultsManager setBoolValue:NO forKey:VIP_NULL_DAY_SHOW];
                ifNextDay = YES;
            }
        }
    }
    if (ifNextDay ) {
        [UserDefaultsManager setObject:today forKey:CHECK_ID_VIP_NULL_DAY];
        
    }
    return ifNextDay;
}

+ (UIImage *) getQRImageFromString:(NSString *) qrstring withSize:(CGSize) size {
    if (!qrstring || CGSizeEqualToSize(size, CGSizeZero)) {
        return nil;
    }
    NSData *stringData = [qrstring dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *image = [qrFilter outputImage];
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size.width/CGRectGetWidth(extent), size.height/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}
/**
 *
 #define kAD_TU_HANGUP  @"1"
 #define kAD_TU_CALLING @"4"
 #define kAD_TU_VOIP_PRIVILEGE @"21"
 #define kAD_TU_LAUNCH @"26"
 #define kAD_TU_BACKCALL @"32"
 #define kAD_TU_BACKCALLHANG @"33"
 */
+(NSDictionary *)getADViewSizeWithTu:(NSString *)tu{
    if ([NSString isNilOrEmpty:tu]) {
        return nil;
    }
    NSUInteger w = TPScreenWidth();
    NSUInteger h = TPScreenHeight();
    if ([FunctionUtility systemVersionFloat] < 7.0) {
        h = h - 20;
    }
    NSUInteger scale = [[UIScreen mainScreen] scale];
    
    switch (tu.integerValue) {
        case 26:{
            CGSize logoSize = scale>2 ? CGSizeMake(1242,342):CGSizeMake(720,198);
            CGFloat logoViewWidth = TPScreenWidth();
            CGFloat logoViewHeight = (logoSize.height / logoSize.width) * logoViewWidth;
            h = TPScreenHeight() - logoViewHeight;
        }
            break;
        case 4:
            break;
        case 1:
            break;
        case 21:
            w = 20;
            h = 20;
            break;
        case 32:
            break;
        case 33:
            break;
        case 36: {
            // kAD_TU_CALL_POPUP_HTML
            BOOL isVoipOn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]
            && [UserDefaultsManager boolValueForKey:IS_VOIP_ON];
            NSUInteger offset = MARGIN_TOP_OF_SETTING_LABEL;
            if (isVoipOn && [AppSettingsModel appSettings].dialerMode == DialerModeVoip) {
                offset += MARGIN_BOTTOM_OF_FREE_CALL_BUTTON + CALL_BUTTON_HEIGHT;
            }
            h = h - (VOIP_POPUP_VIEW_HEIGHT - offset) * POPUP_VIEW_SCALE_RATIO;
            break;
        }
        case 40:
        {
            w = 213;
            h = 33;
        }
        default:
            break;
    }
    return  @{@"w":[NSString stringWithFormat:@"%d",w*scale],@"h":[NSString stringWithFormat:@"%d",h*scale]};
}


+ (void) setStatusBarHidden:(BOOL)hidden{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        //WARNING: this selector is deprecated from 9.0
        [application setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
    }
}


#pragma mark --- Send Email ---
+ (void) sendEmailToAddress:(NSString *)emailAddress andSubject:(NSString *)subject withHeader:(NSString *)emailHeader withBody:(NSString *)emailbody {
    if ([emailAddress rangeOfString:@"@"].location == NSNotFound) {
        return;
    }
    if ([NSString isNilOrEmpty:emailbody]) {
        return;
    }
    NSString *emailString = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@\n%@",\
            emailAddress, [NSString nilToEmpty:subject], [NSString nilToEmpty:emailHeader], emailbody];
    NSURL *emailInfo = [NSURL URLWithString:[emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:emailInfo];
}


#pragma mark status bar style
+ (void) setStatusBarStyleByDefaultSkin {
    NSString *flag = (NSString *) [[TPDialerResourceManager sharedManager] getResourceNameInDefaultPackageByStyle:@"statusBar_isDefaultStyle"];
    [FunctionUtility setStatusBarStyleToDefault:[flag isEqualToString:@"1"]];
}

+ (void) updateStatusBarStyle {
    NSString *flag = (NSString *) [[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"statusBar_isDefaultStyle"];
    [FunctionUtility setStatusBarStyleToDefault:[flag isEqualToString:@"1"]];
}

+ (void) setStatusBarStyleToDefault:(BOOL)isDefault {
    if (isDefault) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}


#pragma mark debug view helpers
+ (void) setBorderForView:(UIView *)view color:(UIColor *)borderColor width:(CGFloat)borderWidth {
    if (!view) {
        return;
    }
    if (!borderColor) {
        borderColor = [UIColor clearColor];
    }
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = borderColor.CGColor;
}

+ (void) setBorderForView:(UIView *)view colorStyle:(NSString *)borderStyle width:(CGFloat)borderWidth {
    UIColor *color = [TPDialerResourceManager getColorForStyle:borderStyle];
    [FunctionUtility setBorderForView:view color:color width:borderWidth];
}

+ (void) setBorderForView:(UIView *)view {
    [FunctionUtility setBorderForView:view width:2];
}

+ (void) setBorderForView:(UIView *)view width:(CGFloat)borderWidth {
    NSInteger index = [DateTimeUtil currentTimestampInMillis] % 10;
    NSString *colorStyle = [NSString stringWithFormat:@"tp_color_red_%d00", index];
    [FunctionUtility setBorderForView:view colorStyle:colorStyle width:borderWidth];
}

+ (void) setBorderForViewArray:(NSArray *)views {
    for(UIView *view in views) {
        [self setBorderForView:view];
    }
}

+ (void) setBorderForView:(UIView *)view colorStyle:(NSString *)colorStyle {
    if ([NSString isNilOrEmpty:colorStyle]) {
        return;
    }
    UIColor *color = [TPDialerResourceManager getColorForStyle:colorStyle];
    [FunctionUtility setBorderForView:view color:color];
}

+ (void) setBorderForView:(UIView *)view color:(UIColor *)color {
    [FunctionUtility setBorderForView:view color:color width:2];
}

+ (void) verticallyCenterView:(UIView *)subview inParentView:(UIView *)parentView {
    if (!parentView || CGRectIsNull(parentView.frame) || parentView.frame.size.height == 0) {
        return;
    }
    [FunctionUtility verticallyCenterView:subview inParentHeight:parentView.frame.size.height];
}

+ (void) verticallyCenterView:(UIView *)subview inParentHeight:(CGFloat)parentHeight {
    if (!subview || CGRectIsNull(subview.frame) || subview.frame.size.height == 0) {
        return;
    }
    CGFloat offset = (parentHeight - subview.frame.size.height) / 2;
    CGRect frame = subview.frame;
    subview.frame = CGRectMake(frame.origin.x, offset, frame.size.width, frame.size.height);
}

+ (void) horizontallyCenterView:(UIView *)subview inParentView:(UIView *)parentView {
    if (!parentView || CGRectIsNull(parentView.frame) || parentView.frame.size.width == 0) {
        return;
    }
    [FunctionUtility horizontallyCenterView:subview inParentWidth:parentView.frame.size.width];
}

+ (void) horizontallyCenterView:(UIView *)subview inParentWidth:(CGFloat)parentWidth {
    if (!subview || CGRectIsNull(subview.frame) || subview.frame.size.width == 0) {
        return;
    }
    CGFloat offset = (parentWidth - subview.frame.size.width) / 2;
    CGRect frame = subview.frame;
    subview.frame = CGRectMake(offset, frame.origin.y, frame.size.width, frame.size.height);
}

+ (void) verticallyCenterViewArray:(NSArray *)subviews inParentHeight:(CGFloat)parentHeight {
    for(UIView *subview in subviews) {
        [FunctionUtility verticallyCenterView:subview inParentHeight:parentHeight];
    }
}

+ (void) horizontallyCenterViewArray:(NSArray *)subviews inParentWidth:(CGFloat)parentWidth {
    for(UIView *subview in subviews) {
        [FunctionUtility horizontallyCenterView:subview inParentWidth:parentWidth];
    }
}


#pragma mark helpers for view position and size
+ (void) setX:(CGFloat)x forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    CGRect frame = view.frame;
    view.frame = CGRectMake(x, frame.origin.y, frame.size.width, frame.size.height);
}

+ (void) setY:(CGFloat)y forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    CGRect frame = view.frame;
    view.frame = CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height);
}

+ (void) setOrigin:(CGPoint)op forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    CGRect frame = view.frame;
    view.frame = CGRectMake(op.x, op.y, frame.size.width, frame.size.height);
}

+ (void) setXOffset:(CGFloat)dx forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    [FunctionUtility setX:(dx + view.frame.origin.x) forView:view];
}

+ (void) setYOffset:(CGFloat)dy forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    [FunctionUtility setX:(dy + view.frame.origin.y) forView:view];
}

+ (void) setWidth:(CGFloat)w forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    CGRect frame = view.frame;
    view.frame = CGRectMake(frame.origin.x, frame.origin.y, w, frame.size.height);
}

+ (void) setHeight:(CGFloat)h forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    CGRect frame = view.frame;
    view.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, h);
}

+ (void) setSize:(CGSize)size forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    CGRect frame = view.frame;
    view.frame = CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height);
}

+ (void) setWidthOffset:(CGFloat)widthOffset forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    [FunctionUtility setWidth:(widthOffset + view.frame.size.width) forView:view];
}

+ (void) setHeightOffset:(CGFloat)heightOffset forView:(UIView *)view {
    if (view == nil || CGRectIsNull(view.frame)) {
        return;
    }
    [FunctionUtility setWidth:(heightOffset + view.frame.size.height) forView:view];
}

+ (UIColor *) getPersonDefaultColorByPersonId:(NSInteger)personId {
    // currently there are 2 types for person background color
    if (personId < 0) {
        personId = 0;
    }
    NSString *colorName = [NSString stringWithFormat:@"person_default_image_%d_color", personId % PERSON_DEFAULT_COLOR_TYPES];
    return [TPDialerResourceManager getColorForStyle:@"skinContactDefaultPhotoBackground_color"];
}

+(NSString *)getWebViewUserAgent{
    NSString *myUserAgent = [UserDefaultsManager stringForKey:UserAgent defaultValue:@""];
    if (myUserAgent.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
            NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            [UserDefaultsManager setObject:userAgent forKey:UserAgent];
        });
    }
    return myUserAgent;

}

+ (UIColor *) getBgColorOfLongPressView {
    NSDictionary *longPressStyle = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"longPressView_style"];
    return [TPDialerResourceManager getColorForStyle:[longPressStyle objectForKey:@"bottom_backgroundColor"]];
}


+ (void)saveLogInDebugToDocFile:(NSString *)filepath withLog:(NSObject *)log{
#ifdef DEBUG
        NSDate *senddate=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *locationString=[dateformatter stringFromDate:senddate];
        NSLog(@"locationString:%@",locationString);
        NSString *logfloder = [FileUtils getAbsoluteFilePath:debugLogFloder];
        if (![FileUtils fileExistAtAbsolutePath:logfloder]) {
            [FileUtils createDir:logfloder];
        }
        NSString *filelogfloderpath  =[logfloder stringByAppendingPathComponent:filepath];
        if (![FileUtils fileExistAtAbsolutePath:filelogfloderpath]) {
            [FileUtils createfile:filelogfloderpath];
        }
        NSError *error = nil;
        NSString *alresdyString = [NSString stringWithContentsOfFile:filelogfloderpath encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            [[NSString stringWithFormat:@"%@ saveLogInDebugToDocFile get error = %@ filelogfloderpath = %@" ,locationString,[error description],filelogfloderpath] writeToFile:[FunctionUtility defaultLogFilePath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
            return;
        }
        if (alresdyString.length==0) {
            alresdyString = [NSString stringWithFormat:@"%@ %@",locationString,log];
        }else{
            alresdyString = [NSString stringWithFormat:@"%@ \n%@ %@",alresdyString,locationString,log];
        }
        
        [alresdyString writeToFile:filelogfloderpath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (error){
            [[NSString stringWithFormat:@"saveLogInDebugToDocFile write error = %@ filelogfloderpath = %@" ,[error description],filelogfloderpath] writeToFile:[FunctionUtility defaultLogFilePath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
#endif
}
+(NSString *)defaultLogFilePath{
    NSString *logfloder = [FileUtils getAbsoluteFilePath:debugLogFloder];
    if (![FileUtils fileExistAtAbsolutePath:logfloder]) {
        [FileUtils createDir:logfloder];
    }
    NSString *defaultPath  =[logfloder stringByAppendingPathComponent:defaultLogTxt];
    if (![FileUtils fileExistAtAbsolutePath:defaultPath]) {
        [FileUtils createfile:defaultPath];
    }
    return defaultPath;
}
+ (void)writeUsedTimeToReadyResourcePlistWithArray:(NSArray *)array {
        NSDate *useDate=[NSDate date];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        NSString *useTimeString = [DateTimeUtil dateStringByFormat:@"yyyy-MM-dd HH:mm:ss" fromDate:useDate];
        NSMutableArray *existResources = [[VoipUtils getResource:ALL_RESOURCE_WITHIN_TIME_PLIST] mutableCopy];
        int count = array.count;
        for (NSDictionary *newDic in array) {
            for (NSDictionary *oldDic in existResources) {
                if ([oldDic[@"dest"] isEqualToString:newDic[@"dest"]]) {
                    [indexSet addIndex:[existResources indexOfObject:oldDic]];
                }
            }
        }
        for (int i = 0 ; i < count ;i ++ ) {
            NSMutableDictionary *dic  = [[array objectAtIndex:i] mutableCopy];
            dic[@"used"] =useTimeString;
            [existResources addObject:dic];
        }
        [existResources removeObjectsAtIndexes:indexSet];
        [existResources writeToFile:[VoipUtils pathForResoucePlist:ALL_RESOURCE_WITHIN_TIME_PLIST] atomically:YES];
}

+ (void)deleteFileAndPlistIfExpiredTime {
        NSMutableIndexSet *allRequestIndexSet = [NSMutableIndexSet indexSet];
        NSMutableIndexSet *readyIndexSet = [NSMutableIndexSet indexSet];
        NSMutableArray *allRequestResources = [[VoipUtils getResource:ALL_RESOURCE_WITHIN_TIME_PLIST] mutableCopy];
        NSMutableArray *allReadyResources = [[VoipUtils getResource:READY_RESOURCE_PLIST] mutableCopy];
        [self countTheExceedIndexsetInArray:allRequestResources withMuIndexSet:allRequestIndexSet];
        NSArray *deleteIndexArray = [allRequestResources objectsAtIndexes:allRequestIndexSet];
        [self countSameIndexsetFromArray:deleteIndexArray inArray:allReadyResources withMuIndexSet:readyIndexSet];
        [allRequestResources removeObjectsAtIndexes:allRequestIndexSet];
        [allReadyResources removeObjectsAtIndexes:readyIndexSet];
        [allRequestResources writeToFile:[VoipUtils pathForResoucePlist:ALL_RESOURCE_WITHIN_TIME_PLIST] atomically:YES];
        [allReadyResources writeToFile:[VoipUtils pathForResoucePlist:READY_RESOURCE_PLIST] atomically:YES];
}

+(void)countSameIndexsetFromArray:(NSArray *)fromArray inArray:(NSArray *)inArray withMuIndexSet:(NSMutableIndexSet *)IndexSet {
    for (NSDictionary *deleteDic in fromArray) {
        NSString *dest = deleteDic[@"dest"];
        NSString *deleteDestPath = [NSString stringWithFormat:@"%@/%@/%@", Commercial,ADResource,dest];
        NSString *absDeleteDesPath = [FileUtils getAbsoluteFilePath:deleteDestPath];
        if(![FileUtils checkFileExist:deleteDestPath] || [FileUtils removeFileInAbsolutePath:absDeleteDesPath]){
            for (NSDictionary *exceedDic in inArray) {
                if ([exceedDic[@"dest"] isEqualToString:dest]) {
                    [IndexSet addIndex:[inArray indexOfObject:exceedDic]];
                }
            }
        }
    }
}

+(void)countTheExceedIndexsetInArray:(NSArray *)array withMuIndexSet:(NSMutableIndexSet *)indexSet {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSTimeInterval time = [zone secondsFromGMTForDate:date];
    NSDate *dateNow = [date dateByAddingTimeInterval:time];
    for (NSDictionary *allRequestResourcesDic in array) {
        if ([allRequestResourcesDic.allKeys containsObject:@"used"]){
            NSString *usedTimeString = allRequestResourcesDic[@"used"];
            NSDate *usedDate = [DateTimeUtil dateByFormat:@"yyyy-MM-dd HH:mm:ss" fromString:usedTimeString];
            NSTimeInterval exceedTimeInterval = [dateNow timeIntervalSinceDate:usedDate];
            cootek_log(@"%d",exceedTimeInterval);
            if (exceedTimeInterval > PlastResourceExpiredSecond) {
                [indexSet addIndex:[array indexOfObject:allRequestResourcesDic]];
            }
        }else{
            [indexSet addIndex:[array indexOfObject:allRequestResourcesDic]];
        }
    }
}

+(void)copyNotNilReadyPlistToNilAllResourcePlistWhenUpdate {
    NSMutableArray *allRequestResources = [[VoipUtils getResource:ALL_RESOURCE_WITHIN_TIME_PLIST] mutableCopy];
    NSMutableArray *allReadyResources = [[VoipUtils getResource:READY_RESOURCE_PLIST] mutableCopy];
    if (allRequestResources.count!=0 || allReadyResources.count==0) {
        return;
    }
    [self writeUsedTimeToReadyResourcePlistWithArray:allReadyResources];
}

+ (NSString *) stringifyReachabilityNetworkType:(ClientNetworkType)networkType {
    NSString *typeString = @"none";
    switch (networkType) {
        case network_2g: {
            typeString = @"2g";
            break;
        }
        case network_3g: {
            typeString = @"3g";
            break;
        }
        case network_4g: {
            typeString = @"4g";
            break;
        }
        case network_lte: {
            typeString = @"lte";
            break;
        }
        case network_wifi: {
            typeString = @"wifi";
            break;
        }
        default:
            break;
    }
    return typeString;
}
+ (void)setDicInUserManageWithObject:(NSObject *)object withObjectKey:(NSString *)objectKey withDicKey:(NSString *)Dickey {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[UserDefaultsManager dictionaryForKey:Dickey]];
    [dic setValue:object forKey:objectKey];
    [UserDefaultsManager setObject:dic forKey:Dickey];
}


+ (BOOL)is64bit {
#if defined(__LP64__) && __LP64__
    return YES;
#else
    return NO;
#endif
}

+ (BOOL)is64bitAndIOS10 {
    return ([self is64bit] &&[UIDevice currentDevice].systemVersion.floatValue >= 10);
}

+ (void) pushHandlerWebControllerWithUrlString:(NSString *)rawUrl andTitle:(NSString *)title needToken:(BOOL)needToken {
    NSMutableString *url = [[NSMutableString alloc] initWithString:rawUrl];
    if (![url hasSuffix:@"?"]) {
        [url appendString:@"?"];
    }
    if (needToken) {
        [url appendFormat:@"_token=%@", [SeattleFeatureExecutor getToken]];
    }
    NSString *location = [LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY];
    if (![NSString isNilOrEmpty:location]) {
        [url appendFormat:@"_city=%@", location];
    }
    HandlerWebViewController *vipWebViewVC = [[HandlerWebViewController alloc]init];
    vipWebViewVC.url_string =[url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    vipWebViewVC.header_title = title;
    cootek_log(@"url_string= %@, head_title= %@", vipWebViewVC.url_string, vipWebViewVC.header_title);
    [[TouchPalDialerAppDelegate naviController] pushViewController:vipWebViewVC animated:YES];
}

    
+ (BOOL)CheckIfExistInBindSuccessListarrayWithPhone:(NSString *)phone {
    NSArray *array = [AllViewController getNumberArrarFromBindsuccessListArray];
    NSString *normalizeString = [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:phone];
    return  [array containsObject:normalizeString];
}
+ (BOOL)CheckIfExistInBindSuccessListarrayWithPhoneArray:(NSArray *)phoneArray {
    for (NSString *phone in phoneArray) {
        NSString *normalizeString = [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:phone];
        if ([self CheckIfExistInBindSuccessListarrayWithPhone:normalizeString]==YES) {
            return YES;
        }
    }
    return NO;
}

+ (NSInteger)getCountInBindSuccessListarray {
    NSArray *array = [AllViewController getNumberArrarFromBindsuccessListArray];
    return  array.count;
}

@end
