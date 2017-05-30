//
//  IndexData.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-13.
//
//
#import "IndexData.h"
#import <Foundation/Foundation.h>
#import "SectionGroup.h"
#import "SectionRecommend.h"
#import "CategoryItem.h"
#import "SectionCategory.h"
#import "SectionSeparator.h"
#import "SectionBanner.h"
#import "SectionSearch.h"
#import "SectionFooter.h"
#import "SectionAnnouncement.h"
#import "SectionFavourite.h"
#import "IndexFilter.h"
#import "UserDefaultsManager.h"
#import "SectionNewCategory.h"
#import "SectionCoupon.h"
#import "UIDataManager.h"
#import "SectionTrack.h"
#import "ServiceItem.h"
#import "SectionSubBanner.h"
#import "SubBannerItem.h"
#import "SectionFind.h"
#import "SectionFindNews.h"
#import "SectionMiniBanner.h"
#import "SectionFullScreenAd.h"
#import "SectionMyPhone.h"
#import "IndexConstant.h"
#import "SectionMyProperty.h"
#import "SectionMyTaskBtn.h"
#import "SectionBannerReplace.h"
#import "SectionMyTask.h"
#import "SectionNetworkError.h"
#import "TaskAnimationManager.h"
#import <MJExtension/MJExtension.h>
#import "SectionAD.h"

@implementation IndexData

- (id) initWithJson:(NSDictionary *)json
{
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]){
        return [self initWithTPDJson:json];
    }

    return [self initWithJsonForService:json];
}

- (id) initWithJsonForService:(NSDictionary *)json
{
    
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    NSArray* sections = [json objectForKey:@"sections"];
    NSArray* classifies = [json objectForKey:@"classify"];
    
    for (NSDictionary* section in sections) {
        IndexFilter* filter = [[IndexFilter alloc] initWithJson:[section objectForKey:@"filter"]];
        
        NSString* type = [section objectForKey:@"type"];
        NSNumber* index = [section objectForKey:@"index"];
        
        if (![filter isValid] && ![type isEqualToString:SECTION_TYPE_CATEGORY] ) {
            continue;
        }
        SectionGroup* group = [[SectionGroup alloc]initWithType:type andIndex:[index intValue]];
        
        if ([SECTION_TYPE_SEARCH isEqualToString:type]) {
            SectionSearch* search = [[SectionSearch alloc] initWithJson:section];
            [group.sectionArray addObject:search];
            group.index = SECTION_TYPE_SEARCH_INDEX;
        } else if ([SECTION_TYPE_BANNER isEqualToString:type]) {
            NSArray* bannerGroups = [section objectForKey:@"banners"];
            for (NSDictionary* banner in bannerGroups) {
                SectionBanner* sectionBanner = [[SectionBanner alloc]initWithJson:banner];
                [group.sectionArray addObject:sectionBanner];
            }
            group.index = SECTION_TYPE_BANNER_INDEX;
        } else if ([SECTION_TYPE_SUB_BANNER isEqualToString:type]) {
            IndexFilter* filter = [[IndexFilter alloc]initWithJson:[section objectForKey:@"filter"]];
            if ([filter isValid]) {
                NSArray* bannerGroups = [section objectForKey:@"sub_banners"];
                SectionSubBanner* sectionBanner = [[SectionSubBanner alloc]init];
                for (NSDictionary* banner in bannerGroups) {
                    SubBannerItem* item = [[SubBannerItem alloc]initWithJson:banner];
                    if([item isValid]) {
                        [sectionBanner.items addObject:item];
                    }
                }
                group.index = SECTION_TYPE_SUB_BANNER_INDEX;
                [group.sectionArray addObject:sectionBanner];
                [self.groupArray addObject:group];
                SectionSeparator* item = [[SectionSeparator alloc]init];
                group = [[SectionGroup alloc]initWithType:SECTION_TYPE_SEPARATOR andIndex:SECTION_TYPE_SUB_BANNER_INDEX + 1];
                [group.sectionArray addObject:item];
            }
        } else if ([SECTION_TYPE_MY_TASK isEqualToString:type]) {
            IndexFilter* filter = [[IndexFilter alloc]initWithJson:[section objectForKey:@"filter"]];
            if ([filter isValid]) {
                SectionMyTask* task = [[SectionMyTask alloc] initWithJson:section];
                if ([task isValid]) {
                    [[TaskAnimationManager instance] setTaskSection:task];
                }
                continue;
            }
        } else if ([SECTION_TYPE_FINDS isEqualToString:type]) {
            IndexFilter* filter = [[IndexFilter alloc]initWithJson:[section objectForKey:@"filter"]];
            if ([filter isValid]) {
                NSArray* findGroups = [section objectForKey:SECTION_TYPE_FINDS];
                for (NSDictionary* find in findGroups) {
                    filter = [[IndexFilter alloc]initWithJson:[find objectForKey:@"filter"]];
                    if ([filter isValid]) {
                        for (NSDictionary* j in [find objectForKey:@"items"]) {
                            CategoryItem* item = [[CategoryItem alloc]initWithJson:j];
                            if([item isValid]) {
                                if ([UIDataManager instance].recommends) {
                                    if ([UIDataManager instance].recommends.items.count >= item.index.intValue) {
                                        @synchronized (self) {
                                          [[UIDataManager instance].recommends.items insertObject:item atIndex:item.index.intValue];
                                        }
                                        
                                    }
                                }
                            }
                        }
                        if ([UIDataManager instance].recommends) {
                            
                            CategoryItem* item = [self createAllService];
                            if ([UIDataManager instance].recommends.items.count >= 9) {
                                CategoryItem* item = [self createAllService];
                                @synchronized (self) {
                                    [[UIDataManager instance].recommends.items insertObject:item atIndex:9];
                                }
                                
                            } else {
                                CategoryItem* item = [self createAllService];
                                @synchronized (self) {
                                     [[UIDataManager instance].recommends.items addObject:item];
                                }
                               
                            }
                        }
                    }
                }
            }
            group.sectionType = SECTION_TYPE_RECOMMEND;
            if ([UIDataManager instance].recommends && [UIDataManager instance].recommends.items.count > 0) {
                [group.sectionArray addObject:[UIDataManager instance].recommends];
            }
            continue;
            
        } else if ([SECTION_TYPE_ANNOUNCEMENT isEqualToString:type]) {
            NSArray* announcements = [section objectForKey:@"announcements"];
            for (NSDictionary* announcement in announcements) {
                SectionAnnouncement* sectionAnnouncement = [[SectionAnnouncement alloc]initWithJson:announcement];
                group.index = SECTION_TYPE_ANNOUNCEMENT_INDEX;
                [group.sectionArray addObject:sectionAnnouncement];
            }
        } else if ([SECTION_TYPE_ACTIVITY isEqualToString:type]) {
            NSArray* activityData = [section objectForKey:@"activityIcons"];
            [UserDefaultsManager setObject:activityData forKey:INDEX_REQUEST_ACTIVITY];
        } else if ([SECTION_TYPE_ASSET isEqualToString:type]) {
            NSArray* assetArray = [section objectForKey:@"highlights"];
            [UIDataManager instance].assetDic = [NSMutableDictionary new];
            for (NSDictionary* dictionary in assetArray) {
                [[UIDataManager instance].assetDic setObject:dictionary forKey:[dictionary objectForKey:@"type"]];
            }
        } else if ([SECTION_TYPE_RECOMMEND isEqualToString:type]) {
            NSArray* recommendGroups = [section objectForKey:@"recommends"];
            IndexFilter* filter = [[IndexFilter alloc]initWithJson:[section objectForKey:@"filter"]];
            if ([filter isValid]) {
                for (NSArray* rds in recommendGroups) {
                    SectionRecommend* sectionRecommend = [[SectionRecommend alloc] initWithArray:rds];
                    
                    if ([UIDataManager instance].recommends) {
                        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                               NSMakeRange(0,[sectionRecommend.items count])];
                        @synchronized (self) {
                            [[UIDataManager instance].recommends.items insertObjects:sectionRecommend.items atIndexes:indexes];
                        }
                        
                    } else {
                        [UIDataManager instance].recommends = sectionRecommend;
                    }
                    [group.sectionArray addObject:[UIDataManager instance].recommends];
                    break;
                }
                group.index = SECTION_TYPE_RECOMMEND_INDEX;
                [self.groupArray addObject:group];
                SectionSeparator* item = [[SectionSeparator alloc]init];
                group = [[SectionGroup alloc]initWithType:SECTION_TYPE_SEPARATOR andIndex:SECTION_TYPE_RECOMMEND_INDEX + 1];
                [group.sectionArray addObject:item];
            }
        } else if ([SECTION_TYPE_RECOMMEND_EXTRA isEqualToString:type]) {
            NSArray* recommendGroups = [section objectForKey:@"extra_recommends"];
            IndexFilter* filter = [[IndexFilter alloc]initWithJson:[section objectForKey:@"filter"]];
            if ([filter isValid]) {
                SectionRecommend* sectionRecommend = [SectionRecommend new];
                for (NSDictionary* item in recommendGroups) {
                    CategoryItem* recd = [[CategoryItem alloc] initWithJson:item];
                    if ([recd isValid]) {
                        [sectionRecommend.items addObject:recd];
                    }
                }
                if ([sectionRecommend isValid]) {
                    if ([UIDataManager instance].recommends) {
                        @synchronized (self) {
                            [[UIDataManager instance].recommends.items addObjectsFromArray:sectionRecommend.items];
                        }
                        
                    } else {
                        [UIDataManager instance].recommends = sectionRecommend;
                    }
                    if ([UIDataManager instance].recommends.items.count > 9) {
                        CategoryItem* item = [self createAllService];
                        @synchronized (self) {
                             [[UIDataManager instance].recommends.items insertObject:item atIndex:9];
                        }
                       
                    } else {
                        CategoryItem* item = [self createAllService];
                        @synchronized (self) {
                            [[UIDataManager instance].recommends.items addObject:item];
                        }
                        
                    }
                }
                
            }
        } else if ([SECTION_TYPE_CATEGORY isEqualToString:type]) {
            SectionNewCategory* item = [[SectionNewCategory alloc]initWithJson:section];
            [group.sectionArray addObject:item];
            [UIDataManager instance].hasCategory = [item isValid] && item.count.intValue > 0;
            group.index = SECTION_TYPE_CATEGORY_INDEX;
            if ([UIDataManager instance].hasCategory) {
                [self.groupArray addObject:group];
                SectionSeparator* itemSep = [[SectionSeparator alloc]init];
                group = [[SectionGroup alloc]initWithType:SECTION_TYPE_SEPARATOR andIndex:SECTION_TYPE_CATEGORY_INDEX + 1];
                [group.sectionArray addObject:itemSep];
            }
        } else if ([SECTION_TYPE_TRACK isEqualToString:type]) {
            SectionTrack* item = [[SectionTrack alloc]initWithJson:section];
            [group.sectionArray addObject:item];
            
        } else if ([SECTION_TYPE_CATEGORY_BLIST isEqualToString:type]) {
            NSArray* categoryblistData = [section objectForKey:@"category_black_list"];
            [UserDefaultsManager setObject:categoryblistData forKey:INDEX_CATEGORY_BLIST];
        } else if ([SECTION_TYPE_SEPARATOR isEqualToString:type]) {
            //            SectionSeparator* item = [[SectionSeparator alloc]initWithJson:section];
            //            if ([item isValid]) {
            //                [group.sectionArray addObject:item];
            //            }
        } else if ([SECTION_TYPE_FAVOURITE isEqualToString:type]) {
            SectionFavourite* item = [[SectionFavourite alloc]initWithJson:section];
            [group.sectionArray addObject:item];
            group.index = SECTION_TYPE_FAVOURITE_INDEX;
            [self.groupArray addObject:group];
            SectionSeparator* itemSep = [[SectionSeparator alloc]init];
            group = [[SectionGroup alloc]initWithType:SECTION_TYPE_SEPARATOR andIndex:SECTION_TYPE_FAVOURITE_INDEX + 1];
            [group.sectionArray addObject:itemSep];
        } else if ([SECTION_TYPE_FIND_NEWS isEqualToString:type]) {
            SectionFindNews* item = [[SectionFindNews alloc]initWithJson:section];
            [group.sectionArray addObject:item];
            group.index = SECTION_TYPE_FIND_NEWS_INDEX;
        } else if ([SECTION_TYPE_COUPON isEqualToString:type]) {
            IndexFilter* filter = [[IndexFilter alloc]initWithJson:[section objectForKey:@"filter"]];
            if ([filter isValid]) {
                NSArray* couponGroups = [section objectForKey:@"coupons"];
                for (NSDictionary* cp in couponGroups) {
                    group = [[SectionGroup alloc]initWithType:type andIndex:SECTION_TYPE_COUPON_INDEX];
                    SectionCoupon* coupon = [[SectionCoupon alloc]initWithJson:cp];
                    coupon.title =[section objectForKey:@"title"];
                    coupon.queryId = [section objectForKey:@"query_id"];
                    [group.sectionArray addObject:coupon];
                    [self.groupArray addObject:group];
                }
            }
            continue;
            
        }else if ([SECTION_TYPE_FOOTER isEqualToString:type]) {
            //            SectionFooter* footer = [[SectionFooter alloc]initWithJson:[section objectForKey:@"script"]];
            //            [group.sectionArray addObject:footer];
        } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:type]) {
            SectionMiniBanner* item = [[SectionMiniBanner alloc]initWithJson:section];
            [group.sectionArray addObject:item];
            group.index = SECTION_TYPE_MINI_BANNERS_INDEX;
        } else if ([SECTION_TYPE_FULL_SCREEN_ADS isEqualToString:type]) {
            SectionFullScreenAd *item = [[SectionFullScreenAd alloc] initWithJson:section];
            [group.sectionArray addObject:item];
            group.index = SECTION_TYPE_FULL_SCREEN_AD_INDEX;
        }
        [self.groupArray addObject:group];
    }
    
    NSMutableArray* classifyArray = [NSMutableArray new];
    for (NSDictionary* classify in classifies) {
        ServiceItem* item = [[ServiceItem alloc] initWithJson:classify];
        if ([item isValid]) {
            if (classifyArray.count == 0) {
                item.isSelected = YES;
            } else {
                item.isSelected = NO;
            }
            [classifyArray addObject:item];
        }
    }
    
    if (classifies.count > 0) {
        [UIDataManager instance].classifyArray = classifyArray;
    }
    
    [self dealWithRecommend];
    
    return self;
}

- (id) initWithTPDJson:(NSDictionary *)json{
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    NSArray* sections = [json objectForKey:@"sections"];
    NSLog(@"indexData, json= %@", [json mj_JSONString]);
    
    
    SectionAD* adSection = nil;
    // SECTION_TYPE_BANNER,
    NSArray *validTypes = @[SECTION_TYPE_BANNER, SECTION_TYPE_MINI_BANNERS, SECTION_TYPE_V6_SECTIONS];
    for (NSDictionary* section in sections) {
        NSString* type = [section objectForKey:@"type"];
        NSNumber* index = [section objectForKey:@"index"];
        BOOL valid = NO;
        for(NSString *vtype in validTypes) {
            if ([vtype isEqualToString:type]) {
                valid = YES;
                break;
            }
        }
        if (!valid) {
            continue;
        }
        SectionGroup* group = [[SectionGroup alloc] initWithType:type andIndex:[index intValue]];
        
        if ([SECTION_TYPE_BANNER isEqualToString:type]) {
            NSArray* bannerGroups = [section objectForKey:@"banners"];
            for (NSDictionary* banner in bannerGroups) {
                SectionBanner* sectionBanner = [[SectionBanner alloc]initWithJson:banner];
                [group.sectionArray addObject:sectionBanner];
            }
            group.index = SECTION_TYPE_TPD_BANNER_INDEX;
            
        } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:type]) {
            SectionMiniBanner* item = [[SectionMiniBanner alloc]initWithJson:section];
            [group.sectionArray addObject:item];
            group.index = SECTION_TYPE_TPD_MINI_BANNERS_INDEX;
            
        } else if ([SECTION_TYPE_V6_SECTIONS isEqualToString:type]) {
            adSection = [[SectionAD alloc] initWithJson:section sectionIndex:SECTION_TYPE_TPD_V6_SECTIONS_INDEX sectionType:type];
            [group.sectionArray addObject:adSection];
            group.index = SECTION_TYPE_TPD_V6_SECTIONS_INDEX;
        }
        
        [self.groupArray addObject:group];
    }
    
    if (adSection.items.count >= 1) {
        SectionGroup* profitGroup = [[SectionGroup alloc] initWithType:SECTION_TYPE_PROFIT_CENTER andIndex:SECTION_TYPE_TPD_PROFIT_CENTER_INDEX];
        
        SectionAD* firstAdSection = [[SectionAD alloc] init];
        [firstAdSection.items addObject:[adSection.items firstObject]];
        
        firstAdSection.sectionIndex = SECTION_TYPE_TPD_PROFIT_CENTER_INDEX;
        firstAdSection.sectionType = SECTION_TYPE_PROFIT_CENTER;
        
        [profitGroup.sectionArray addObject:firstAdSection];
        profitGroup.index = SECTION_TYPE_TPD_PROFIT_CENTER_INDEX;
        
        //
        [self.groupArray addObject:profitGroup];
        
        // remove the the head
        [adSection.items removeObjectAtIndex:0];
        if (adSection.items.count == 1) {
            [self.groupArray removeObject:adSection];
        }
    }
    [self sortWithIndex];
    return self;
}

- (id) initFindNewsWithJson:(NSDictionary *)json
{
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    SectionGroup* group = [[SectionGroup alloc]initWithType:SECTION_TYPE_FIND_NEWS andIndex:SECTION_TYPE_FIND_NEWS_INDEX];
    
    SectionFindNews* item = [[SectionFindNews alloc]initWithJson:json];
    [group.sectionArray addObject:item];
    [self.groupArray addObject:group];
    
    return self;
}

- (id) initMyPhone{
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    SectionGroup* group = [[SectionGroup alloc]initWithType:SECTION_TYPE_MY_PHONE andIndex:SECTION_TYPE_MY_PHONE_INDEX];
    
    SectionMyPhone* myPhone = [SectionMyPhone new];
    [group.sectionArray addObject:myPhone];
    [self.groupArray addObject:group];
    
    return self;
}

- (id) initNetWorkError{
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    SectionGroup* group = [[SectionGroup alloc]initWithType:SECTION_TYPE_NETWORK_ERROR andIndex:SECTION_TYPE_NETWORK_ERROR_INDEX];
    
    SectionNetworkError* networkError = [SectionNetworkError new];
    [group.sectionArray addObject:networkError];
    [self.groupArray addObject:group];
    
    return self;
}

- (id) initMyTask {
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    SectionGroup* group = [[SectionGroup alloc]initWithType:SECTION_TYPE_MY_TASK andIndex:SECTION_TYPE_MY_TASK_INDEX];
    
    SectionMyTask* myTask = [[TaskAnimationManager instance] taskSection];
    if (myTask) {
        [group.sectionArray addObject:myTask];
        [self.groupArray addObject:group];
        return self;
    }
    
    return nil;
}

- (id) initHotChannel {
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    SectionGroup* group = [[SectionGroup alloc]initWithType:SECTION_TYPE_HOT_CHANNEL andIndex:SECTION_TYPE_HOT_CHANNEL_INDEX];
    
    SectionBase* hotChannel = [SectionBase new];
    [hotChannel.items addObject:[BaseItem new]];
    [group.sectionArray addObject:hotChannel];
    [self.groupArray addObject:group];
    
    return self;
}

- (id) initMyProperty {
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    // V6 testing
    int index = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO] ?
        SECTION_TYPE_TPD_MY_PROPERTY_INDEX : SECTION_TYPE_MY_PROPERTY_INDEX;
    
    SectionGroup* group = [[SectionGroup alloc]initWithType:SECTION_TYPE_MY_PROPERTY andIndex:index];
    SectionMyProperty* propertySection = [SectionMyProperty new];
    
    for (int i = 0; i < MY_PROPERTY_COLUMN_COUNT; i++) {
        CategoryItem* item = [CategoryItem new];
        item.title = [NSString stringWithFormat:@"%d", i];
        item.subTitle = [NSString stringWithFormat:@"%d", i];
        item.disabledIcon = [NSString stringWithFormat:@"%d", i + 1];
        [propertySection.items addObject:item];
    }
    
    [group.sectionArray addObject:propertySection];
    [self.groupArray addObject:group];
    
    return self;
}

- (id) initMyTaskBtn {
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    SectionGroup* group = [[SectionGroup alloc]initWithType:SECTION_TYPE_MY_TASK_BTN andIndex:SECTION_TYPE_MY_TASK_BTN_INDEX];
    
    SectionMyTaskBtn* taskSection = [SectionMyTaskBtn new];
    
    [group.sectionArray addObject:taskSection];
    [self.groupArray addObject:group];
    
    return self;
}

- (id) initBannerReplace {
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    SectionGroup* group = [[SectionGroup alloc]initWithType:SECTION_TYPE_BANNER_REPLACE andIndex:SECTION_TYPE_BANNER_REPLACE_INDEX];
    
    SectionBannerReplace* section = [SectionBannerReplace new];
    
    [group.sectionArray addObject:section];
    [self.groupArray addObject:group];
    
    return self;
}

- (id) initLocalSettings {
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    SectionGroup* localSettingGroup = [[SectionGroup alloc] initWithType:SECTION_TYPE_LOCAL_SETTINGS andIndex:SECTION_TYPE_TPD_LOCAL_SETTINGS_INDEX];
    SectionAD* item = [SectionAD localSettingSection];
    [localSettingGroup.sectionArray addObject:item];
    localSettingGroup.index = SECTION_TYPE_TPD_LOCAL_SETTINGS_INDEX;
    [self.groupArray addObject:localSettingGroup];
    
    return self;
}

- (void) dealWithRecommend
{
    for (SectionGroup* group in self.groupArray) {
        if ([group.sectionType isEqualToString:SECTION_TYPE_RECOMMEND]) {
            if (group.sectionArray.count > 0) {
                SectionRecommend* recommend = [group.sectionArray objectAtIndex:0];
                NSMutableArray* newItems = [NSMutableArray new];
                for (CategoryItem* item in recommend.items) {
                    if (item.type && item.type.length > 0 && [item isValid]) {
                        for (SectionGroup* group in self.groupArray) {
                            if ([SECTION_TYPE_CATEGORY isEqualToString:group.sectionType]) {
                                SectionNewCategory* categorySection = (SectionNewCategory*)[group.sectionArray objectAtIndex:group.current];
                                BOOL isValidItem = NO;
                                for (CategoryItem* i in categorySection.items) {
                                    if ([i.identifier isEqualToString:item.type]) {
                                        item.ctUrl = [i.ctUrl mutableCopy];
                                        item.subItems = [i.subItems mutableCopy];
                                        item.type = i.type;
                                        item.filter = [i.filter mutableCopy];
                                        isValidItem = YES;
                                        break;
                                    }
                                }
                                if (!isValidItem) {
                                    for (CategoryItem* i in [[UIDataManager instance] categoryExtendData]) {
                                        if ([i.identifier isEqualToString:item.type]) {
                                            item.ctUrl = [i.ctUrl mutableCopy];
                                            item.subItems = [i.subItems mutableCopy];
                                            item.type = i.type;
                                            item.filter = [i.filter mutableCopy];
                                            isValidItem = YES;
                                            break;
                                        }
                                    }
                                }
                                
                                if (isValidItem) {
                                    [newItems addObject:item];
                                }
                            }
                        }
                    } else {
                        if ([item isValid]) {
                            [newItems addObject:item];
                        }
                    }
                }
                
                recommend.items = newItems;
            }
        }
    }
}
- (id)init
{
    self = [super init];
    self.groupArray = [[NSMutableArray alloc]init];
    
    return self;
}


- (void) mergeWithOther:(IndexData* )other
{
    if (other) {
        for (SectionGroup* group in other.groupArray) {
            if ([group isValid] || [SECTION_TYPE_ANNOUNCEMENT isEqualToString:group.sectionType] || [SECTION_TYPE_CATEGORY isEqualToString:group.sectionType]) {
                SectionGroup* validGroup = [[SectionGroup alloc] init];
                NSArray* categories = (NSMutableArray*)[UserDefaultsManager objectForKey:INDEX_CATEGORY_BLIST];
                if ([SECTION_TYPE_CATEGORY isEqualToString:group.sectionType] && categories && categories.count > 0) {
                    SectionCategory* newData = [[SectionCategory alloc] init];
                    for (SectionCategory* data in group.sectionArray) {
                        for (CategoryItem* item in data.items) {
                            if ([categories containsObject:item.identifier]) {
                                continue;
                            }
                            [newData.items addObject:item];
                        }
                        newData.filter = data.filter;
                        newData.isOpened = data.isOpened;
                        newData.name = data.name;
                        newData.style = data.style;
                        
                        if (newData.items.count > 0) {
                            [validGroup.sectionArray addObject:newData];
                        }
                        
                    }
                    if (validGroup.sectionArray.count > 0) {
                        validGroup.index = group.index;
                        validGroup.current = group.current;
                        validGroup.sectionType = group.sectionType;
                        [self.groupArray addObject:validGroup];
                    }
                } else {
                    //                    if ([SECTION_TYPE_RECOMMEND isEqualToString:group.sectionType]) {
                    //                        break;
                    //                    } else
                    if ([SECTION_TYPE_CATEGORY isEqualToString:group.sectionType]) {
                        validGroup = [group copyAll];
                        [self.groupArray addObject:validGroup];
                    } else {
                        validGroup = [group validCopy];
                        [self.groupArray addObject:validGroup];
                    }
                }
                
            }
        }
    }
}

- (void) sortWithIndex
{
    NSArray* sortedArray = [self.groupArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger indexA = ((SectionGroup* )a).index;
        NSInteger indexB = ((SectionGroup* )b).index;
        return indexA > indexB;
    }];
    
    NSMutableArray* array =  [NSMutableArray arrayWithArray: sortedArray];
    self.groupArray = array;
}

- (CategoryItem *) createAllService
{
    CategoryItem* item = [CategoryItem new];
    item.title = @"全部服务";
    item.identifier = @"all_service";
    item.iconLink = @"http://search.cootekservice.com/res/image/index/first_icon/all_service_20160118.png";
    item.iconPath = @"/res/image/index/first_icon/all_service_20160118.png";
    item.ctUrl = [CTUrl new];
    item.ctUrl.nativeUrl = [NSDictionary dictionaryWithObject:@{@"controller":@"AllServiceViewController"} forKey:@"ios"];
    return item;
}
@end
