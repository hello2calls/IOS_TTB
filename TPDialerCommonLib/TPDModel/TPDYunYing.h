//
//  TPDYunYing.h
//  TouchPalDialer
//
//  Created by weyl on 16/12/22.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    YunYinPositionServiceNum = 901, // 服务号运营位
    YunYinPositionCallLog = 902, // 通话记录运营位
    YunYinPositionDuringCall = 903,  // 通话中运营位
    YunYinPositionNotificationBar = 904,  // 通知栏运营位
    YunYinPositionInApp = 905,   // InApp运营位
} YunYinPosition;

@interface TPDYunYingReserve : NSObject
@property (nonatomic,strong) NSString* target;
@property (nonatomic) BOOL hasClose;
@property (nonatomic) BOOL hasArrow;
@property (nonatomic,strong) NSString* button1;
@property (nonatomic,strong) NSString* url1;
@property (nonatomic,strong) NSString* icon;
@property (nonatomic,strong) NSString* button2;
@property (nonatomic,strong) NSString* url2;
@property (nonatomic,strong) NSString* url;
@property (nonatomic) NSInteger btnCount;
@property (nonatomic) NSInteger duration;
@property (nonatomic) NSInteger start;
@property (nonatomic) BOOL needWrap;

@end

@interface TPDYunYingItem : NSObject
@property (nonatomic,strong) NSString* edurl;
@property (nonatomic,strong) TPDYunYingReserve* reserved;
@property (nonatomic,strong) NSString* clk_url;
@property (nonatomic) BOOL is_deeplink;
@property (nonatomic) BOOL ec;

@property (nonatomic,strong) NSString* surl;
@property (nonatomic,strong) NSString* at;
@property (nonatomic,strong) NSString* curl;
@property (nonatomic,strong) NSString* checkcode;
@property (nonatomic,strong) NSString* title;
@property (nonatomic) NSInteger etime;
@property (nonatomic,strong) NSString* app_package;
@property (nonatomic,strong) NSString* ttype;
@property (nonatomic,strong) NSString* icon;
@property (nonatomic) NSInteger dtime;
@property (nonatomic,strong) NSString* ad_id;
@property (nonatomic,strong) NSArray* transform_monitor_url;
@property (nonatomic,strong) NSString* rdesc;
@property (nonatomic,strong) NSString* tracking_url;
@property (nonatomic,strong) NSString* tstep;
@property (nonatomic,strong) NSArray* ed_monitor_url;
@property (nonatomic) NSInteger h;
@property (nonatomic) NSInteger w;
@property (nonatomic) NSInteger interaction_type;
@property (nonatomic,strong) NSString* src;
@property (nonatomic,strong) NSString* desc;
@property (nonatomic,strong) NSString* turl;
@property (nonatomic,strong) NSString* material;
@end




@interface TPDYunYingRequestParam : NSObject
@property (nonatomic,strong) NSString* ch;
@property (nonatomic,strong) NSString* v;
@property (nonatomic) NSInteger prt;
@property (nonatomic,strong) NSString* at;
@property (nonatomic,strong) NSString* tu;
@property (nonatomic) NSInteger adn;
@property (nonatomic,strong) NSString* adclass;
@property (nonatomic,strong) NSString* nt;
@property (nonatomic,strong) NSString* rt;
@property (nonatomic) NSInteger w;
@property (nonatomic) NSInteger h;
@property (nonatomic,strong) NSString* city;
@property (nonatomic,strong) NSString* addr;
@property (nonatomic) double longtitude;
@property (nonatomic) double latitude;
@property (nonatomic,strong) NSString* other_phone;
@property (nonatomic,strong) NSString* call_type;
@property (nonatomic,strong) NSString* vt;
@property (nonatomic) NSInteger ito;
@property (nonatomic) NSInteger et;
@property (nonatomic) double open_free_call;
@property (nonatomic,strong) NSString* contactname;
@property (nonatomic,strong) NSString* ck;
@property (nonatomic) NSInteger pf;

@property (nonatomic,strong) NSString* token;
@property (nonatomic,strong) NSString* ip;

@end

@interface TPDYunYing : NSObject


+(TPDYunYingRequestParam*)defaultParam;

+(TPDYunYingItem*)getYunYingByPosition:(YunYinPosition)position;
@end
