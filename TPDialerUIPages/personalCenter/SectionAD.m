//
//  SectionAD.m
//  TouchPalDialer
//
//  Created by siyi on 16/9/26.
//
//

#import "SectionAD.h"
#import "YPAdItem.h"
#import "IndexData.h"

@implementation SectionAD 
- (instancetype) initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self) {
        NSArray *ads = [json objectForKey:SECTION_TYPE_V6_SECTIONS];
        for(int i = 0, len = ads.count; i < len; i++) {
            YPAdItem *item = [[YPAdItem alloc] initWithJson:ads[i]];
            [self.items addObject:item];
        }
    }
    return self;
}

- (instancetype) initWithJson:(NSDictionary *)json sectionIndex:(int)sectionIndex sectionType:(NSString *)sectionType {
    _sectionIndex = sectionIndex;
    _sectionType = sectionType;
    self = [self initWithJson:json];
    return self;
}

+ (instancetype) localSettingSection {
    SectionAD *localSection =  [[SectionAD alloc] init];
    if (localSection != nil) {
        [localSection.items addObject:[YPAdItem localAntiharassItem]];
        [localSection.items addObject:[YPAdItem localSettingItem]];
        localSection.sectionIndex = SECTION_TYPE_TPD_LOCAL_SETTINGS_INDEX;
        localSection.sectionType = SECTION_TYPE_LOCAL_SETTINGS;
    }
    return localSection;
}

@end
