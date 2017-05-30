//
//  YPAdTaskNews.h
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "YPTaskBase.h"

@interface YPAdTaskNews : YPTaskBase

@property(assign, setter=setRefresh:)BOOL isRefresh;
@property(assign, setter=setTu:)NSInteger tu;
@property (nonatomic, assign) NSInteger layout;

+ (NSString *) requestURLStringWithExtra:(NSDictionary *)extra;
@end
