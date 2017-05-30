//
//  SmartEyeSettingView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 9/26/12.
//
//

#import "SmartEyeSettingView.h"
#import "TPDialerResourceManager.h"
#import "CootekTableViewCell.h"
#import "UITableView+TP.h"
#import "YellowCityModel.h"
#import "CityDataDBA.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "AppSettingsModel.h"
#import "TouchPalDialerAppDelegate.h"
#import "CommonModel.h"
#import "CloudYellowPage.h"
#import "YellowCityDataManager.h"
#import "SettingCellView.h"
#import "YellowPageModel.h"
#import "RootTabViewController.h"
#import "YellowPageGuideView.h"
#import "NetworkDataDownloader.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"
#define CHECK_IAMGE_VIEW_IN_SMARTSETTINGVIEW 94853

#define SMART_EYE_SETTING_VIEW_TAG 94584
#define GUIDE_TO_YELLOWPAGE_ALRET_VIEW_TAG 94585

@interface SmartEyeSettingView (){
    NSMutableDictionary *updateCitys_;
}
-(void)queryCityForUpdate:(NSArray *)citys;
-(BOOL)isUpdateCity:(YellowCityModel *)city;
@end
@implementation SmartEyeSettingView

@synthesize installCitys = installCitys_;
@synthesize unInstallCitys = unInstallCitys_;
@synthesize nationCity = nationCity_;

-(NSUInteger)cityCountNeedToUpdate
{
    if (updateCitys_ == nil) {
        return 0;
    }
    return [updateCitys_ count];
}

-(void) queryCityForUpdate:(NSArray *)citys{
    updateCitys_ = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSMutableDictionary *cityDic = [NSMutableDictionary dictionaryWithCapacity:[citys count]];
    for (YellowCityModel *city in citys) {
        [cityDic setObject:city forKey:city.cityID];
    }
  
    for(YellowCityModel* oldCity in installCitys_) {
        YellowCityModel *updateCity = [cityDic objectForKey:oldCity.cityID];
        if(updateCity) {
            NSInteger oldMainValue = [oldCity.mainVersion integerValue];
            NSInteger newMainValue = [updateCity.mainVersion integerValue];
            NSInteger oldUpdateValue = [oldCity.updateVersion integerValue];
            NSInteger newUpdateValue = [updateCity.updateVersion integerValue];
            if(newMainValue > oldMainValue || newUpdateValue > oldUpdateValue) {
                [updateCitys_ setObject:updateCity forKey:updateCity.cityID];
            }
        }
    }
    //TODO Nation
    YellowCityModel *updateCity = [cityDic objectForKey:nationCity_.cityID];
    if(updateCity) {
        NSInteger oldMainValue = [nationCity_.mainVersion integerValue];
        NSInteger newMainValue = [updateCity.mainVersion integerValue];
        NSInteger oldUpdateValue = [nationCity_.updateVersion integerValue];
        NSInteger newUpdateValue = [updateCity.updateVersion integerValue];
        if(newMainValue > oldMainValue ) {
            updateCity.updatePath = @"";
            [updateCitys_ setObject:updateCity forKey:updateCity.cityID];
        }else if (newUpdateValue > oldUpdateValue){
            updateCity.mainPath = @"";
            [updateCitys_ setObject:updateCity forKey:updateCity.cityID];
        }
    }
}
-(YellowCityModel *)updateCityForID:(NSString *)cityID{
    return [updateCitys_ objectForKey:cityID];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
        UITableView *contentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        contentTable.backgroundView = nil;
        contentTable.delegate = self;
        contentTable.dataSource = self;
        contentTable.sectionHeaderHeight = 30;
        [contentTable setSkinStyleWithHost:self forStyle:@"defaultUITableView_style"]; 
        cityTableView_ = contentTable;
        [self addSubview:contentTable];
        [contentTable release];

        isNoData_ = YES;
        [self loadLocalData];
        [self loadNetWorkData];
    
        self.tag = SMART_EYE_SETTING_VIEW_TAG;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(unInstallCitys_.count > 0 && installCitys_.count > 0){
       return 3;
    }else{
       return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0){
        return 1;
    }else if(section==1){
        if(installCitys_.count > 0){
            return installCitys_.count;
        }else{
            return unInstallCitys_.count;
        }
    }else if(section == 2){
        return unInstallCitys_.count;
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 30)] autorelease];
    sectionView.backgroundColor = [UIColor clearColor];
    UILabel* sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, TPScreenWidth()-15, 30-0)];
    sectionHeader.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"SmartDailViewController_sectionHeaderText_color"];
    sectionHeader.font = [UIFont boldSystemFontOfSize:CELL_FONT_INPUT];
    sectionHeader.textAlignment = UITextAlignmentLeft;
    sectionHeader.backgroundColor = [UIColor clearColor];
    if(section==0){
       sectionHeader.text = NSLocalizedString(@"Unknown number recognition", @"");
    }else if(section==1){
       sectionHeader.text = installCitys_.count > 0 ? NSLocalizedString(@"Downloaded cities", @""):NSLocalizedString(@"Citylist", @"");
    }else if(section==2){
       sectionHeader.text = NSLocalizedString(@"More cities", @"");
    }
    
    [sectionView addSubview:sectionHeader];
    [sectionHeader release];
    BOOL needLoadingIndicator = (section ==1 || section == 2);
    if (isDidLoadData_ == NO && (isNoData_ && needLoadingIndicator)) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [indicator startAnimating];
        indicator.frame = CGRectMake(280, 3, 24, 24);
        [sectionView addSubview:indicator];
        [indicator release];
    }
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifierSetting = @"SettingCell";
    NSString *CellIdentifierCity = @"CityCellSmartEye";
    CootekTableViewCell *cell;
    if(indexPath.section ==0){
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSetting];
        if(cell == nil){
                       RoundedCellBackgroundViewPosition position  =[tableView cellPositionOfIndexPath:indexPath];
            cell = [[[SettingCellView alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:CellIdentifierSetting
                                              withCellType:SwitchCellType
                                              cellPosition:position] autorelease];
        }
        cell.textLabel.text = NSLocalizedString(@"Inquiry unknown numbers", @"");
        cell.textLabel.font = [UIFont boldSystemFontOfSize:CELL_FONT_INPUT];
        cell.detailTextLabel.text = NSLocalizedString(@"Connect to cloud for additional information", @"");
        SettingCellView *tmpCell = (SettingCellView *)cell;
        tmpCell.delegate = self;
        [tmpCell.rightSwitch setOn:[AppSettingsModel appSettings].smart_eye];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCity];
        if(cell==nil){
             cell = [[[CityDownCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierCity inFullWidth:YES] autorelease];
            [cell setSkinStyleWithHost:self forStyle:@"yellow_citycellForSetting_style"];
            CityDownCell *cellChange = (CityDownCell *)cell;
            cellChange.downLoadButton.frame = CGRectMake(cellChange.downLoadButton.frame.origin.x-10, cellChange.downLoadButton.frame.origin.y, cellChange.downLoadButton.frame.size.width, cellChange.downLoadButton.frame.size.height);
        }
        CityDownCell *cellChange = (CityDownCell *)cell;
        YellowCityModel *city = [self currentItem:indexPath.row section:indexPath.section];
        cellChange.delegate = self;
        BOOL isEdit = (installCitys_.count> 0 && indexPath.section == 1) ? YES : NO;
        [cellChange fillWithSource:city isSelected:NO isEdit:isEdit];
        if ([self isUpdateCity:city]) {

        }
       
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)loadNetWorkData{
    if([[CommonModel getSharedCommonModel].net_status_listener currentReachabilityStatus] > NotReachable) {
        isDidLoadData_ = NO;
        [cityTableView_ reloadData];
        [NSThread detachNewThreadSelector:@selector(willLoadCityData) toTarget:self withObject:nil];
    }
}
-(void)willLoadCityData{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *citys = [CloudYellowPage queryPackageList];
    [self performSelectorOnMainThread:@selector(didLoadCityData:) withObject:citys waitUntilDone:NO];
    [pool release];
}
-(void)didLoadCityData:(NSArray *)citys{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self mergeData:citys];
    isDidLoadData_ = YES;
    [cityTableView_ reloadData];
    isNoData_ = NO;
    [pool release];
}

-(void)mergeData:(NSArray *)citys{
    [YellowCityDataManager queryNewsUnLoadCity:installCitys_
                            withUnInstallCitys:unInstallCitys_
                                withServeCitys:citys];
    self.unInstallCitys = [CityDataDBA queryAllUnloadCity];
    [self queryCityForUpdate:citys];
}
#pragma mark SettingCellView delegate
- (void)changeSwitch:(BOOL)is_on  withKey:(NSString *)key{
    AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
    appSettingsModel.smart_eye = is_on;
    [appSettingsModel saveToFile];
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 2){
        CityDownCell *cell = (CityDownCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell downData:[cell downLoadButton]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
-(YellowCityModel *)currentItem:(NSInteger)row section:(NSInteger)section{
    YellowCityModel *city = nil;
    switch (section) {
        case 1:
            city = [installCitys_ count] > 0 ?[installCitys_ objectAtIndex:row]:[unInstallCitys_ objectAtIndex:row];
            break;
        case 2:
            city = [unInstallCitys_ objectAtIndex:row];
            break;
        default:
            break;
    }
    return city;
}

- (BOOL)isDown:(NSInteger)row section:(NSInteger)section{
    BOOL isDown = YES;
    switch (section) {
        case 1:
            isDown = ([installCitys_ count] > 0);
            break;
        case 2:
            isDown = NO;
            break;
        default:
            break;
    }
    return isDown;
}
-(BOOL)isUpdateCity:(YellowCityModel *)city{
    if (city.isDown) {
        return [updateCitys_ objectForKey:city.cityID]?YES:NO;
    }
    return NO;
}
-(void)loadLocalData{
    NSArray *allInstallCity = [CityDataDBA queryAllInstallCity];
    NSMutableArray *tmpInstallCity = [NSMutableArray arrayWithCapacity:1];
    for (int i =0; i<[allInstallCity count]; i++) {
        YellowCityModel *city = [allInstallCity objectAtIndex:i];
        if (![city.cityID isEqualToString:KEY_NATIONAL_ID]) {
            [tmpInstallCity addObject:city];
        }else{
            self.nationCity = city;
        }
    }
    self.installCitys = tmpInstallCity;
    self.unInstallCitys = [CityDataDBA queryAllUnloadCity];
}

#pragma mark CityDataDownDelegate
- (BOOL)isUpdateForCityId:(NSString *)cityID{
    return [updateCitys_ objectForKey:cityID]?YES:NO;
}
-(void)removeCityForID:(NSString *)cityID{
    [updateCitys_ removeObjectForKey:cityID];
}

-(void)didSelectItemCity:(YellowCityModel *)item{
    //do nothing here
}
-(void)willReloadCityDataAfterDown:(YellowCityModel *)item{
    [self loadLocalData];
    [cityTableView_ reloadData];
    BOOL needGuideToYellowPage = ![UserDefaultsManager boolValueForKey:GUIDE_TO_YELLOWPAGE_AFTER_DOWNLOADING_HAVE_ALREADY_SHOWN];
    
    UINavigationController *controller = [((TouchPalDialerAppDelegate *)([UIApplication sharedApplication].delegate)) activeNavigationController];
    if(needGuideToYellowPage && [controller.topViewController.view viewWithTag:SMART_EYE_SETTING_VIEW_TAG]){
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Find public numbers of %@", @""),item.cityName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                            message:message delegate:self
                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                             otherButtonTitles:NSLocalizedString(@"Try it", @""), nil];
        alertView.tag = GUIDE_TO_YELLOWPAGE_ALRET_VIEW_TAG;
        [alertView show];
        [alertView release];
        [UserDefaultsManager setBoolValue:YES forKey:GUIDE_TO_YELLOWPAGE_AFTER_DOWNLOADING_HAVE_ALREADY_SHOWN];
    }
}
-(void)willReloadCityDataAfterFailedDown:(YellowCityModel *)item{
    YellowPageModel *pageModel =[[YellowPageModel alloc] init];
    if([NetworkDataDownloadManager countForDownloadingItems:NetworkDataDownloaderYellowpage] == 0) {
        if ([installCitys_ count] > 0 && [pageModel.currentCity length] == 0) {
            pageModel.currentCity = item.cityID;;
        }
    }
    [pageModel release];
}
-(void)willReloadCityDataAfterUninstall:(YellowCityModel *)item{
    YellowCityModel *updateCity = [self updateCityForID:item.cityID];
    if (updateCity) {
        [CityDataDBA updateCity:updateCity];
        [self removeCityForID:updateCity.cityID];
    }
    YellowPageModel *pageModel =[[YellowPageModel alloc] init];
    if ([item.cityID isEqualToString:pageModel.currentCity]){
        pageModel.currentCity = @"";
    }
    [pageModel release];
    [self loadLocalData];
    [cityTableView_ reloadData];
}
- (void)dealloc{
    [SkinHandler removeRecursively:self];
    [nationCity_ release];
    [installCitys_ release];
    [unInstallCitys_ release];
    [updateCitys_ release];
    [super dealloc];
}
- (void)changeSkin{
  self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
  [cityTableView_ reloadData];
}
- (void)guideToYellowPageView{
    UINavigationController *controller = [((TouchPalDialerAppDelegate *)([UIApplication sharedApplication].delegate)) activeNavigationController];
    [controller popViewControllerAnimated:YES];
    [((RootTabViewController *)controller.topViewController).tabBar selectButtonAtIndex:0];
    YellowPageGuideView *yellowPageGuideView = [[YellowPageGuideView alloc] initWithFrame:CGRectMake(0, -20, TPScreenWidth(), TPScreenHeight())];
    [controller.topViewController.view addSubview:yellowPageGuideView];
    [yellowPageGuideView release];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case GUIDE_TO_YELLOWPAGE_ALRET_VIEW_TAG:
            if(buttonIndex == 1){
                [self guideToYellowPageView];
            }
            break;
            
        default:
            break;
    }
}
@end
