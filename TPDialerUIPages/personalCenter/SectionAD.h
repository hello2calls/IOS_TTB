//
//  SectionAD.h
//  TouchPalDialer
//
//  Created by siyi on 16/9/26.
//
//

#ifndef SectionAD_h
#define SectionAD_h


#import <Foundation/Foundation.h>
#import "SectionBase.h"

@interface SectionAD : SectionBase

@property (nonatomic, assign, readwrite) int sectionIndex;
@property (nonatomic, strong, readwrite) NSString *sectionType;

- (instancetype) initWithJson:(NSDictionary *)json;
- (instancetype) initWithJson:(NSDictionary *)json sectionIndex:(int)sectionIndex sectionType:(NSString *)sectionType;

+ (instancetype) localSettingSection;

@end

#endif /* SectionAD_h */
