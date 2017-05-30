//
//  OrlandoEngine.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//

#import "OrlandoEngine.h"
#import "DialResultModel.h"
#import "ContractResultModel.h"
#import "CallLogDBA.h"
#import "PhonePadModel.h"
#import "YellowCityDataManager.h"
#include "def.h"
#include "Option.h"
#include "ContactEngine.h"
#include "Configs.h"
#include "ISearchResult.h"
#include "IPhoneNumber.h"
#include "IContactRecord.h"
#include "YellowPage.h"
#include "IYellowPageResult.h"
#include "ISearchResult_YellowPage.h"
#include <list>
#include <fcntl.h>
#include "SearchResult_CallerID.h"
#include "ICityGroup.h"
#import "CityGroupModel.h"
#import "CStringUtils.h"
#import "FunctionUtility.h"
#import "SmartDailerSettingModel.h"
#import "CityDataDBA.h"
#import "YellowFileModel.h"
#import "EngineResultModel.h"

#define MAX_QUERY_YELLLOWCOUNT    500
#define MAX_BRANCHES_YELLLOWCOUNT 300
#define KEY_NATION_NAME @"Hotlines"
#define DEFALUT_NATION_DATA_VERSION @"1100"
#define DEFALUT_NATION_DATA_SIZE 2300


using namespace orlando;

@interface OrlandoEngine(){
    ContactEngine *searchEngine;
}
@end
@implementation OrlandoEngine
static int specificKey = 0;
static int queryKey = 1;
static OrlandoEngine *_sharedSingletonContactSearchEngine = nil;

+ (OrlandoEngine *)instance
{
    return _sharedSingletonContactSearchEngine;
}

+ (void)initialize
{
    _sharedSingletonContactSearchEngine = [[OrlandoEngine alloc] init];
}

- (id)init
{
	self = [super init];
	if (self != nil) {
        searchEngineOperationqueue_ = dispatch_queue_create("com.touchpal.dialer.search.operation", NULL);
        CFStringRef specificValue = CFSTR("com.touchpal.dialer.search.operation");
        dispatch_queue_set_specific(searchEngineOperationqueue_, &specificKey, (void*)specificValue, NULL);
        
        searchEngineQueryqueue_ = dispatch_queue_create("com.touchpal.dialer.search.query", NULL);
        CFStringRef queryValue = CFSTR("com.touchpal.dialer.search.query");
        dispatch_queue_set_specific(searchEngineOperationqueue_, &queryKey, (void*)queryValue, NULL);

        
		searchEngine = new ContactEngine();
	}
	return self;
}

- (void)initCallerTellSearch
{
    cityFileIDDictionary = [[NSMutableDictionary alloc] init];
    cityDictionary = [[NSMutableDictionary alloc] init];
    
    [self initNationData];
    
    NSArray *citys = [CityDataDBA queryAllInstallCity];
    NSMutableArray *deleteInstallCitys = [NSMutableArray arrayWithCapacity:1];
    for (int i =0; i<[citys count]; i++) {
        YellowCityModel *city =[citys objectAtIndex:i];
        if ([self isValidCity:city]) {
            [self addCitySearchData:city];
        }else{
            [deleteInstallCitys addObject:city];
        }
    }
    if ([deleteInstallCitys count] > 0) {
        [CityDataDBA deleteInstallCitys:citys];
    }
}

+ (void)copyFile:(NSString *)fileName
            from:(NSString *)filePath
              to:(NSString *)targetPath
      useManager:(NSFileManager*) fileManager
{
    NSString *toFilepath = [NSString stringWithFormat:@"%@/%@.img",targetPath, fileName];
    NSString *fromFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@/%@",filePath,fileName]
                                                             ofType:@"img"];
    if([fileManager fileExistsAtPath:toFilepath]) {
        [fileManager removeItemAtPath:toFilepath error:nil];
    }
    if([fileManager fileExistsAtPath:fromFilePath]) {
        [fileManager copyItemAtPath:fromFilePath toPath:toFilepath error:nil];
    }
}

- (void)initNationData
{
    //nation
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *relativePath = [YellowCityDataManager relativePathCityData:KEY_NATIONAL_ID];
    NSString *filePath = [YellowCityDataManager sourcePathCityData:relativePath];
    YellowCityModel *city = [CityDataDBA queryInstallCityById:KEY_NATIONAL_ID];
    if (!city|| ![fileManager fileExistsAtPath:filePath] ||
        [city.mainVersion integerValue] < [DEFALUT_NATION_DATA_VERSION integerValue]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        [OrlandoEngine copyFile:@"number" from:@"yellowpagedata" to:filePath useManager:fileManager];
        [OrlandoEngine copyFile:@"numberUpdate" from:@"yellowpagedata" to:filePath useManager:fileManager];

        
        NSString *imageToDir = [NSString stringWithFormat:@"%@/image",filePath];
        NSString *imageFormDir = [[NSBundle mainBundle] pathForResource:@"yellowpagedata/image" ofType:@""];
        NSArray*files = [fileManager subpathsOfDirectoryAtPath:imageFormDir error:nil];
        [fileManager createDirectoryAtPath:imageToDir withIntermediateDirectories:YES attributes:nil error:nil];
        for (NSString *file in files)
        {
            NSString *to = [NSString stringWithFormat:@"%@/%@",imageToDir,file];
            NSString *from = [NSString stringWithFormat:@"%@/%@",imageFormDir,file];
            [fileManager removeItemAtPath:to error:nil];
            [fileManager copyItemAtPath:from toPath:to error:nil];
        }
        
        YellowCityModel *cityNation = [[YellowCityModel alloc] init];
        cityNation.cityID = KEY_NATIONAL_ID;
        cityNation.cityName = KEY_NATION_NAME;
        cityNation.mainPath = relativePath;
        cityNation.mainSize = DEFALUT_NATION_DATA_SIZE;
        cityNation.mainVersion = DEFALUT_NATION_DATA_VERSION;
        cityNation.updatePath = relativePath;
        cityNation.updateVersion  = DEFALUT_NATION_DATA_VERSION;
        cityNation.updateSize = DEFALUT_NATION_DATA_SIZE;
        cityNation.isDown = YES;
        if (!city) {
            [CityDataDBA insertCity:cityNation];
        }else{
            [CityDataDBA updateCity:cityNation];
        }
    }
}

- (void)excuteOperateEngine:(void (^)(void))block
{
    dispatch_queue_t q = searchEngineOperationqueue_;
    if(q == NULL || dispatch_get_specific(&specificKey)){
        block();
    }else {
        dispatch_async(q, ^() {
            block();
        });
    }
}

- (void)excuteQueryEngine:(void (^)(void))block
{
    dispatch_queue_t q = searchEngineQueryqueue_;
    if(q == NULL || dispatch_get_specific(&queryKey)){
        block();
    }else {
        dispatch_sync(q, ^() {
            @try {
                block();
            }
            @catch (NSException *exception) {
                cootek_log(@"orlando exception when query");
            }
        });
    }
}

- (BOOL)isValidCity:(YellowCityModel *)city
{
    NSString *relativePathCityData = [YellowCityDataManager relativePathCityData:city.cityID];
    NSString *fileFolder = [YellowCityDataManager sourcePathCityData:relativePathCityData];
    return [[NSFileManager defaultManager] fileExistsAtPath:fileFolder];
}

- (void)addCitySearchData:(YellowCityModel *)city
{
    YellowFileModel *file =[[YellowFileModel alloc] init];
    
    if ([city.mainPath length] > 0) {
        NSString* folderPath = [YellowCityDataManager sourcePathCityData:city.mainPath];
        [file openFile:@"number.img" inFolder:folderPath forIndex:orlando::calleridFile];
    }
    if ([city.updatePath length] > 0) {
        NSString* folderPath = [YellowCityDataManager sourcePathCityData:city.updatePath];
        [file openFile:@"numberUpdate.img" inFolder:folderPath forIndex:orlando::delta_calleridFile];
    }
    if (!file.isValid) {
        [file closeAllFiles];
        return;
    }
    
    FileDescription fd;
    for(int i=0; i < orlando::file_size; i++) {
        fd.files[i] = [file fileAtIndex:i];
    }
    if ([city.cityID isEqualToString:KEY_NATIONAL_ID]) {
        fd.type = CountryYellowPage;
    }else {
        fd.type = CityYellowPage;
    }
    
    [self excuteOperateEngine:^(){
        file.fileID = searchEngine->CreatFile(fd);
    }];
    if ([city.cityID isEqualToString:KEY_NATIONAL_ID]) {
        nationId = file.fileID;
    }
    [cityDictionary setObject:file forKey:city.cityID];
    [cityFileIDDictionary setObject:city.cityID forKey:[NSNumber numberWithInt:file.fileID]];
}

- (void)closeCityFile:(NSString *)cityID
{
    YellowFileModel *file =  [cityDictionary objectForKey:cityID];
    [file closeAllFiles];
}
- (void)closeAllCityFile
{
    NSArray *allKey =[cityDictionary allKeys];
    for (NSString *key in allKey) {
        [self closeCityFile:key];
    }
}
- (void)deleteFile:(NSInteger)fileID{
    [self excuteOperateEngine:^(){
        searchEngine->DeleteFile(fileID);
    }];
}

- (CallerIDInfoModel *)queryCallerIDByNumber:(NSString *)number
{
    if(!SmartDailerSettingModel.isChinaSim){
        return nil;
    }
    u16string str = CStringUtils::nsstr2u16str(number);
    SearchResult_CallerID *callerIDResult = new SearchResult_CallerID();
    __block BOOL isExitis = NO;
    [self excuteQueryEngine:^(){
        isExitis = searchEngine->GetCallerIDInfo(callerIDResult,str);
    }];
    CallerIDInfoModel *callerID  = nil;
    
    if (isExitis) {
        callerID = [[CallerIDInfoModel alloc] init];
        callerID.number = number;
        callerID.name = CStringUtils::u16str2nsstr(callerIDResult->getName());
        callerID.callerType = CStringUtils::u16str2nsstr(callerIDResult->getClassifyType());
        callerID.markCount = 0;
        callerID.callerIDCacheLevel = CallerIDQueryLocalLevel;
        callerID.versionTime = [NSString stringWithFormat:@"%llu",callerIDResult->GetDataTime()];
        if(callerIDResult->IsVip()){
            callerID.vipID = callerIDResult->GetVipInfo().ID;
        }
           } else {
        //luchenAdded
    }
    
    delete callerIDResult;
    return callerID;
}
- (void)ClearResultList:(vector<ISearchResult*>)result_list
{
    //消除内存
	vector<ISearchResult*>::iterator it;
	for(it = result_list.begin(); it != result_list.end(); it++) {
		delete (*it);
	}
	result_list.clear();
}
-(NSMutableArray *)queryByContractName:(NSString *)content
                             hasNumber:(BOOL)isNumber
{
    content=[content lowercaseString];
	u16string str = CStringUtils::nsstr2u16str(content);
    
    __block vector<ISearchResult*> result_list;
    [self excuteQueryEngine:^(){
        searchEngine->Query(str,result_list,YES,isNumber);
    }];
    
	NSMutableArray *resultArray = [[NSMutableArray alloc]init];
	int result_count = result_list.size();
	if (result_count<=0) {
		return resultArray;
	}
	for (int i=0; i<result_count; i++) {
		EngineResultModel* result_item=[[EngineResultModel alloc] init];
		result_item.personID = (NSInteger)result_list[i]->getId();
		result_item.name = CStringUtils::u16str2nsstr(result_list[i]->getName());
		vector<int> vHitinfo = result_list[i]->getHitInfo();
		int iHitInfoCount = vHitinfo.size();
		for (int j=0; j<iHitInfoCount;j++) {
			NSNumber *num=[NSNumber numberWithInt:(NSInteger)vHitinfo[j]];
			[result_item.hitNameInfo addObject:num];
		}
        result_item.hitType = (NSInteger)result_list[i]->getHitType();
		[resultArray addObject:result_item];
	}
	//消除内存
	[self ClearResultList:result_list];
	return resultArray;
}

- (NSInteger)calcuWeightByPersonID:(NSInteger)personID
{
	CallCountModel *contactCallCount = [CallLogDBA callCountReturnByPersonID:personID];
	return [self calcuWeight:contactCallCount];
}
- (NSInteger)calcuWeight:(CallCountModel *)contactCallCount{
	int weight = 0;
	if (contactCallCount.callCount>0) {
		NSInteger currentTime = [[NSDate date] timeIntervalSince1970];
		NSInteger days = (currentTime -contactCallCount.callTime)/(24*3600);
		weight= contactCallCount.callCount;
		if (days<60) {
			weight = weight +(60-days);
		}
	}
	return weight;
}

- (void)updateContactWeightToEngine:(NSInteger)recordId
                             weight:(NSInteger)weight
{
     [self excuteOperateEngine:^(){
        const IContactRecord *contactsRecord = searchEngine->getContactRecord(recordId);
        if (contactsRecord) {
            searchEngine->updateContact(recordId,
                                        contactsRecord->getName(),
                                        weight,
                                        contactsRecord->getAccountId(),
                                        contactsRecord->isVisible(),
                                        contactsRecord->hasPhoneNumber());
        }
     }];
}

- (void)addContactToEngine:(NSInteger)recordId
                  fullName:(NSString *)fullName
                 hasNumber:(BOOL)hasNumber
{
     [self excuteOperateEngine:^(){
        searchEngine->addContactandIndex(recordId,
                                         CStringUtils::nsstr2u16str(fullName),
                                         0,
                                         0,
                                         true,
                                         hasNumber);
     }];
}
- (void)initContactToEngine:(NSInteger)recordId
                   fullName:(NSString *)fullName
                  hasNumber:(BOOL)hasNumber
{
	searchEngine->addContactandIndex(recordId,
                                     CStringUtils::nsstr2u16str(fullName),
                                     0,
                                     0,
                                     true,
                                     hasNumber);
}
- (void)updateContactToEngine:(NSInteger)recordId
                  fullName:(NSString *)fullName
                 hasNumber:(BOOL)hasNumber
{
     [self excuteOperateEngine:^(){
        searchEngine->updateContact(recordId,
                                    CStringUtils::nsstr2u16str(fullName),
                                    [self calcuWeightByPersonID:recordId],
                                    0,
                                    true,
                                    hasNumber);
     }];
}

- (void)deleteContactByPersonID:(NSInteger)personID{
    [self excuteOperateEngine:^(){
        searchEngine->deleteContact(personID);
    }];
}

- (void)addNumberToContact:(NSInteger)personID
                withNumber:(NSString *)number
               withPhoneID:(NSInteger)phoneID{
     [self excuteOperateEngine:^(){
        searchEngine->addPhoneNumber(phoneID,
                                     personID,
                                     CStringUtils::nsstr2u16str(number),
                                     CStringUtils::nsstr2u16str(@""),
                                     YES);
     }];
}
- (void)initNumberToContact:(NSInteger)personID
                 withNumber:(NSString *)number
                withPhoneID:(NSInteger)phoneID
{
    [self excuteOperateEngine:^(){
        searchEngine->addPhoneNumber(phoneID,
                                     personID,
                                     CStringUtils::nsstr2u16str(number),
                                     CStringUtils::nsstr2u16str(@""),
                                     YES);
    }];
}

- (void)deleteNumberToContact:(NSString *)number
                    contactID:(NSInteger)contactID
                      phoneID:(NSInteger)phoneID
{
      [self excuteOperateEngine:^(){
        searchEngine->deletePhoneNumber(phoneID,
                                        contactID,
                                        CStringUtils::nsstr2u16str(number));
      }];
}

- (void)initSmartSearchIndex:(NSMutableArray *)searchKeyArray
               personIdArray:(NSMutableArray *)personIdArray
                hitTypeArray:(NSMutableArray *)hitTypeArray
           clickedTimesArray:(NSMutableArray *)clickedTimesArray
{
    [self excuteOperateEngine:^{
        vector<u16string> keyList;
        vector<long> contactIdList;
        vector<int> hitTypeList;
        vector<int> clickedTimesList;
        
        for(NSString* searchKey in searchKeyArray) {
            keyList.push_back(CStringUtils::nsstr2u16str(searchKey));
        }
        for(NSNumber* personId in personIdArray) {
            contactIdList.push_back([personId longValue]);
        }
        for(NSNumber* hitType in hitTypeArray) {
            hitTypeList.push_back([hitType intValue]);
        }
        for(NSNumber* clickedTimes in clickedTimesArray) {
            clickedTimesList.push_back([clickedTimes intValue]);
        }
        searchEngine->initSmartSearchIndex(keyList, contactIdList, clickedTimesList, hitTypeList);
    }];
}

- (void)increaseContactClickedTimesToEngine:(NSString *)query
                                   recordID:(NSInteger)recordID
                                    hitType:(NSInteger)hitType
{
    [self excuteOperateEngine:^{
        searchEngine->increaseContactClickedTimes(CStringUtils::nsstr2u16str(query),
                                                  recordID,
                                                  hitType);
    }];
}


- (NSInteger)queryNumberToContact:(NSString *)number
                       withLength:(NSInteger)length
{
    __block vector<long> id_list;
    [self excuteQueryEngine:^(){
        searchEngine->queryPhoneNuber(CStringUtils::nsstr2u16str(number),length,id_list);
    }];
    int result_count = id_list.size();
    NSInteger personID = -1;
    if (result_count > 0) {
        personID = (int)id_list[0];
    }
    id_list.clear();
    return personID;
}

-(NSArray *)getCityGroup{
    int count = searchEngine->getCityCount();
    CityResult** cityGroups = new CityResult*[count];
    for (int i=0; i< count; i++) {
        cityGroups[i] = new CityResult();
    }
    [self excuteQueryEngine:^(){
         searchEngine->getCityGroups(cityGroups, count);
    }];
   
    vector<ICityGroup *>::iterator it;
    NSMutableArray *cityGroupArray = [[NSMutableArray alloc] initWithCapacity:count+1];
    
    for(int i=0; i< count; i++){
        CityResult *group = cityGroups[i];
        if (group->get_cityname().length() == 0) {
            continue;
        }
        NSString *cityName = CStringUtils::u16str2nsstr(group->get_cityname());
        set<long> ids = group->get_contacts();
        NSMutableArray *idsArray = [[NSMutableArray alloc] initWithCapacity:ids.size()];
        set<long>::iterator ids_it = ids.begin();
        for(;ids_it!=ids.end();ids_it++){
            NSNumber *contactId = [NSNumber numberWithLong:*ids_it];
            [idsArray addObject:contactId];
        }
        CityGroupModel *cityGroupModel = [[CityGroupModel alloc] init];
        cityGroupModel.cityName = cityName;
        cityGroupModel.contactIDs = idsArray;
        [cityGroupArray addObject:cityGroupModel];
    }
    for (int i=0; i< count; i++) {
        delete cityGroups[i];
    }
    delete [] cityGroups;
    return cityGroupArray;
}

- (void)clearCityGroups{

}

-(void)dealloc
{
	delete searchEngine ;
}
@end
