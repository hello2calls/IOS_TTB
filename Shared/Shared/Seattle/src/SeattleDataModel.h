//
//  SeattleDataModel.h
//  CallerInfoShow
//
//  Created by Elfe Xu on 13-1-31.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface StatisticInfo : NSObject

@property (nonatomic, retain) NSNumber *totalCallerId;
@property (nonatomic, retain) NSNumber *recentlyCallerId;
@property (nonatomic, retain) NSNumber *recogCallerId;
@property (nonatomic, retain) NSNumber *userContribute;

@end

@interface CloudBlackItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, assign) BOOL isContact;

@end

@interface BaseShopInfo : NSObject

@property (nonatomic, retain) NSNumber *shopId;
@property (nonatomic, copy) NSString *googleMapUrl;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, retain) NSNumber *distance;

@end

@interface FullShopInfo : BaseShopInfo

@property (nonatomic, copy) NSString *address;
//@property(nonatomic,copy)  NSString *logo;
//@property(nonatomic,copy)  NSString *description;

@end

@interface SurveyInfo : NSObject

@property (nonatomic, copy) NSString *systemTag;
@property (nonatomic, copy) NSString *systemName;

@end

@interface CloudCallerIdInfo : NSObject

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, assign) BOOL isVerified;
@property (nonatomic, copy) NSString *classifyType;
@property (nonatomic, copy) NSString *shopName;
@property (nonatomic, copy) NSString *areaCode;
@property (nonatomic, retain) NSNumber *markCount;
@property (nonatomic, retain) SurveyInfo *survey;

@end

@interface DetailLocation : NSObject

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D location;

@end

@interface CloudVersionInfo : NSObject

@property(nonatomic,assign)NSInteger version;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *description_en_us;
@property(nonatomic,copy)NSString *description_zh_cn;
@property(nonatomic,copy)NSString *description_zh_tw;

@end

@interface CloudPackageInfo : NSObject

@property(nonatomic,copy)NSString *cityID;
@property(nonatomic,copy)NSString *cityName;
@property(nonatomic,copy)NSString *mainVersion;
@property(nonatomic,copy)NSString *mainPath;
@property(nonatomic,assign)NSInteger mainSize;
@property(nonatomic,copy)NSString *updateVersion;
@property(nonatomic,copy)NSString *updatePath;
@property(nonatomic,assign)NSInteger updateSize;

@end

@interface CloudCallLogItem : NSObject <NSCoding>
@property(nonatomic,copy)NSString *otherPhone;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,assign)BOOL isContact;
@property(nonatomic,assign)long date;
@property(nonatomic,assign)long duration;
@property(nonatomic,assign)long ringTime;
@end