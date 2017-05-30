//
//  SectionFullScreenAd.h
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 16/2/3.
//
//

#ifndef SectionFullScreenAd_h
#define SectionFullScreenAd_h
#import "SectionBase.h"

@interface SectionFullScreenAd : SectionBase

@property (nonatomic, strong)NSString *tabGuideIcon;
- (id)initWithJson:(NSDictionary *)json;

@end

#endif /* SectionFullScreenAd_h */
