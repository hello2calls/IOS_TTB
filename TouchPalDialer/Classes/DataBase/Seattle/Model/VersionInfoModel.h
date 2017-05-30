//
//  VersionInfoModel.h
//  TouchPalDialer
//
//  Created by lingmei xie on 12-10-15.
//
//

#import <Foundation/Foundation.h>

@interface VersionInfoModel : NSObject
@property(nonatomic,assign)NSInteger version;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *description_en_us;
@property(nonatomic,copy)NSString *description_zh_cn;
@property(nonatomic,copy)NSString *description_zh_tw;
@end
