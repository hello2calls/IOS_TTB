//
//  FindNewsItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/23.
//
//

#import "BaseItem.h"
#import "GDTNativeAd.h"

#define FIND_NEWS_TYPE_ONE_IMAGE 1
#define FIND_NEWS_TYPE_BIG_IMAGE 2
#define FIND_NEWS_TYPE_THREE_IMAGE 3
#define FIND_NEWS_TYPE_NO_IMAGE 4
#define FIND_NEWS_TYPE_VIDEO (5)

typedef NS_ENUM(NSInteger, FindCategory) {
    CategoryNews  = 0,
    CategoryADDavinci,
    CategoryADBaidu,
    CategoryADGDT,
    CategoryUpdateRec,
    CategoryVideo
} ;


@interface FindNewsItem : BaseItem

- (id) initWithDavinicJson:(NSDictionary*) json;

@property(nonatomic, strong) NSNumber* type;
@property(nonatomic, strong) NSString* newsId;
@property(nonatomic, strong) NSString* queryId;
@property(nonatomic, strong) NSArray* images;
@property(nonatomic, strong) NSArray* hotKeys;
@property(nonatomic, strong) NSArray* highlightFlags;
@property(nonatomic, strong) NSDictionary* appLaunch;
@property(nonatomic, strong) NSString* timestamp;
@property(nonatomic, assign) BOOL isAd;
@property(nonatomic, strong) GDTNativeAd* gdtAdNativeObject;
@property(nonatomic, strong) GDTNativeAdData* gdtAdNativeData;
@property(nonatomic, assign) FindCategory category;
@property(nonatomic, strong) NSString* sspS;
@property(nonatomic, strong) NSNumber* followAdn;
@property(nonatomic, strong) NSNumber* rank;
@property(nonatomic, strong) NSNumber* expid;
@property(nonatomic, strong) NSString* reserved;
@property(nonatomic, assign) NSNumber* topIndex;
@property(nonatomic, assign) BOOL noBottomBorder;
@property (nonatomic, assign) long duration;

//work for ad
@property(nonatomic, strong) NSString* ftu;
//work for is clicked
@property(nonatomic, assign) BOOL isClicked;

- (NSComparisonResult)compare:(id)otherObject;
@end
