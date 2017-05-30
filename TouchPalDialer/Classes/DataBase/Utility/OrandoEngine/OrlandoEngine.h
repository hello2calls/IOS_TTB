//
//  OrlandoEngine.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//


#import <Foundation/Foundation.h>
#import "CallCountModel.h"
#import "YellowCityModel.h"
#import "BasicUtil.h"
#import "CallerIDInfoModel.h"

#define INDEX_PHONEPAD  1
#define INDEX_CONTACT   2
#define INDEX_ALL       0

@interface OrlandoEngine : NSObject {
    int nationId;
    NSMutableDictionary *cityDictionary;
    NSMutableDictionary *cityFileIDDictionary;
    dispatch_queue_t searchEngineOperationqueue_;
    dispatch_queue_t searchEngineQueryqueue_;
}
+ (OrlandoEngine*)instance;

- (void)excuteOperateEngine:(void (^)(void))block;
- (void)excuteQueryEngine:(void (^)(void))block;

- (void)addContactToEngine:(NSInteger)recordId
                  fullName:(NSString *)fullName
                 hasNumber:(BOOL)hasNumber;

- (void)initContactToEngine:(NSInteger)recordId
                  fullName:(NSString *)fullName
                 hasNumber:(BOOL)hasNumber;


- (void)deleteContactByPersonID:(NSInteger)personID;

- (void)updateContactToEngine:(NSInteger)recordId
                     fullName:(NSString *)fullName
                    hasNumber:(BOOL)hasNumber;

- (void)updateContactWeightToEngine:(NSInteger)recordId
                             weight:(NSInteger)weight;

- (void)addNumberToContact:(NSInteger)personID
                withNumber:(NSString *)number
               withPhoneID:(NSInteger)phoneID;

- (void)initNumberToContact:(NSInteger)personID
                withNumber:(NSString *)number
               withPhoneID:(NSInteger)phoneID;

- (void)deleteNumberToContact:(NSString *)number
                    contactID:(NSInteger)contactID
                      phoneID:(NSInteger)phoneID;

- (void)initSmartSearchIndex:(NSMutableArray*)searchKeyArray
               personIdArray:(NSMutableArray*)personIdArray
                hitTypeArray:(NSMutableArray*)hitTypeArray
           clickedTimesArray:(NSMutableArray*)clickedTimesArray;


- (void)increaseContactClickedTimesToEngine:(NSString *)query
                                   recordID:(NSInteger) recordID
                                    hitType:(NSInteger) hitType;


- (NSInteger)calcuWeight:(CallCountModel *)contactCallCount;

- (NSMutableArray *)queryByContractName:(NSString *)content
                              hasNumber:(BOOL)isNumber;

- (NSInteger)queryNumberToContact:(NSString *)number
                       withLength:(NSInteger)length;


//获取城市分组
- (NSArray *)getCityGroup;

- (void)clearCityGroups;

//黄页查找
- (void)initCallerTellSearch;

//unused
//- (CallerIDInfoModel *)queryCallerIDByNumber:(NSString *)number;

- (void)addCitySearchData:(YellowCityModel  *)city;

- (void)deleteFile:(NSInteger)fileID;

- (void)closeAllCityFile;

- (void)closeCityFile:(NSString *)cityID;



@end