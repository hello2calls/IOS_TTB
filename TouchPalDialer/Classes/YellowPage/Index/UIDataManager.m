//
//  UIDataManager.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#import <Foundation/Foundation.h>
#import "UIDataManager.h"
#import "SearchRowView.h"
#import "BannerRowView.h"
#import "AnnouncementRowView.h"
#import "RecommendRowView.h"
#import "CategoryRowView.h"
#import "SearchCellView.h"
#import "FooterRowView.h"
#import "IndexConstant.h"
#import "IndexJsonUtils.h"
#import "YellowPageWebViewController.h"
#import "CTUrl.h"
#import "IndexData.h"
#import "CategoryItem.h"
#import "SectionCategory.h"
#import "YellowPageMainTabController.h"
#import "SectionRecommend.h"
#import "SectionSeparator.h"
#import "SeparatorRowView.h"
#import "SectionSearch.h"
#import "UserDefaultsManager.h"
#import "SectionFavourite.h"
#import "FindRowView.h"
#import "SectionNewCategory.h"
#import "NewCategoryRowView.h"
#import "CootekNotifications.h"
#import "SectionCoupon.h"
#import "CouponRowView.h"
#import "NSStack.h"
#import "PublicNumberMessageView.h"
#import "SubBannerRowView.h"
#import "SectionFind.h"
#import "FindNewsRowView.h"
#import "SectionFindNews.h"
#import "FindNewTitleView.h"
#import "SectionMiniBanner.h"
#import "MiniBannerRowView.h"
#import "BaiduMobAdNativeAdView.h"
#import "MyRowView.h"
#import "SectionMyPhone.h"
#import "MyPropertyRowView.h"
#import "MyTaskBtnRowView.h"
#import "SectionMyTaskBtn.h"
#import "SectionMyTask.h"
#import "MyTaskRowView.h"
#import "HotChannelRowView.h"
#import "NetworkErrorRowView.h"
#import "Reachability.h"
#import "TaskAnimationManager.h"
#import "SectionAD.h"
#import "Masonry.h"
#import "UILayoutUtility.h"
#import "TPDPersonalCenterController.h"
#import "TPDialerResourceManager.h"

UIDataManager *ui_instance_ = nil;

@interface UIDataManager()
{
    int isCrazyCount;
    BOOL isClicked;
    BOOL addUserAgent;
}

@end

@implementation UIDataManager : NSObject

@synthesize tempData;
@synthesize indexData;
@synthesize tableView;
@synthesize viewController;
@synthesize searchBar;
@synthesize stackWebview;
@synthesize categoryExtendData;
@synthesize couponDic;
@synthesize serviceBottomData;
@synthesize tracks;

- (id) init
{
    self = [super init];
    self.stackWebview = [NSStack new];
    self.couponData = [[IndexData alloc] init];
    self.findNewsData = [IndexData new];
    addUserAgent = NO;
    self.tracks = (NSMutableArray*)[UserDefaultsManager objectForKey:YP_USER_TRACK];
    self.classifyArray = [NSMutableArray new];
    self.queue = [[NSOperationQueue alloc]init];
    [self.queue setMaxConcurrentOperationCount:10];
    self.showedNewsDic = [[NSMutableDictionary alloc]init];
    return self;
}

+ (void)initialize
{
    ui_instance_ = [[UIDataManager alloc] init];
}

+ (UIDataManager *)instance
{
    return ui_instance_;
}

- (void) updateWithLocalData:(IndexData *)localData
{
    @synchronized(self) {
        self.localData = localData;
        [self updateIndexData];
    }
}

- (void) updateWithNetData:(IndexData *)netData
{
    @synchronized(self) {
        self.netData = netData;
        [self updateWithMiniBanner];
        [self updateIndexData];
    }
}

- (void) updateWithDynamicData:(IndexData *)dynamicData
{
    @synchronized(self) {
        self.dynamicData = dynamicData;
        [self updateIndexData];
    }
}

- (void) updateWithCouponData:(IndexData *)couponData
{
    @synchronized(self) {
        if (![self hasCoupon] && couponData.groupArray.count > 0) {
            for (SectionGroup* group in couponData.groupArray) {
                if ([group isValid]) {
                    SectionCoupon* firstCoupon = [group.sectionArray objectAtIndex:0];
                    firstCoupon.isFirst = YES;
                    break;
                }
            }
            
        }
        [self.couponData mergeWithOther:couponData];
        [self updateIndexData];
    }
}

- (void) updateWithFindNewsData:(NSArray *)findNewsData isRefresh:(BOOL)isRefresh
{
    @synchronized(self) {
        if (!self.findNewsData){
            self.findNewsData = [IndexData new];
        }
        if(self.findNewsData.groupArray.count <= 0) {
            SectionGroup* group = [[SectionGroup alloc]initWithType:SECTION_TYPE_FIND_NEWS andIndex:SECTION_TYPE_FIND_NEWS_INDEX];
            
            SectionFindNews* item = [[SectionFindNews alloc]initWithJson:[NSDictionary new]];
            [group.sectionArray addObject:item];
            [self.findNewsData.groupArray addObject:group];
        }
        SectionGroup* g = [self.findNewsData.groupArray objectAtIndex:0];
        SectionFindNews* f = [g.sectionArray objectAtIndex:g.current];
        if (isRefresh) {
            NSRange range = NSMakeRange(0, [findNewsData count]);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [f.items insertObjects:findNewsData atIndexes:indexSet];
        } else {
            [f.items addObjectsFromArray:findNewsData];
        }
    }
    [self updateIndexData];
}

- (void) updateWithMiniBanner
{
    NSDictionary* data = (NSDictionary *)[UserDefaultsManager objectForKey:INDEX_REQUEST_MINI_BANNER];
    if (data) {
        IndexData* miniBanner = [[IndexData alloc]initWithJson:data];
        @synchronized(self) {
            self.miniBannerData = miniBanner;
            [self updateIndexData];
        }
    }
}

- (void) updateWithNetworkError
{
    if (self.networkErrorData) {
        return;
    }
    IndexData* netwrokError = [[IndexData alloc] initNetWorkError];
    @synchronized(self) {
        if (!self.networkErrorData) {
            self.networkErrorData = netwrokError;
            [self updateIndexData];
        }
    }
}

- (void) updateWithMyPhone
{
    if (self.myPhoneData) {
        return;
    }
    IndexData* myPhone = [[IndexData alloc] initMyPhone];
    @synchronized(self) {
        if (!self.myPhoneData) {
            self.myPhoneData = myPhone;
            [self updateIndexData];
        }
    }
}

- (void) updateWithMyProperty
{
    if (self.myProperty) {
        return;
    }
    IndexData* myProperty = [[IndexData alloc] initMyProperty];
    @synchronized(self) {
        if (!self.myProperty) {
            self.myProperty = myProperty;
            [self updateIndexData];
        }
    }
}

- (void) updateWithLocalSettings
{
    if (self.localSettings) {
        return;
    }
    IndexData* localSettings = [[IndexData alloc] initLocalSettings];
    @synchronized(self) {
        if (!self.localSettings) {
            self.localSettings = localSettings;
            [self updateIndexData];
        }
    }
}


- (int) updateWithMyDummyTask
{
    if (self.myTask) {
        return -1;
    }
    
    IndexData* myTask = [[IndexData alloc] initMyTask];
    @synchronized(self) {
        self.myTask = myTask;
        if (self.myTask) {
            [self.indexData mergeWithOther:myTask];
            [self.indexData sortWithIndex];
        }
    }
    
    for (int i = 0; i < self.indexData.groupArray.count; i++) {
        SectionGroup* group = [self.indexData.groupArray objectAtIndex:i];
        if ([group.sectionType isEqualToString:SECTION_TYPE_MY_TASK]) {
            return i;
        }
    }
    
    return -1;
    
}

- (void) updateWithHotChannel
{
    if (self.hotChannel) {
        return;
    }
    IndexData* hot = [[IndexData alloc] initHotChannel];
    @synchronized(self) {
        if (!self.hotChannel) {
            self.hotChannel = hot;
            [self updateIndexData];
        }
    }
}

- (void) updateWithMyTaskBtn
{
    IndexData* myTaskBtn = [[IndexData alloc] initMyTaskBtn];
    @synchronized(self) {
        self.myTaskBtn = myTaskBtn;
        [self updateIndexData];
    }
}

- (BOOL) hasCoupon
{
    for (SectionGroup* group in self.tempData.groupArray) {
        if ([group isValid] && [group.sectionType isEqualToString:SECTION_TYPE_COUPON]) {
            return YES;
        }
    }
    return NO;
}

- (void) removeCoupons
{
    @synchronized(self) {
        self.couponData = [IndexData new];
        self.couponDic = nil;
        [self updateIndexData];
    }
}

- (void) removeMiniBanner
{
    @synchronized(self) {
        self.miniBannerData = [IndexData new];
        [self updateIndexData];
    }
}

- (void) updateIndexData
{
    @synchronized(self) {
        IndexData* temp = [[IndexData alloc] init];
        
        if (!self.bannerReplace) {
            self.bannerReplace = [[IndexData alloc] initBannerReplace];
            
        }
        
        [temp mergeWithOther:self.localData];
        [temp mergeWithOther:self.netData];
        [temp mergeWithOther:self.couponData];
        [temp mergeWithOther:self.findNewsData];
        [temp mergeWithOther:self.miniBannerData];
        [temp mergeWithOther:self.dynamicData];
        [temp mergeWithOther:self.localSettings];
        
        if ([Reachability network] < network_2g) {
            [temp mergeWithOther:self.networkErrorData];
        }
        //        [temp mergeWithOther:self.myPhoneData];
        [temp mergeWithOther:self.myProperty];
        [temp mergeWithOther:self.myTaskBtn];
        [temp mergeWithOther:self.myTask];
        [temp mergeWithOther:self.hotChannel];
        
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            [self updateIndexForBanners:temp]; // mini-banners and banners
        }
        [temp sortWithIndex];
        
        self.tempData = temp;
        self.dynamicData = nil;
    }
}

- (void) updateIndexForBanners:(IndexData *)data {
    if (data == nil
        || data.groupArray.count == 0) {
        return;
    }
    SectionGroup *miniBannerGroup = nil;
    SectionGroup *bannerGroup = nil;
    for(SectionGroup *group in data.groupArray) {
        if ([SECTION_TYPE_BANNER isEqualToString:group.sectionType]) {
            bannerGroup = group;
        } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:group.sectionType]) {
            miniBannerGroup = group;
        }
    }
    if (miniBannerGroup != nil) {
        miniBannerGroup.index = SECTION_TYPE_TPD_MINI_BANNERS_INDEX;
        if (bannerGroup != nil) {
            bannerGroup.index = SECTION_TYPE_TPD_BANNER_INDEX;
        }
    } else {
        if (bannerGroup != nil) {
            bannerGroup.index = SECTION_TYPE_TPD_MINI_BANNERS_INDEX;
        }
    }
}

- (void) updateToUIData
{
    @synchronized(self) {
        if (self.tempData != self.indexData) {
            self.indexData = tempData;
        }
    }
}

- (UITableViewCell *) createViewWithIndexPath:(NSIndexPath *)indexPath andIdentifier:(NSString *)identifier
{
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        return [self tpd_createViewWithIndexPath:indexPath andIdentifier:identifier];
    }
    
    UITableViewCell *fCell = nil;
    float rowHeight = [self heightForRowWithIndexPath:indexPath];
    
    int screenWidth = TPScreenWidth();
    int startX = 0;
    fCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
    
    
    SectionGroup* group = (SectionGroup*)[indexData.groupArray objectAtIndex:indexPath.section];
    NSString* type = group.sectionType;
    
    if ([SECTION_TYPE_SEARCH isEqualToString:type]) {
        SearchRowView *searhView = [[SearchRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:[group.sectionArray objectAtIndex:group.current]];
        [fCell addSubview:searhView];
    } else if ([SECTION_TYPE_NETWORK_ERROR isEqualToString:type]) {
        NetworkErrorRowView *myView = [[NetworkErrorRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight)];
        [myView drawView];
        [fCell addSubview:myView];
    } else if ([SECTION_TYPE_MY_PHONE isEqualToString:type]) {
        MyRowView *myView = [[MyRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight)];
        [myView drawView];
        [fCell addSubview:myView];
    } else if ([SECTION_TYPE_HOT_CHANNEL isEqualToString:type]) {
        HotChannelRowView *myView = [[HotChannelRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight)];
        [fCell addSubview:myView];
        fCell.layer.zPosition = indexPath.section;
    } else if ([SECTION_TYPE_BANNER isEqualToString:type]) {
        BannerRowView *bannerView = [[BannerRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:group];
        [fCell addSubview:bannerView];
    } else if ([SECTION_TYPE_BANNER_REPLACE isEqualToString:type]) {
        UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, rowHeight -1)];
        [fCell addSubview:bannerView];
    } else if ([SECTION_TYPE_SUB_BANNER isEqualToString:type]) {
        SubBannerRowView *bannerView = [[SubBannerRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight)];
        [bannerView resetDataWithItem:[group.sectionArray objectAtIndex:group.current] andIndexPath:indexPath];
        [fCell addSubview:bannerView];
        fCell.layer.zPosition = indexPath.section;
    } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:type]) {
        MiniBannerRowView *bannerView = [[MiniBannerRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight)];
        [bannerView resetDataWithItem:[group.sectionArray objectAtIndex:group.current] andIndexPath:indexPath];
        [fCell addSubview:bannerView];
        
    } else if ([SECTION_TYPE_ANNOUNCEMENT isEqualToString:type]) {
        AnnouncementRowView *announcement = [[AnnouncementRowView alloc] initWithFrame:CGRectMake(startX,0, screenWidth,rowHeight) andData:group];
        [fCell addSubview:announcement];
    } else if ([SECTION_TYPE_RECOMMEND isEqualToString:type]) {
        SectionRecommend* sectionRecommend = [group.sectionArray objectAtIndex:group.current];
        RecommendRowView *recommendView = [[RecommendRowView alloc] initWithFrame:CGRectMake(startX,0, screenWidth,rowHeight) andData:sectionRecommend andIndex:indexPath];
        [fCell addSubview:recommendView];
        fCell.layer.zPosition = indexPath.section;
    } else if ([SECTION_TYPE_CATEGORY isEqualToString:type]) {
        SectionNewCategory* item = [group.sectionArray objectAtIndex:group.current];
        NewCategoryRowView* categoryView = [[NewCategoryRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:item andIndexPath:indexPath andHeader:YES];
        [fCell addSubview:categoryView];
    } else if ([SECTION_TYPE_MY_PROPERTY isEqualToString:type]) {
        SectionMyProperty* item = [group.sectionArray objectAtIndex:group.current];
        MyPropertyRowView* categoryView = [[MyPropertyRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:item andIndex:indexPath];
        [fCell addSubview:categoryView];
        fCell.layer.zPosition = indexPath.section;
    } else if ([SECTION_TYPE_MY_TASK_BTN isEqualToString:type]) {
        MyTaskBtnRowView* taskBtnView = [[MyTaskBtnRowView alloc] initWithFrame:CGRectMake(startX, (INDEX_ROW_HEIGHT_MY_TASK_BTN - MY_TASK_BTN_HEIGHT) / 2, screenWidth, rowHeight)];
        [taskBtnView drawView];
        [fCell addSubview:taskBtnView];
        [[TaskAnimationManager instance] setIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section + 1]];
        fCell.layer.zPosition = indexPath.section;
    } else if ([SECTION_TYPE_MY_TASK isEqualToString:type]) {
        SectionMyTask* item = [group.sectionArray objectAtIndex:group.current];
        if(item.items && item.items.count > 0) {
            MyTaskRowView* myTaskView = [[MyTaskRowView alloc] initWithFrame:CGRectMake(startX , 0, screenWidth, rowHeight) andData:item andIndexPath:indexPath];
            [fCell addSubview:myTaskView];
        } else {
            UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, rowHeight)];
            dummyView.backgroundColor = [UIColor clearColor];
            [fCell addSubview:dummyView];
        }
        fCell.layer.zPosition = 0;
    } else if ([SECTION_TYPE_TRACK isEqualToString:type]) {
        if (tracks.count > 0) {
            startX = 20;
            NSString* title = @"足迹:";
            CGSize titleSize = [PublicNumberMessageView getSizeByText:title andUIFont:[UIFont systemFontOfSize:13.0f]];
            VerticallyAlignedLabel* trackTitle = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(startX, 0, titleSize.width, rowHeight)];
            [fCell addSubview:trackTitle];
            trackTitle.text = title;
            trackTitle.font = [UIFont systemFontOfSize:13.0f];
            trackTitle.textColor = [UIColor grayColor];
            trackTitle.verticalAlignment = VerticalAlignmentMiddle;
            startX = startX + titleSize.width;
            int index = 0;
            for (CategoryItem* track in tracks) {
                if ([track isValid]) {
                    CGSize trackSize = [PublicNumberMessageView getSizeByText:track.title andUIFont:[UIFont systemFontOfSize:13.0f]];
                    startX = startX + 20;
                    if (startX + trackSize.width + 20 > screenWidth) {
                        break;
                    }
                    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(startX, 0, trackSize.width, rowHeight)];
                    button.titleLabel.font = [UIFont systemFontOfSize: 13.0f];
                    [button setTitle: track.title forState: UIControlStateNormal];
                    [button setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blueColor]forState:UIControlStateSelected];
                    [button setTitleColor:[UIColor blueColor]forState:UIControlStateHighlighted];
                    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    startX = startX + trackSize.width;
                    button.tag = index;
                    [fCell addSubview:button];
                    [button addTarget:self action:@selector(onClickTrack:) forControlEvents:UIControlEventTouchUpInside];
                    index ++;
                }
            }
        }
    } else if ([SECTION_TYPE_FINDS isEqualToString:type]) {
        SectionFind* item = [group.sectionArray objectAtIndex:group.current];
        FindRowView *findView = [[FindRowView alloc]initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:item andIndexPath:indexPath];
        [fCell addSubview:findView];
    } else if ([SECTION_TYPE_COUPON isEqualToString:type]) {
        SectionCoupon* item = [group.sectionArray objectAtIndex:group.current];
        CouponRowView *couponRowView = [[CouponRowView alloc]initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:item andIndexPath:indexPath];
        [fCell addSubview:couponRowView];
    } else if ([SECTION_TYPE_FIND_NEWS isEqualToString:type]) {
        
        SectionFindNews* item = [group.sectionArray objectAtIndex:group.current];
        FindNewsItem* itemFindnews = [item.items objectAtIndex:indexPath.row];
        
        FindNewsRowView *findNewsView = [[FindNewsRowView alloc]initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:itemFindnews andIndexPath:indexPath isV6:[UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]];
        if (itemFindnews.category == CategoryADBaidu) {
            BaiduMobAdNativeAdView* nativeAdView = [[BaiduMobAdNativeAdView alloc]initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight)
                                                                                          title:nil
                                                                                           text:nil
                                                                                           icon:nil
                                                                                      mainImage:nil];
            
            [nativeAdView addSubview:findNewsView];
            [nativeAdView loadAndDisplayNativeAdWithObject:itemFindnews.baiduAdNativeObject completion:^(NSArray *errors) {
                if (!errors) {
                    if (nativeAdView) {
                        [nativeAdView trackImpression];
                    }
                }
            }];
            [fCell addSubview:nativeAdView];
        } else {
            [fCell addSubview:findNewsView];
        }
    } else if ([SECTION_TYPE_SEPARATOR isEqualToString:type]) {
        SectionSeparator* item = [group.sectionArray objectAtIndex:group.current];
        SeparatorRowView *separatorView = [[SeparatorRowView alloc]initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:item andIndexPath:indexPath];
        [fCell addSubview:separatorView];
        fCell.selectionStyle = UITableViewCellSelectionStyleNone;
        fCell.userInteractionEnabled = NO;
    } else if ([SECTION_TYPE_FOOTER isEqualToString:type]) {
        FooterRowView *footerRowView = [[FooterRowView alloc] initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:[group.sectionArray objectAtIndex:group.current]];
        [fCell addSubview:footerRowView];
        fCell.selectionStyle = UITableViewCellSelectionStyleNone;
        fCell.userInteractionEnabled = NO;
    }

    return fCell;
}

- (UITableViewCell *) tpd_createViewWithIndexPath:(NSIndexPath *)indexPath andIdentifier:(NSString *)identifier
{
    
    UITableViewCell *fCell = nil;
    float rowHeight = [self tpd_heightForRowWithIndexPath:indexPath];
    
    int screenWidth = TPScreenWidth();
    int startX = 0;
    UIColor *grey100 = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    fCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
    fCell.contentView.backgroundColor = grey100;
    
    SectionGroup* group = (SectionGroup*)[indexData.groupArray objectAtIndex:indexPath.section];
    NSString* type = group.sectionType;

    if ([SECTION_TYPE_BANNER isEqualToString:type]) {
        startX = 20;
        CGFloat contentHeight = 80;
        CGFloat startY = (rowHeight - contentHeight) / 2.0;
        BannerRowView *bannerView = [[BannerRowView alloc] initWithFrame:
                                     CGRectMake(startX, startY, screenWidth - 2 * startX, contentHeight) andData:group];
        bannerView.clipsToBounds = YES;
        bannerView.layer.cornerRadius = 10;
        [fCell addSubview:bannerView];
        fCell.contentView.backgroundColor = grey100;
        fCell.clipsToBounds = YES;
        
        UIImage *adImage = [TPDialerResourceManager getImage:@"tab_me_ad_text@3x.png"];
        UIImageView *adImageView = [[UIImageView alloc] initWithImage:adImage];
        [bannerView addSubview:adImageView];
        [adImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerY.mas_equalTo(bannerView);
        }];
        
    } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:type]) {
        CGSize contentSize = CGSizeMake(screenWidth * 0.75, INDEX_ROW_HEIGHT_TPD_MINI_BANER);
        startX = (screenWidth - contentSize.width ) / 2;
        MiniBannerRowView *bannerView = [[MiniBannerRowView alloc] initWithFrame:
                        CGRectMake(0, 0, screenWidth, contentSize.height)];
        [bannerView resetDataWithItem:[group.sectionArray objectAtIndex:group.current] andIndexPath:indexPath];
        [fCell addSubview:bannerView];
        
    } else if ([SECTION_TYPE_MY_PROPERTY isEqualToString:type]) {
        YPPropertyRowView *propertRowView = [[YPPropertyRowView alloc] init];
        propertRowView.tag = TAG_TPD_MY_PROPERTY;
        [fCell addSubview:propertRowView];
        
        [propertRowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(screenWidth);
            make.edges.mas_equalTo(fCell);
        }];
        
    } else if ([SECTION_TYPE_PROFIT_CENTER isEqualToString:type]) {
        SectionAD* item = (SectionAD *)[group.sectionArray objectAtIndex:group.current];
        YPAdRowView *cellView = [[YPAdRowView alloc] initWithData:item];
        cellView.tag = TAG_TPD_PROFIT_CENTER;
        [fCell addSubview:cellView];
        [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@(INDEX_ROW_HEIGHT_TPD_PROFIT_CENTER_CELL));
            make.left.right.top.mas_equalTo(fCell);
        }];
        
    } else if ([SECTION_TYPE_LOCAL_SETTINGS isEqualToString:type]) {
        SectionAD* item = (SectionAD *)[group.sectionArray objectAtIndex:group.current];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, INDEX_ROW_AD_CELL_MARGIN, 0);
        YPAdRowView *cellView = [[YPAdRowView alloc] initWithData:item contentInsets:insets];
        cellView.tag = TAG_TPD_LOCAL_SETTINGS;
        
        [fCell addSubview:cellView];
        [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@(INDEX_ROW_HEIGHT_AD_CELL * item.items.count));
            make.top.mas_equalTo(fCell.mas_top).offset(INDEX_ROW_AD_CELL_MARGIN * 0.5);
            make.left.right.mas_equalTo(fCell);
        }];
    
    } else if ([SECTION_TYPE_V6_SECTIONS isEqualToString:type]) {
        SectionAD* item = (SectionAD *)[group.sectionArray objectAtIndex:group.current];
        YPAdRowView *cellView = [[YPAdRowView alloc] initWithData:item];
        cellView.tag = TAG_TPD_AD_CELL;
        [fCell addSubview:cellView];
        [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@(INDEX_ROW_HEIGHT_AD_CELL * item.items.count));
            make.left.right.mas_equalTo(fCell);
            make.top.mas_equalTo(fCell).offset(INDEX_ROW_AD_CELL_MARGIN * 0.5);
            make.bottom.mas_equalTo(fCell).offset(-INDEX_ROW_AD_CELL_MARGIN * 0.5);
        }];
    }
    return fCell;
}


- (NSString *) getIdentifierWithIndexPath:(NSIndexPath *)indexPath
{
    return ((SectionGroup *)[indexData.groupArray objectAtIndex:indexPath.section]).sectionType;
    
}

- (int) rowCountWithSectionIndex:(NSInteger)section
{
    SectionGroup* group = (SectionGroup*)[indexData.groupArray objectAtIndex:section];
    NSString* type = group.sectionType;
    
    if ([SECTION_TYPE_SEARCH isEqualToString:type]) {
        return 1;
    }else if ([SECTION_TYPE_NETWORK_ERROR isEqualToString:type]) {
        return 1;
    }else if ([SECTION_TYPE_MY_PHONE isEqualToString:type]) {
        return 1;
    }else if ([SECTION_TYPE_HOT_CHANNEL isEqualToString:type]) {
        return 1;
    } else if ([SECTION_TYPE_BANNER isEqualToString:type]) {
        if ([BannerRowView checkImageReady:group]) {
            return 1;
        } else {
            return 0;
        }
    } else if ([SECTION_TYPE_BANNER_REPLACE isEqualToString:type]) {
        if (section == 0) {
            return 1;
        }
        return 0;
    } else if ([SECTION_TYPE_SUB_BANNER isEqualToString:type]) {
        SectionSubBanner* banner = ((SectionSubBanner*)[group.sectionArray objectAtIndex:group.current]);
        if(banner.items.count <= 1) {
            return 0;
        }
        return (banner.items.count / SUBBANNER_COLUMN_COUNT);
    } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:type]) {
        SectionMiniBanner* banner = (SectionMiniBanner*)[group.sectionArray objectAtIndex:group.current];
        return banner.items.count > 0 ? 1: 0;
    } else if ([SECTION_TYPE_ANNOUNCEMENT isEqualToString:type]) {
        if(![group isValid] && self.weatherData.length == 0) {
            return 0;
        }
        return 1;
    } else if ([SECTION_TYPE_RECOMMEND isEqualToString:type]) {
        SectionRecommend* recommend = ((SectionRecommend*)[group.sectionArray objectAtIndex:group.current]);
        int count = recommend.items.count > 10 ? 10 : recommend.items.count;
        return (count + RECOMMEND_COLUMN_COUNT - 1) / RECOMMEND_COLUMN_COUNT;
    } else if ([SECTION_TYPE_CATEGORY isEqualToString:type]) {
        if([group isValid]) {
            SectionNewCategory* category = (SectionNewCategory*)[group.sectionArray objectAtIndex:group.current];
            if (category.count.intValue > 0) {
                int count = (category.items.count + NEW_CATEGORY_COLUMN_COUNT - 1) / NEW_CATEGORY_COLUMN_COUNT;
                return count;
            }
        }
        return 0;
    } else if ([SECTION_TYPE_MY_PROPERTY isEqualToString:type]) {
        //        if([group isValid]) {
        //            SectionMyProperty* properties = (SectionMyProperty*)[group.sectionArray objectAtIndex:group.current];
        //            if (properties.items.count > 0) {
        //                int count = (properties.items.count + MY_PROPERTY_COLUMN_COUNT - 1) / MY_PROPERTY_COLUMN_COUNT;
        //                return count;
        //            }
        //        }
        return 1;
    } else if ([SECTION_TYPE_MY_TASK_BTN isEqualToString:type]) {
        return 1;
    } else if ([SECTION_TYPE_MY_TASK isEqualToString:type]) {
        SectionMyTask* task = (SectionMyTask*)[group.sectionArray objectAtIndex:group.current];
        return task.items.count;
    } else if ([SECTION_TYPE_TRACK isEqualToString:type]) {
        return 1;
    } else if ([SECTION_TYPE_COUPON isEqualToString:type]) {
        return 1;
    } else if ([SECTION_TYPE_FIND_NEWS isEqualToString:type]) {
        SectionFindNews* findNews = (SectionFindNews*)[group.sectionArray objectAtIndex:group.current];
        return findNews.items.count;
    } else if ([SECTION_TYPE_FINDS isEqualToString:type]) {
        return 1;
    } else if ([SECTION_TYPE_SEPARATOR isEqualToString:type]) {
        return 1;
    } else if ([SECTION_TYPE_FOOTER isEqualToString:type]) {
        return 1;
    } else if ([SECTION_TYPE_V6_SECTIONS isEqualToString:type]) {
        return 1;
    } else if ([SECTION_TYPE_PROFIT_CENTER isEqualToString:type]) {
        return 1;
    } else if ([SECTION_TYPE_LOCAL_SETTINGS isEqualToString:type]) {
        return 1;
    }
    return 0;
    
}

-(void)onClickTrack:(UIButton *)button{
    CategoryItem* item = [tracks objectAtIndex:button.tag];
    [item.ctUrl startWebView];
}

- (int) sectionCount
{
    //    int count = 0;
    //    for (SectionGroup* g in self.indexData.groupArray) {
    //        if ([g isValid]) {
    //            count++;
    //        }
    //    }
    return self.indexData.groupArray.count;
}

- (float) tpd_heightForRowWithIndexPath:(NSIndexPath *)indexPath {
    SectionGroup* group = (SectionGroup*)[indexData.groupArray objectAtIndex:indexPath.section];
    NSString* type = group.sectionType;
    if ([SECTION_TYPE_BANNER isEqualToString:type]) {
        if ([UserDefaultsManager boolValueForKey:INDEX_REQUEST_DOWNLOADED_NEW_BANNER defaultValue:NO]) {
            return 0;
        }
        return INDEX_ROW_HEIGHT_TPD_BANNER;
        
    } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_TPD_MINI_BANER;
        
    } else if ([SECTION_TYPE_MY_PROPERTY isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_TPD_MY_PROPERTY;
        
    } else if ([SECTION_TYPE_SEPARATOR isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_SEPARATOR;
    } else if ([SECTION_TYPE_FOOTER isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_FOOTER;
        
    } else if ([SECTION_TYPE_LOCAL_SETTINGS isEqualToString:type]) {
        SectionAD* adSection = [group.sectionArray objectAtIndex:0];
        return INDEX_ROW_HEIGHT_AD_CELL * adSection.items.count + INDEX_ROW_AD_CELL_MARGIN * 1.5;
        
    } else if ([SECTION_TYPE_PROFIT_CENTER isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_AD_CELL + INDEX_ROW_AD_CELL_MARGIN * 0.5;
        
    } else if ([SECTION_TYPE_V6_SECTIONS isEqualToString:type]) {
        SectionAD* adSection = [group.sectionArray objectAtIndex:0];
        return INDEX_ROW_HEIGHT_AD_CELL * adSection.items.count + INDEX_ROW_AD_CELL_MARGIN;
    }
    return 0;
}

- (float) heightForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        return [self tpd_heightForRowWithIndexPath:indexPath];
    }
    
    SectionGroup* group = (SectionGroup*)[indexData.groupArray objectAtIndex:indexPath.section];
    NSString* type = group.sectionType;
    if(![group isValid]) {
        if (self.weatherData.length == 0 || ![SECTION_TYPE_ANNOUNCEMENT isEqualToString:type]) {
            return 0;
        }
    }
    
    if ([SECTION_TYPE_SEARCH isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_SEARCH;
    } else if ([SECTION_TYPE_NETWORK_ERROR isEqualToString:type]) {
        if ([Reachability network] < network_2g) {
            return INDEX_ROW_HEIGHT_NETWORK_ERROR;
        }
    } else if ([SECTION_TYPE_MY_PHONE isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_MY_PHONE;
    } else if ([SECTION_TYPE_HOT_CHANNEL isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_HOT_CHANNEL;
    } else if ([SECTION_TYPE_BANNER isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_BANNER;
    } else if ([SECTION_TYPE_BANNER_REPLACE isEqualToString:type]) {
        if (indexPath.row == 0) {
            return TPHeaderBarHeight();
        } else {
            return 0;
        }
    } else if ([SECTION_TYPE_SUB_BANNER isEqualToString:type]) {
        
        SectionSubBanner* subbaner = [group.sectionArray objectAtIndex:0];
        if (subbaner.items.count < 2) {
            return 0;
        }
        
        //        新版iOS奇数时候第一行高度更大
        if ((subbaner.items.count % 2) && !(indexPath.row)) {
            return INDEX_ROW_HEIGHT_SUB_BANNER * 2;
        } else {
            return INDEX_ROW_HEIGHT_SUB_BANNER;
        }
    } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:type]) {
        SectionMiniBanner* banner = (SectionMiniBanner*)[group.sectionArray objectAtIndex:group.current];
        return banner.items.count > 0 ? INDEX_ROW_HEIGHT_MINI_BANNER: 0;
    } else if ([SECTION_TYPE_ANNOUNCEMENT isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_ANNOUNCEMENT;
    } else if ([SECTION_TYPE_TRACK isEqualToString:type]) {
        if (tracks.count <=0) {
            return 0;
        }
        return INDEX_ROW_HEIGHT_TRACK;
    } else if ([SECTION_TYPE_RECOMMEND isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_RECOMMEND;
    } else if ([SECTION_TYPE_CATEGORY isEqualToString:type]) {
        if (indexPath.row == 0) {
            return INDEX_ROW_HEIGHT_NEW_CATEGORY + NEW_CATEGORY_ROW_HEIGHT_HEADER;
        } else {
            return INDEX_ROW_HEIGHT_NEW_CATEGORY;
        }
    } else if ([SECTION_TYPE_MY_PROPERTY isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_MY_PROPERTY;
    } else if ([SECTION_TYPE_MY_TASK_BTN isEqualToString:type]) {
        if (self.myTask) {
            return INDEX_ROW_HEIGHT_MY_TASK_BTN;
        } else {
            return INDEX_ROW_HEIGHT_MY_TASK_BTN + 10.0f;
        }
    } else if ([SECTION_TYPE_MY_TASK isEqualToString:type]) {
        //        if (self.myTask) {
        //            return 0.0f;
        //        } else {
        return INDEX_ROW_HEIGHT_MY_TASK;
        //        }
    } else if ([SECTION_TYPE_COUPON isEqualToString:type]) {
        SectionCoupon* coupon = ((SectionCoupon*)[group.sectionArray objectAtIndex:group.current]);
        return [CouponRowView getRowHeight:coupon];
    } else if ([SECTION_TYPE_FIND_NEWS isEqualToString:type]) {
        SectionFindNews* finds = [group.sectionArray objectAtIndex:group.current];
        FindNewsItem* item = [finds.items objectAtIndex:indexPath.row];
        
        if (item.category == CategoryADBaidu && [item.baiduAdNativeObject isExpired]) {
            return 0;
        }
        
        CGFloat height = -1.0f;
        switch (item.type.intValue) {
            case FIND_NEWS_TYPE_BIG_IMAGE:
            {
                CGFloat width = TPScreenWidth() - 2 * FIND_NEWS_LEFT_MARGIN;
                CGFloat heightTitle = [FindNewTitleView getHeightByTitle:item.title withWidth:width];
                CGFloat heightSubTitle = [FindNewsSubTitleView getHeightByTitle:item.title withWidth:width];
                height =  INDEX_ROW_HEIGHT_FIND_NEWS_BIG_IMAGE + heightTitle + 2 * FIND_NEWS_TOP_MARGIN + heightSubTitle + 2 * FIND_NEWS_MARGIN_TO_IMAGE;
                break;
            }
            case FIND_NEWS_TYPE_NO_IMAGE:
            {
                CGFloat width = TPScreenWidth() - 2 * FIND_NEWS_LEFT_MARGIN;
                CGFloat heightTitle = [FindNewTitleView getHeightByTitle:item.title withWidth:width];
                CGFloat heightSubTitle = [FindNewsSubTitleView getHeightByTitle:item.title withWidth:width];
                height =  INDEX_ROW_HEIGHT_FIND_NEWS_NO_IMAGE + heightTitle + 2 * FIND_NEWS_TOP_MARGIN + heightSubTitle;
                break;
            }
            case FIND_NEWS_TYPE_ONE_IMAGE:
            {
                height = INDEX_ROW_HEIGHT_FIND_NEWS_ONE_IMAGE + 2 * FIND_NEWS_TOP_MARGIN;
                break;
            }
            case FIND_NEWS_TYPE_THREE_IMAGE:
            {
                CGFloat width = TPScreenWidth() - 2 * FIND_NEWS_LEFT_MARGIN;
                CGFloat heightTitle = [FindNewTitleView getHeightByTitle:item.title withWidth:width];
                CGFloat heightSubTitle = [FindNewsSubTitleView getHeightByTitle:item.title withWidth:width];
                height = INDEX_ROW_HEIGHT_FIND_NEWS_THREE_IMAGE + heightTitle + 2 * FIND_NEWS_TOP_MARGIN + heightSubTitle + 2 * FIND_NEWS_MARGIN_TO_IMAGE;
                break;
            }
            case FIND_NEWS_TYPE_VIDEO: {
                CGFloat width = TPScreenWidth() - 2 * FIND_NEWS_LEFT_MARGIN;
                CGFloat heightTitle = [FindNewTitleView getHeightByTitle:item.title withWidth:width];
                CGFloat heightSubTitle = [FindNewsSubTitleView getHeightByTitle:item.title withWidth:width];
                height = INDEX_ROW_HEIGHT_FIND_NEWS_VIDEO + heightTitle + 2 * FIND_NEWS_TOP_MARGIN + heightSubTitle + 2 * FIND_NEWS_MARGIN_TO_IMAGE;
                break;
            }
            default:
                break;
        }
        if (indexPath.row == 0 && height > 0) {
            height = height + INDEX_ROW_HEIGHT_FIND_NEWS_HEADER;
        }
        return height;
    } else if ([SECTION_TYPE_FINDS isEqualToString:type]) {
        SectionFind* find = ((SectionFind*)[group.sectionArray objectAtIndex:group.current]);
        int rowCount = ([find.items count] + FIND_COLUMN_COUNT - 1) / FIND_COLUMN_COUNT;
        return INDEX_ROW_HEIGHT_FIND * rowCount + FIND_ROW_HEIGHT_HEADER;
    } else if ([SECTION_TYPE_SEPARATOR isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_SEPARATOR;
    } else if ([SECTION_TYPE_FOOTER isEqualToString:type]) {
        return INDEX_ROW_HEIGHT_FOOTER;
    }
    return 0;
}

- (BOOL) resetDataWithCell:(UITableViewCell*)cell andIndexPath:(NSIndexPath *)indexPath
{
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        return [self tpd_resetDataWithCell:cell andIndexPath:indexPath];
    }
    
    SectionGroup* group = (SectionGroup*)[indexData.groupArray objectAtIndex:indexPath.section];
    NSString* type = group.sectionType;
    UIView* targetView = nil;
    if ([SECTION_TYPE_CATEGORY isEqualToString:type]) {
        SectionNewCategory* category = (SectionNewCategory*)[group.sectionArray objectAtIndex:group.current];
        NewCategoryRowView* view = (NewCategoryRowView*)[cell viewWithTag:[NewCategoryRowView getCategoryTag:indexPath]];
        [view resetDataWithCategoryItem:category andIndexPath:indexPath];
        targetView = view;
        //    } else if ([SECTION_TYPE_MY_PROPERTY isEqualToString:type]) {
        //        SectionMyProperty* property = (SectionMyProperty*)[group.sectionArray objectAtIndex:group.current];
        //        MyPropertyRowView* view = (MyPropertyRowView*)[cell viewWithTag:[NewCategoryRowView getCategoryTag:indexPath]];
        //        [view resetDataWithMyProperty:property andIndexPath:indexPath];
        //        targetView = view;
    } else if ([SECTION_TYPE_MY_TASK_BTN isEqualToString:type]) {
        MyTaskBtnRowView* view = (MyTaskBtnRowView*)[cell viewWithTag:MT_TASK_BTN_TAG];
        [view drawView];
        targetView = view;
    } else if ([SECTION_TYPE_BANNER isEqualToString:type]) {
        BannerRowView* view = (BannerRowView*)[cell viewWithTag:BANNER_TAG];
        [view resetWithBannerData:group];
        targetView = view;
    } else if ([SECTION_TYPE_SUB_BANNER isEqualToString:type]) {
        //        SectionSubBanner* banner = (SectionSubBanner*)[group.sectionArray objectAtIndex:group.current];
        //        SubBannerRowView* view = (SubBannerRowView*)[cell viewWithTag:SUB_BANNER_TAG];
        //        [view resetDataWithItem:banner andIndexPath:indexPath];
        //        targetView = view;
    } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:type]) {
        MiniBannerRowView* view = (MiniBannerRowView*)[cell viewWithTag:MINI_BANNER_TAG];
        targetView = view;
        
    } else if ([SECTION_TYPE_MY_TASK isEqualToString:type]) {
        //        MyTaskRowView* view = (MyTaskRowView*)[cell viewWithTag:MY_TASK];
        //        view.task = [group.sectionArray objectAtIndex:0];
        //        view.path = indexPath;
        //        [view drawView];
        //        targetView = view;
    } else if ([SECTION_TYPE_ANNOUNCEMENT isEqualToString:type]) {
        AnnouncementRowView* view = (AnnouncementRowView*)[cell viewWithTag:ANNOUNCEMENT_TAG];
        [view resetWithAnnouncementData:group];
        targetView = view;
    } else if ([SECTION_TYPE_FINDS isEqualToString:type]) {
        FindRowView* view = (FindRowView*)[cell viewWithTag:FIND_TAG + indexPath.section * 100];
        SectionFind* find = (SectionFind*)[group.sectionArray objectAtIndex:group.current];
        [view resetDataWithFindItem:find andIndexPath:indexPath];
        targetView = view;
    } else if ([SECTION_TYPE_RECOMMEND isEqualToString:type]) {
        SectionRecommend* recommend = ((SectionRecommend*)[group.sectionArray objectAtIndex:group.current]);
        RecommendRowView* view = (RecommendRowView*)[cell viewWithTag:RECOMMEND_TAG];
        [view resetDataWithRecommendItem:recommend andIndexPath:indexPath];
        targetView = view;
    } else if ([SECTION_TYPE_COUPON isEqualToString:type]) {
        SectionCoupon* coupon = ((SectionCoupon*)[group.sectionArray objectAtIndex:group.current]);
        CouponRowView* view = (CouponRowView*)[cell viewWithTag:COUPON_TAG];
        [view resetDataWithCouponItem:coupon andIndexPath:indexPath];
        targetView = view;
    } else if ([SECTION_TYPE_FIND_NEWS isEqualToString:type]) {
        SectionFindNews* finds = ((SectionFindNews*)[group.sectionArray objectAtIndex:group.current]);
        FindNewsItem* item = [finds.items objectAtIndex:indexPath.row];
        if (item.category == CategoryADBaidu) {
            targetView = nil;
        } else {
            FindNewsRowView* view = (FindNewsRowView*)[cell viewWithTag:FIND_NEWS_TAG];
            [view resetDataWithFindNewsItem:item andIndexPath:indexPath];
            targetView = view;
        }
    } else if ([SECTION_TYPE_FOOTER isEqualToString:type]) {
        FooterRowView* view = (FooterRowView*)[cell viewWithTag:FOOTER_TAG];
        [view drawView];
        targetView = view;
    } else if ([SECTION_TYPE_SEPARATOR isEqualToString:type]) {
        SeparatorRowView* view = (SeparatorRowView*)[cell viewWithTag:SEPARATOR_TAG];
        targetView = view;
    }
    return targetView != nil;
}

- (BOOL) tpd_resetDataWithCell:(UITableViewCell*)cell andIndexPath:(NSIndexPath *)indexPath {
    SectionGroup* group = (SectionGroup*)[indexData.groupArray objectAtIndex:indexPath.section];
    NSString* type = group.sectionType;
    UIView* targetView = nil;
    
    if ([SECTION_TYPE_BANNER isEqualToString:type]) {
        BannerRowView* view = (BannerRowView*)[cell viewWithTag:BANNER_TAG];
        [view resetWithBannerData:group];
        targetView = view;
    } else if ([SECTION_TYPE_MINI_BANNERS isEqualToString:type]) {
        MiniBannerRowView* view = (MiniBannerRowView*)[cell viewWithTag:MINI_BANNER_TAG];
        targetView = view;
    } else if ([SECTION_TYPE_V6_SECTIONS isEqualToString:type]) {
        YPAdRowView *rowView = (YPAdRowView *)[cell viewWithTag:TAG_TPD_AD_CELL];
        [rowView updateUIWithData:group.sectionArray[0]];
        targetView = rowView;
        
    } else if ([SECTION_TYPE_PROFIT_CENTER isEqualToString:type]) {
        YPAdRowView *rowView = (YPAdRowView *)[cell viewWithTag:TAG_TPD_PROFIT_CENTER];
        [rowView updateUIWithData:group.sectionArray[0]];
        targetView = rowView;
        
    } else if ([SECTION_TYPE_LOCAL_SETTINGS isEqualToString:type]) {
        YPAdRowView *rowView = (YPAdRowView *)[cell viewWithTag:TAG_TPD_LOCAL_SETTINGS];
        [rowView updateUIWithData:group.sectionArray[0]];
        targetView = rowView;
        
    } else if ([SECTION_TYPE_MY_PROPERTY isEqualToString:type]) {
        YPPropertyRowView *propertyView = (YPPropertyRowView *)[cell viewWithTag:TAG_TPD_MY_PROPERTY];
        [propertyView update];
    }
    return targetView != nil;
}

- (void) setClicked {
    isClicked = YES;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        isClicked = NO;
    });
}

- (BOOL) isButtonClicked {
    return isClicked;
}

- (BOOL) checkDoubleClick {
    if (!isClicked) {
        [self setClicked];
        return NO;
    }
    
    return YES;
}

- (void) addTrack: (CategoryItem*)track
{
    if (!tracks) {
        tracks = [NSMutableArray new];
    }
    for (CategoryItem* item in tracks) {
        if ([item.title isEqualToString:track.title]) {
            [tracks removeObject:item];
            break;
        }
    }
    [tracks insertObject:track atIndex:0];
    while (tracks.count > 9) {
        [tracks removeLastObject];
    }
    [UserDefaultsManager setObject:tracks forKey:YP_USER_TRACK];
}

- (void) pushWebView:(UIView<FLWebViewProvider> *)object
{
    [stackWebview push:object];
}

- (UIView<FLWebViewProvider> *) popWebView;
{
    return [stackWebview pop];
}

- (BOOL) isCrazyScroll
{
    if (isCrazyCount++ > 2) {
        isCrazyCount = 0;
        return YES;
    }
    return NO;
}

- (void) deallocUI
{
    if(self.tableView) {
        tableView = nil;
        viewController = nil;
    }
}

- (void) addUserAgent
{
    if (!addUserAgent) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        oldAgent = [oldAgent stringByReplacingOccurrencesOfString:@" Proxy/cootekservice" withString:@""];
        NSString *newAgent = [NSString stringWithFormat:@"%@ %@", oldAgent, @"Proxy/cootekservice"];
        
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
        addUserAgent = YES;
        
    }
}
@end
