//
//  SettingPageModel.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SettingPageModel.h"

@implementation SettingPageModel

@synthesize pageType;
@synthesize title;
@synthesize sections;
@synthesize monitorKeys;
@synthesize settings;

+(SettingPageModel*) pageWithTitle:(NSString*) title sections:(NSArray*)sections type:(SettingPageType)pageType settings:(AppSettingsModel*)settings{
    SettingPageModel* page = [[SettingPageModel alloc] init];
    page.pageType = pageType;
    page.title = title;
    page.sections = sections;
    page.settings = settings;
    NSMutableArray* keys = [[NSMutableArray alloc] init];
    for(SettingSectionModel* section in sections) {
        [keys addObjectsFromArray:section.monitorKeys];
    }
    page.monitorKeys = keys;
    return page;
}

-(void) save {
    [settings saveToFile];
}

@end

@implementation SettingSectionModel

@synthesize title;
@synthesize items;
@synthesize monitorKeys;

+(SettingSectionModel*) sectionWithTitle:(NSString*) title items:(NSArray*)items {
    SettingSectionModel* section = [[SettingSectionModel alloc] init];
    section.title = title;
    section.items = items;
    NSMutableArray* keys = [[NSMutableArray alloc] init];
    for(SettingItemModel* item in items) {
        if ([item isKindOfClass:[SettingItemModel class]]) {
            if([item respondsToSelector:@selector(monitorKey)] &&
               item.monitorKey != nil &&
               item.monitorKey.length > 0)  {
                [keys addObject:item.monitorKey];
            }
        }
    }
    section.monitorKeys = keys;
    return section;
}


+(SettingSectionModel*) sectionWithItems:(NSArray*) items {
    return [SettingSectionModel sectionWithTitle:nil items:items];
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end

