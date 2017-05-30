//
//  SearchRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#import "SearchRowView.h"
#import "UIView+WithSkin.h"
#import "IndexConstant.h"
#import "SectionSearch.h"
#import "LocalStorage.h"
#import "UserDefaultsManager.h"
#import "CootekNotifications.h"
#import "UpdateService.h"
#import "TouchPalVersionInfo.h"
#import "CTUrl.h"
#import "Reachability.h"
#import "UIDataManager.h"

@implementation SearchRowView

@synthesize searhView;
@synthesize citySelectView;


- (id)initWithFrame:(CGRect)frame andData:(SectionSearch *)data
{
    self = [super initWithFrame:frame];
    
    [self resetDataWithSearchItem: data];
    return self;
}

- (BOOL) shouldChangeLocCity:(NSString*)city
{
    int locTime = [[LocalStorage getItemWithKey:QUERY_LAST_CACHE_TIME_CITY] intValue];
    int now = [[NSDate date] timeIntervalSince1970];
    if (now - locTime > 24 * 60 * 60) {
        return YES;
    }
    
    if (![city isEqualToString:[LocalStorage getItemWithKey:QUERY_LAST_PARAM_CITY]]) {
        return YES;
    }
    
    return NO;
}

- (void) resetDataWithSearchItem:(SectionSearch*)item
{
    CGFloat searchWidth = 0;
    CGFloat cityWidth = 0;
    CitySelectView* cityView = nil;
    NSString* city =[LocalStorage getItemWithKey:QUERY_PARAM_CITY];
    if (city == nil || city.length == 0) {
        city = @"全国";
        [LocalStorage setItemForKey:QUERY_PARAM_CITY andValue:@"全国"];
    }
    
    if (![city isEqualToString:self.selectedCity]) {
        for(UIView *view in [self subviews])
        {
            [view removeFromSuperview];
        }
        
        if (city && city.length > 2) {
            cityWidth = SEARCH_BAR_CITY_WIDTH * 1.3;
            cityView = [[CitySelectView alloc] initWithFrame:CGRectMake(0,0, cityWidth,self.frame.size.height)];
            if (city.length > 4) {
                city = [city substringToIndex:4];
            }
            
        } else {
            cityWidth = SEARCH_BAR_CITY_WIDTH;
            cityView = [[CitySelectView alloc] initWithFrame:CGRectMake(0,0, cityWidth,self.frame.size.height)];
        }
        searchWidth = self.frame.size.width - cityWidth;
        
        self.citySelectView = cityView;
        self.citySelectView.tag = 99;
        [self addSubview:cityView];
        
        SearchCellView* searchView = [[SearchCellView alloc]initWithFrame:CGRectMake(cityWidth,0,searchWidth, self.frame.size.height) andData:item];
        [self setTag:SEARCH_TAG];
        self.searhView = searchView;
        [self addSubview:searchView];
    }
    
    [self.citySelectView drawView:city];
    [self.searhView drawView];
    
}

@end