//
//  SectionMiniBanner.h
//  TouchPalDialer
//
//  Created by tanglin on 16/1/20.
//
//

#import "SectionBase.h"

@interface SectionMiniBanner : SectionBase

@property(nonatomic, strong)NSString* tabGuideIcon;
-(id)initWithJson:(NSDictionary *)json;
@end
