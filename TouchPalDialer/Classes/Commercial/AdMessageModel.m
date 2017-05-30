//
//  AdMessageModel.m
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/7.
//
//

#import "AdMessageModel.h"
#import "Ad.pb.h"
#import "NSString+TPHandleNil.h"

#define AD_PREFIX_FEATURE @"feature"
#define AD_PREFIX_SHARE @"share"
#define AD_PREFIX_YELLOWPAGE @"yellowpage"
#define AD_PREFIX_JUMPWEB @"jumpweb"
#define AD_PREFIX_DOWNLOAD @"download"

#define RESERVED_TARGET @"target"
#define RESERVED_ICON @"icon"
#define RESERVED_TARGET_CLASS @"className_iOS"

#define SRC_LOCAL @"ct"
#define SRC_COMMERCIAL @"ct_com"


@implementation AdMessageModel {
    NSDictionary *_reservedDict;
}

-(NSMutableArray<NSString *> *)clk_monitor_url{
    if (!_clk_monitor_url) {
        _clk_monitor_url = [NSMutableArray arrayWithCapacity:0];
    }
    return _clk_monitor_url;
}

-(NSMutableArray<NSString *> *)ed_monitor_url{
    if (!_ed_monitor_url) {
        _ed_monitor_url = [NSMutableArray arrayWithCapacity:0];
    }
    return _ed_monitor_url;
}

- (instancetype)initWithUdpResponseData:(udp_response_tData *)data tu:(NSString *)tu
{
    if (!data) {
        return nil;
    }

    self = [super init];

    if (self) {
        _adId = [@(data.adid)stringValue];
        _title = data.title;
        _desc = data.desc;
        _brand = data.brand;
        _curl = data.curl;
        _surl = nil;
        _edurl = data.edurl;
        _material = data.material;
        _src = nil;
        _at = nil;
        _w = 0;
        _h = 0;
        _s = data.sid;
        _tu = tu;
        _reserved = nil;
    }

    return self;
}

- (NSDictionary *)reservedDict {
    if (_reservedDict) {
        return _reservedDict;
    }
    if (_reserved && [_reserved rangeOfString:@"{"].length > 0) {
        _reservedDict = [NSJSONSerialization JSONObjectWithData:[_reserved dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        return _reservedDict;
    }
    return nil;
}

- (NSString *)jumpURL
{
    NSString *jumpUrl = nil;
    if ([_adId hasPrefix:AD_PREFIX_FEATURE]) {
        NSString *targetString = [[self reservedDict] objectForKey:RESERVED_TARGET];
        NSDictionary *target = [NSJSONSerialization JSONObjectWithData:[targetString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        jumpUrl = [target objectForKey:RESERVED_TARGET_CLASS];
    } else if ([_adId hasPrefix:AD_PREFIX_DOWNLOAD]) {
        if ([_src isEqualToString:SRC_LOCAL]) {
            jumpUrl = [[self reservedDict] objectForKey:RESERVED_TARGET];
        }
    } else if ([_adId hasPrefix:AD_PREFIX_JUMPWEB]) {
        if ([_src isEqualToString:SRC_LOCAL]) {
            jumpUrl = [[self reservedDict] objectForKey:RESERVED_TARGET];
        }
    }
    if (![jumpUrl isKindOfClass:[NSString class]] || jumpUrl.length == 0) {
        jumpUrl = nil;
        cootek_log(@"jump url can not be parsed from reserved");
    }
    return jumpUrl;
}

- (NSString *) toJSONString {
    NSDictionary *ad = @{
       @"ad_id": [NSString nilToEmpty:self.adId],
       @"title": [NSString nilToEmpty:self.title],
       @"desc": [NSString nilToEmpty:self.desc],
       @"src": [NSString nilToEmpty:self.src],
       @"edurl": [NSString nilToEmpty:self.edurl],
       @"curl": [NSString nilToEmpty:self.curl],
       @"material": [NSString nilToEmpty:self.material],
       @"at": [NSString nilToEmpty:self.at],
       @"w": @(self.w),
       @"h": @(self.h),
       @"surl": [NSString nilToEmpty:self.surl],
       @"brand": [NSString nilToEmpty:self.brand],
       @"turl": [NSString nilToEmpty:self.turl],
       @"ttype": [NSString nilToEmpty:self.ttype],
       @"tstep": [NSString nilToEmpty:self.tstep],
       @"rdesc": [NSString nilToEmpty:self.rdesc],
       @"reserved": [NSString nilToEmpty:self.reserved],
       @"checkcode": [NSString nilToEmpty:self.checkcode]
    };
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:ad options:kNilOptions error:&err];
    if (err) {
        return nil;
    } else {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}
@end
