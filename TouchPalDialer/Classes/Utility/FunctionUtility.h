//
//  FunctionUtility.h
//  TouchPalDialer
//
//  Created by zhang Owen on 8/22/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "consts.h"
#import "FLWebViewProvider.h"
#import "Reachability.h"

#define PERSON_DEFAULT_COLOR_TYPES (2)

#define davinciADMaxTime 3
#define PlastResourceExpiredSecond        (7*24*60*60)
@interface FunctionUtility : NSObject

+ (UIImage*)getImageFromColorRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue size:(CGSize)size;
+ (NSString *)getLocalShortTimeString:(NSTimeInterval)intervalFrom1970;
+ (NSString *)dateString:(NSTimeInterval)time;
//获取时间的字符串
+ (NSString *)getSystemFormatDateString:(NSTimeInterval)time;
+ (NSString *)getTimeString:(NSInteger)seconds;
+ (NSString *)getSystemFormatDateString:(NSTimeInterval)time dateOnly:(BOOL)dateOnly timeOnly:(BOOL)timeOnly;
+ (NSString *)getWeekdayDescription:(NSInteger)weekday;

+ (BOOL)isNilOrEmptyString:(NSString*)string;

+ (UIImage *)createRoundedRectImage:(UIImage*)image withSize:(CGSize)size;
+ (BOOL)isMoreThanOneDay:(int)newTime oldTime:(int)oldTime;
//resize
+ (UIImage *)imageWithResize:(UIImage *)image scaledToSize:(CGSize)newSize ;
//rect
+ (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)rect;
+ (UIImage *)imageWithColor:(UIColor *)color;
//圆
+ (UIImage *)imageWithColor:(UIColor *)color withOval:(CGRect)rect;
+ (UIImage *)circleImageWithColor:(UIColor *)color withOval:(CGRect)rect;
+ (UIImage*)getImageFromUIColor:(UIColor *)color andFrame:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)rect withBoardColor:(UIColor *)boardColor andBoardWidth:(int)width;
+ (UIImage*) getGradientImageFromStartColor:(UIColor*)startColor endColor:(UIColor*)endColor forSize:(CGSize) size ;
+ (UIImage *)captureImage:(UIImage *)sourceImage;

//for some string that may be different after a short time period, for example the number in PhoneNumberInputView
+ (BOOL)string:(NSString *)string1 sharesSuffixWithString:(NSString *)string2 suffixLength:(int)suffixLength;

+ (NSString *)getYellowPublicNumberPath;

+ (float)imageScale;

+ (void)image:(UIImage *)image drawInRect:(CGRect)rect;

+ (BOOL)is3x;

+ (BOOL)isPageActive:(NSString *)pageName;

+ (BOOL)isTimeUpForEvent:(NSString *)event withSchedule:(double)schedule firstTimeCount:(BOOL)firstTimeCount persistCheck:(BOOL)persist;

+ (NSString*)documentFile:(NSString*)file;

+ (NSString *)getRemoteTxtContent:(NSString *)url;

+ (NSDictionary *)getDictionaryFromJsonString:(NSString *)string;

+ (NSData *)getRemoteData:(NSString *)url;

+ (void) asyncVisitUrl:(NSString *)url;

+ (void)visitUrl:(NSString *)url;

+ (void)visitUrl:(NSString *)url param:(NSDictionary *)param; // param for HTTP GET method

+ (NSString *)generateUUID;
+ (NSString *)GetUUID;

+ (void)shortenUrl:(NSString*)url andBlock:(void (^)(NSString *url))block;

+ (BOOL)isCurrentBetweenDate:(NSString *)date1 andDate:(NSString *)date2;

+ (NSString*)networkType;

+ (NSString*) deviceName;

+ (NSString*) generateWechatMessage:(NSString *)tempId andFrom:(NSString *)from;

+ (NSString*) generateUrlMessage:(NSString *)url andTemptId:(NSString *)tempId andFrom:(NSString *)from;

+ (NSString *)getTagString:(NSString *)tag inString:(NSString *)string;

+ (void)screenShot:(UIView*)view name:(NSString *)name;

+ (UIImage *)addTwoImageToOne:(UIImage *)oneImg
                     twoImage:(UIImage *)twoImg
                    xposition:(NSInteger)xpos
                    yposition:(NSInteger)ypos;

+ (UIImage *)addLabelToImage:(UIImage *)image
                    andTitle:(NSString *)title
                     andRect:(CGRect)titleRect
                     andFont:(UIFont *)titleFont
                    andColor:(UIColor *)textColor;

+ (NSString *)currentWifiBase;

+ (NSString*)saveImage:(NSData*)imageData withImageName:(NSString*)imageName;

+ (BOOL)isInChina;

+ (BOOL)removeDocumentFile:(NSString *)path;

+ (NSString *)simpleEncodeForString:(NSString *)string;

+ (NSString *)simpleDecodeForString:(NSString *)string;

+ (void)writeDefaultKeyToDefaults:(NSString *)name andObject:(id)object andKey:(NSString *)key;

+ (id)readDataFromNSUserDefaults:(NSString *)name andKey:(NSString *)key;

+ (void)shareSMS:(NSString *)smsUrl andNeedDefault:(BOOL)needDefault andMessage:(NSString *)msg andNumber:(NSString *)phoneNumber andFromWhere:(NSString *)fromWhere;

+ (void)sharePasteboard:(NSString *)smsUrl andNeedDefault:(BOOL)needDefault andFromWhere:(NSString *)fromWhere title:(NSString *)title;

+ (void)shareByWeixin:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andResultCallback:(id)resultCallback;

+ (void)shareByWeixinTimeline:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andResultCallback:(id)resultCallback;

+ (void)shareByWeixinImage:(UIImage *)image andFromWhere:(NSString *)fromWhere andIfTimeLine:(BOOL)TimeLine;

+ (void)shareByQQ:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andResultCallback:(id)resultCallback;

+ (void)shareByQQZone:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andResultCallback:(id)resultCallback;

+ (void)shareByWeixinImageByImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere andIfTimeLine:(BOOL)timeline;

+ (void)shareTextByWeixin:(NSString *)text andThumbImage:(UIImage *)image andSuccesBlock:(void (^)())block;

+ (UIViewController *)openUrl:(NSString *)url withTitle:(NSString *)title;

+ (NSString *)getIpAddress;

+ (BOOL)judgeContactAccessFail;

+ (UILabel *)labelNoBgWithRect:(CGRect)frame font:(UIFont *)font align:(NSTextAlignment)align textColor:(UIColor *)textColor andText:(NSString *)text;

+ (void)setAppHeaderStyle;

+ (void)removeFromStackViewController:(UIViewController *)controller;

+ (void)executeJavaScript:(UIView<FLWebViewProvider> *)webview withScript:(NSString* )script;

+ (void)downloadImage:(NSString *)imageUrl usingBlock:(void(^)(UIImage *image)) block;
+ (float)systemVersionFloat;

+ (BOOL)checkIfNot138testNumber;
+ (BOOL)judgeTimeAfterNatureDayWithID:(NSString *)ID;

+(void)popToRootViewWithIndex:(NSInteger)index;
+(BOOL)arc4randomIfmMorePersent:(NSInteger)persent;
+(void)popViewController;

/**
 *  get a black-white image by QRencoding a string
 *
 *  @param qrstring the string will be encoded
 *  @param size     the size of the image
 *
 *  @return a black-white image if possible
 */
+ (UIImage *) getQRImageFromString:(NSString *) qrstring withSize:(CGSize) size;

/**
 *  set the status bar style according to the default skin
 *
 *  @return none
 */
+ (void) setStatusBarStyleByDefaultSkin;
+ (void) updateStatusBarStyle;
+ (void) setStatusBarStyleToDefault:(BOOL)isDefault;

// for debug views
+ (void) setBorderForView:(UIView *)view color:(UIColor *)borderColor width:(CGFloat)borderWidth;
+ (void) setBorderForView:(UIView *)view colorStyle:(NSString *)borderStyle width:(CGFloat)borderWidth;
+ (void) setBorderForView:(UIView *)view width:(CGFloat)borderWidth;
+ (void) setBorderForView:(UIView *)view colorStyle:(NSString *)colorStyle;
+ (void) setBorderForView:(UIView *)view color:(UIColor *)color;
+ (void) setBorderForView:(UIView *)view;
+ (void) setBorderForViewArray:(NSArray *)views;

+ (void) verticallyCenterView:(UIView *)subview inParentView:(UIView *)parentView;
+ (void) verticallyCenterView:(UIView *)subview inParentHeight:(CGFloat)parentHeight;
+ (void) verticallyCenterViewArray:(NSArray *)subviews inParentHeight:(CGFloat)parentHeight;

+ (void) horizontallyCenterView:(UIView *)subview inParentView:(UIView *)parentView;
+ (void) horizontallyCenterView:(UIView *)subview inParentWidth:(CGFloat)parentWidth;
+ (void) horizontallyCenterViewArray:(NSArray *)subviews inParentWidth:(CGFloat)parentWidth;

+ (void) setX:(CGFloat)newX forView:(UIView *)view;
+ (void) setY:(CGFloat)newY forView:(UIView *)view;
+ (void) setOrigin:(CGPoint)newOrigin forView:(UIView *)view;

+ (void) setXOffset:(CGFloat)dx forView:(UIView *)view;
+ (void) setYOffset:(CGFloat)dy forView:(UIView *)view;

+ (void) setWidth:(CGFloat)newWidth forView:(UIView *)view;
+ (void) setHeight:(CGFloat)newHeight forView:(UIView *)view;
+ (void) setSize:(CGSize)newSize forView:(UIView *)view;

+ (void) setWidthOffset:(CGFloat)widthOffset forView:(UIView *)view;
+ (void) setHeightOffset:(CGFloat)heightOffset forView:(UIView *)view;

+ (UIColor *) getPersonDefaultColorByPersonId:(NSInteger)personId;
+ (UIColor *) getBgColorOfLongPressView;
+(NSDictionary *)getADViewSizeWithTu:(NSString *)tu;

+(id)recodeTransWithdic:(NSDictionary *)dic;
+(id)recodeTransWithErrorcode:(NSString *)error_code  dic:(NSDictionary *)dic;
+ (NSString *) getWebViewUserAgent;
+ (void)asyncWithUAVisitUrl:(NSString *)url tryTime:(NSUInteger)time;
+ (void)setStatusBarHidden:(BOOL)hidden;
+ (void)saveLogInDebugToDocFile:(NSString *)filepath withLog:(NSObject *)log;
+ (void)writeUsedTimeToReadyResourcePlistWithArray:(NSArray *)array;
+ (void)deleteFileAndPlistIfExpiredTime;
+(void)copyNotNilReadyPlistToNilAllResourcePlistWhenUpdate;

// send info
+ (void) sendEmailToAddress:(NSString *)emailAddress andSubject:(NSString *)subject withHeader:(NSString *)emailHeader withBody:(NSString *)emailbody;

// networktype string
+ (NSString *) stringifyReachabilityNetworkType:(ClientNetworkType)networkType;
+ (void)setDicInUserManageWithObject:(NSObject *)object withObjectKey:(NSString *)objectKey withDicKey:(NSString *)Dickey;

+ (BOOL)is64bit;
+ (BOOL)is64bitAndIOS10;


+ (void) pushHandlerWebControllerWithUrlString:(NSString *)urlString andTitle:(NSString *)title needToken:(BOOL)needToken;
+ (BOOL)CheckIfExistInBindSuccessListarrayWithPhone:(NSString *)phone;
+ (BOOL)CheckIfExistInBindSuccessListarrayWithPhoneArray:(NSArray *)phoneArray;
+ (NSInteger)getCountInBindSuccessListarray;
@end
