//
//  FindNewsItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/23.
//
//

#import "FindNewsItem.h"
#import "CTUrl.h"

@implementation FindNewsItem

@synthesize type;
@synthesize images;
@synthesize tu;
@synthesize timestamp;
@synthesize isAd;

- (id) initWithJson:(NSDictionary*) json
{
    self = [super initWithJson:json];
    if (self) {
        if ([json objectForKey:@"clk_url"]) {
            self.ctUrl = [[CTUrl alloc] initWithUrl:[json objectForKey:@"clk_url"]];
        }
        self.type = [json objectForKey:@"layout"];
        self.newsId = [json objectForKey:@"slot_id"];
        self.images = [json objectForKey:@"materials"];
        self.subTitle = [json objectForKey:@"source"];
        self.timestamp = [json objectForKey:@"timestamp"];
        self.hotKeys = [json objectForKey:@"tags"];
        self.highlightFlags = [json objectForKey:@"is_highlight"];
        self.tu = [json objectForKey:@"tu"];
        self.followAdn = [json objectForKey:@"follow_adn"];
        self.appLaunch = [json objectForKey:@"startApp"];
        self.isAd = NO;
        self.reserved = [json objectForKey:@"reserved"];
        self.topIndex = [json objectForKey:@"news_index"];
        if(self.type.intValue == FIND_NEWS_TYPE_THREE_IMAGE) {
            if(self.images.count < 3) {
                self.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_ONE_IMAGE];
            }
        }
        if ([json objectForKey:@"duration"] != nil) {
            _duration = [[json objectForKey:@"duration"] longValue];
        }
    }
    
    return self;
}

- (id) initWithDavinicJson:(NSDictionary*) json
{
    self = [super initWithJson:json];
    if (self) {
        if ([json objectForKey:@"clk_url"]) {
            self.ctUrl = [[CTUrl alloc] initWithUrl:[json objectForKey:@"clk_url"]];
        }
        self.adid = [json objectForKey:@"ad_id"];
        NSString* image = [json objectForKey:@"material"];
        if (image.length > 0) {
            self.images = [NSArray arrayWithObject:image];
        }
        
        self.subTitle = [json objectForKey:@"brand"];
        self.timestamp = [json objectForKey:@"timestamp"];
        self.hotKeys = [json objectForKey:@"tags"];
        self.highlightFlags = [json objectForKey:@"is_highlight"];
        self.tu = [json objectForKey:@"tu"];
        self.ftu = [json objectForKey:@"tu"];
        self.topIndex = [NSNumber numberWithInteger: -1];
        self.appLaunch = [json objectForKey:@"startApp"];
        self.isAd = YES;
        self.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_ONE_IMAGE];
        if ([json objectForKey:@"duration"] != nil) {
            _duration = [[json objectForKey:@"duration"] longValue];
        }
    }
    
    return self;
}

- (NSComparisonResult)compare:(id)otherObject {
    return [self.topIndex compare:((FindNewsItem *)otherObject).topIndex];
}


#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    FindNewsItem* ret = [super copyWithZone:zone];
    ret.type = [self.type copyWithZone:zone];
    ret.newsId = [self.newsId copyWithZone:zone];
    ret.queryId = [self.queryId copyWithZone:zone];
    ret.images = [self.images copyWithZone:zone];
    ret.hotKeys = [self.hotKeys copyWithZone:zone];
    ret.highlightFlags = [self.hotKeys copyWithZone:zone];
    ret.tu = [self.tu copyWithZone:zone];
    ret.ftu = [self.ftu copyWithZone:zone];
    ret.appLaunch = [self.appLaunch copyWithZone:zone];
    ret.timestamp = [self.timestamp copyWithZone:zone];
    ret.followAdn = [self.followAdn copyWithZone:zone];
    ret.isAd = self.isAd;
    ret.sspS = [self.sspS copyWithZone:zone];
    ret.rank = [self.rank copyWithZone:zone];
    ret.category = self.category;
    ret.expid = [self.expid copyWithZone:zone];
    ret.reserved = [self.reserved copyWithZone:zone];
    ret.isClicked = self.isClicked;
    ret.topIndex = self.topIndex;
    ret.noBottomBorder = self.noBottomBorder;
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    FindNewsItem* ret = [super mutableCopyWithZone:zone];
    ret.type = [self.type copyWithZone:zone];
    ret.newsId = [self.newsId copyWithZone:zone];
    ret.queryId = [self.queryId copyWithZone:zone];
    ret.images = [self.images mutableCopyWithZone:zone];
    ret.hotKeys = [self.hotKeys mutableCopyWithZone:zone];
    ret.highlightFlags = [self.hotKeys mutableCopyWithZone:zone];
    ret.tu = [self.tu mutableCopyWithZone:zone];
    ret.ftu = [self.ftu mutableCopyWithZone:zone];
    ret.appLaunch = [self.appLaunch mutableCopyWithZone:zone];
    ret.timestamp = [self.timestamp mutableCopyWithZone:zone];
    ret.followAdn = [self.followAdn copyWithZone:zone];
    ret.isAd = self.isAd;
    ret.category = self.category;
    ret.sspS = [self.sspS mutableCopyWithZone:zone];
    ret.rank = [self.rank copyWithZone:zone];
    ret.expid = [self.expid copyWithZone:zone];
    ret.reserved = [self.reserved mutableCopyWithZone:zone];
    ret.isClicked = self.isClicked;
    ret.topIndex = self.topIndex;
    ret.noBottomBorder = self.noBottomBorder;
    
    return ret;
}

#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.newsId = [aDecoder decodeObjectForKey:@"newsId"];
        self.queryId = [aDecoder decodeObjectForKey:@"queryId"];
        self.images = [aDecoder decodeObjectForKey:@"images"];
        self.hotKeys = [aDecoder decodeObjectForKey:@"hotKeys"];
        self.highlightFlags = [aDecoder decodeObjectForKey:@"highlightFlags"];
        self.tu = [aDecoder decodeObjectForKey:@"tu"];
        self.ftu = [aDecoder decodeObjectForKey:@"ftu"];
        self.appLaunch = [aDecoder decodeObjectForKey:@"appLaunch"];
        self.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
        self.followAdn = [aDecoder decodeObjectForKey:@"followAdn"];
        self.isAd = [aDecoder decodeBoolForKey:@"isAd"];
        self.category = [aDecoder decodeIntegerForKey:@"category"];
        self.sspS = [aDecoder decodeObjectForKey:@"sspS"];
        self.rank = [aDecoder decodeObjectForKey:@"rank"];
        self.expid = [aDecoder decodeObjectForKey:@"expid"];
        self.reserved = [aDecoder decodeObjectForKey:@"reserved"];
        self.topIndex = [aDecoder decodeObjectForKey:@"topIndex"];
        self.noBottomBorder = [aDecoder decodeBoolForKey:@"noBottomBorder"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.newsId forKey:@"newsId"];
    [aCoder encodeObject:self.queryId forKey:@"queryId"];
    [aCoder encodeObject:self.images forKey:@"images"];
    [aCoder encodeObject:self.hotKeys forKey:@"hotKeys"];
    [aCoder encodeObject:self.highlightFlags forKey:@"highlightFlags"];
    [aCoder encodeObject:self.tu forKey:@"tu"];
    [aCoder encodeObject:self.ftu forKey:@"ftu"];
    [aCoder encodeObject:self.appLaunch forKey:@"appLaunch"];
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
    [aCoder encodeObject:self.followAdn forKey:@"followAdn"];
    [aCoder encodeBool:self.isAd forKey:@"isAd"];
    [aCoder encodeInteger:self.category forKey:@"category"];
    [aCoder encodeObject:self.sspS forKey:@"sspS"];
    [aCoder encodeObject:self.rank forKey:@"rank"];
    [aCoder encodeObject:self.expid forKey:@"expid"];
    [aCoder encodeObject:self.reserved forKey:@"reserved"];
    [aCoder encodeObject:self.topIndex forKey:@"topIndex"];
    [aCoder encodeBool:self.noBottomBorder forKey:@"noBottomBorder"];
}

@end
