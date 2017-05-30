//
//  CTUrl.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-10.
//
//

@interface CTUrl : NSObject<NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic, retain) NSString* url;
@property(nonatomic, retain) NSString* localUrl;
@property(nonatomic, retain) NSString* controller;
@property(nonatomic, retain) NSString* params;
@property(nonatomic, retain) NSArray* nativeParams;
@property(nonatomic, assign) BOOL needWrap;
@property(nonatomic, assign) BOOL needLogin;
@property(nonatomic, assign) BOOL needSign;
@property(nonatomic, assign) BOOL external;
@property(nonatomic, retain) NSString* titleBar;
@property(nonatomic, assign) BOOL navigateBar;
@property(nonatomic, retain) NSString* quitAlert;
@property(nonatomic, retain) NSString* serviceId;
@property(nonatomic, assign) BOOL newWebView;
@property(nonatomic, assign) BOOL isPost;
@property(nonatomic, assign) BOOL fullScreen;
@property(nonatomic, assign) BOOL landscape;
@property(nonatomic, assign) BOOL backConfirm;
@property(nonatomic, assign) BOOL showFloatingPoint;
@property(nonatomic, assign) BOOL sendToDeskTop;
@property(nonatomic, retain) NSString* shortCutTitle;
@property(nonatomic, retain) NSString* shortCutIcon;
@property(nonatomic, retain) NSDictionary *nativeUrl;
@property(nonatomic, assign) BOOL needTitle;
@property(nonatomic, assign) BOOL loadLocalJs;
@property(nonatomic, assign) BOOL allowsInlineMediaPlayback;
@property(nonatomic, assign) BOOL queryFeedsRedPacket;
@property(nonatomic, assign) BOOL needFontSizeSettings;
@property(nonatomic, assign) BOOL isNews;

- (id) initWithUrl:(NSString *)url;
- (id) initWithJson:(NSDictionary *)json;
- (id) initBeyondYellowPageWithUrl:(NSString *)url andLocalUrl:(NSString *) localUrl andController:(NSString *)controller andParams:(NSString *) params andNativeParams:(NSArray *) nativeParams andNeedWrap:(BOOL) needWrap andNeedLogin:(BOOL) needLogin andNeedSign:(BOOL) needSign andExternal:(BOOL) external andTitleBar:(NSString *) titleBar andQuitAlert:(NSString *) quitAlert;
- (UIViewController *) startWebView;
- (BOOL) isValid;
- (void) addOtherParams;
- (NSDictionary*)jsonFromCTUrl;
+ (NSString *)encodeUrl:(NSString*)url;
+ (NSString *)encodeRequestUrl:(NSString*)url;
+ (NSString *) signWithUrl:(NSString *)url andNeedLogin:(BOOL)needLogin andTS:(NSTimeInterval) interval;

- (NSString *) urlWrapper;
@end
