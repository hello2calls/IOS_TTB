//
//  UIDataManager.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#import "CategoryItem.h"
#import "FLWebViewProvider.h"
#import "SectionRecommend.h"

@class IndexData;
@class YellowPageMainTabController;
@class NSStack;
@class SectionNewCategory;
@class FullScreenAdItem;

@interface UIDataManager : NSObject

+ (UIDataManager *)instance;

@property(nonatomic ,retain) IndexData* indexData;
@property(nonatomic, retain) IndexData* localData;
@property(nonatomic, retain) IndexData* netData;
@property(nonatomic, retain) IndexData* couponData;
@property(nonatomic, retain) IndexData* findNewsData;
@property(nonatomic, retain) IndexData* miniBannerData;
@property(nonatomic, retain) IndexData* networkErrorData;
@property(nonatomic, retain) IndexData* myPhoneData;
@property(nonatomic, retain) IndexData* myProperty;
@property(nonatomic, retain) IndexData* myTask;
@property(nonatomic, retain) IndexData* hotChannel;
@property(nonatomic, retain) IndexData* myTaskBtn;
@property(nonatomic, retain) IndexData* bannerReplace;
@property(atomic, retain) SectionRecommend* recommends;
@property(nonatomic, retain) IndexData* dynamicData;
@property(nonatomic, retain) IndexData* tempData;
@property(nonatomic, retain) NSMutableDictionary* assetDic;
@property(nonatomic ,retain) UITableView *tableView;
@property(nonatomic ,retain) UIViewController* viewController;
@property(nonatomic, retain) UISearchBar* searchBar;
@property(nonatomic, retain) NSStack* stackWebview;
@property(nonatomic, retain) NSMutableArray* categoryExtendData;
@property(nonatomic, retain) NSDictionary* couponDic;
@property(nonatomic, retain) NSDictionary* serviceBottomData;
@property(nonatomic, retain) NSMutableArray* tracks;
@property(nonatomic, retain) NSMutableArray* classifyArray;
@property(nonatomic, retain) NSString* weatherData;
@property(nonatomic, assign) double startRecordTime;
@property(nonatomic, retain) NSString* indexFontName;
@property(nonatomic, retain) SectionNewCategory* allCategories;
@property(nonatomic, assign) BOOL hasCategory;
@property(nonatomic, retain) NSOperationQueue* queue;
@property(nonatomic, retain) NSMutableDictionary* showedNewsDic;
@property(nonatomic, retain) FullScreenAdItem* showAdItem;
@property (nonatomic, strong) IndexData *localSettings;

- (void) updateWithLocalData: (IndexData* ) localData;
- (void) updateWithNetData: (IndexData* ) netData;
- (void) updateWithCouponData: (IndexData*) couponData;
- (void) updateWithFindNewsData:(NSArray *)findNewsData isRefresh:(BOOL)isRefresh;
- (void) updateWithMiniBanner;
- (void) updateWithNetworkError;
- (void) updateWithMyPhone;
- (void) updateWithMyProperty;
- (void) updateWithMyTaskBtn;
- (int) updateWithMyDummyTask;
- (void) updateWithHotChannel;
- (void) updateToUIData; // should call from main thread
- (void) removeCoupons;
- (void) updateWithLocalSettings;

- (UITableViewCell *) createViewWithIndexPath: (NSIndexPath *)indexPath andIdentifier:(NSString*) identifier;
- (NSString *) getIdentifierWithIndexPath: (NSIndexPath *)indexPath;
- (int) rowCountWithSectionIndex:(NSInteger)section;
- (int) sectionCount;
- (float) heightForRowWithIndexPath:(NSIndexPath *)indexPath;
- (BOOL) resetDataWithCell:(UITableViewCell*)cell andIndexPath:(NSIndexPath *)indexPath;
- (BOOL) isCrazyScroll;
- (BOOL) checkDoubleClick;
- (void) deallocUI;
- (void) pushWebView:(UIView<FLWebViewProvider> *)object;
- (void) addTrack:(CategoryItem* )track;
- (void) addUserAgent;
- (UIWebView *) popWebView;

@end
