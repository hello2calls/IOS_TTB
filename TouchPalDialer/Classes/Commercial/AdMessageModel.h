//
//  AdMessageModel.h
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/7.
//
//

#import <Foundation/Foundation.h>

#define kAD_TU_HANGUP  @"1"
#define kAD_TU_CALLING @"4"
#define kAD_TU_VOIP_PRIVILEGE @"21"
#define kAD_TU_LAUNCH @"26"
#define kAD_TU_BACKCALL @"32"
#define kAD_TU_BACKCALLHANG @"33"
#define kAD_TU_CALL_POPUP_HTML @"36"
#define kAD_TU_NUMPAD_HTML @"40"


////////////////   AD Transform
#define kADTransformUrl             @"http://ws2.cootekservice.com/ad/transform"
#define kADTransformShowTime        @"5"
#define kADTransformLandingPage     @"1"
#define kADTransformParamType       @"type"
#define kADTransformParamUrl        @"url"
#define kADTransformParamSid        @"s"
#define kADTransformParamTsin       @"tsin"
#define kADTransformParamTsout      @"tsout"
#define kADTransformParamTU         @"tu"
#define kADTransformParamCloseType  @"closetype"



#define kADTransformParamBlts       @"blts"
#define kADTransformParamFlts       @"flts"
#define kADTransformParamAdid       @"adid"
#define kADTransformParamCtid       @"ctid"


@class udp_response_tData;
@interface AdMessageModel : NSObject
@property (nonatomic, copy)NSString *adId;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *desc;
@property (nonatomic, copy)NSString *brand;
@property (nonatomic, copy)NSString *curl; //click to jump url, even if click to open local page
@property (nonatomic, copy)NSString *surl; //
@property (nonatomic, copy)NSString *edurl; //after successly show the ad, request the edurl, need token
@property (nonatomic, copy)NSString *material;
@property (nonatomic, copy)NSString *src; //the source of the commercial
@property (nonatomic, copy)NSString *at;
@property (nonatomic, assign)double w;
@property (nonatomic, assign)double h;
@property (nonatomic, copy)NSString *s;
@property (nonatomic, copy)NSString *tu;
@property (nonatomic, copy)NSString *turl;
@property (nonatomic, copy)NSString *ttype;
@property (nonatomic, copy)NSString *tstep;
@property (nonatomic, copy)NSString *rdesc;
@property (nonatomic, copy)NSString *checkcode;
@property (nonatomic, copy)NSString *reserved;
@property (nonatomic, assign) BOOL da; // direct ad, i.e. directly open the curl
@property (nonatomic, assign) BOOL ec; // enable click 


@property (nonatomic, assign) long long dtime; // time for displaying the ad
@property (nonatomic, assign) long long etime;  // time for this ad to be valid
@property (nonatomic, assign) long long expireTimestamp; //

@property (nonatomic, copy) NSString *orginalADJSONString; // single ad json string item
@property (nonatomic, copy) NSString *rawResponseString; // string from the http reposonse body
@property (nonatomic, copy) NSString *clk_url;
@property (nonatomic, retain)NSMutableArray<NSString *> *clk_monitor_url;
@property (nonatomic, retain)NSMutableArray<NSString *> *ed_monitor_url;

// properties of ad package
@property (nonatomic, assign) BOOL idws; // should show the white splash screen
@property (nonatomic, assign) long long wtime; // time for fetching the ad

- (instancetype)initWithUdpResponseData:(udp_response_tData *)data tu:(NSString *)tu;
- (NSDictionary *)reservedDict;
- (NSString *)jumpURL;
- (NSString *) toJSONString;
@end
