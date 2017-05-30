//
//  GlobalStrategy.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/25.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSInteger{
    NCWifi_First = 4,
    NCMobile = 2,
    NCAny = 3,
    NCWifi = 1,
}NetworkConnection;

typedef enum : NSInteger{
    UCSameAsCheck = 0,
    UCWifi,
    UCMobile,
    UCAny,
    UCWifi_First,
}UploadConnection;

@interface GlobalStrategy : NSObject

@property (nonatomic, assign) NetworkConnection connection;
@property (nonatomic, assign) float checkInterval;
@property (nonatomic, assign) int toolbarQuietDays;
@property (nonatomic, assign) int statusbarQuietDays;
@property (nonatomic, assign) int startupQuietDays;
@property (nonatomic, assign) UploadConnection uploadConnection;
@property (nonatomic, assign) float uploadInterval;

- (id)initWithDictonary:(NSDictionary *) dict;

@end
