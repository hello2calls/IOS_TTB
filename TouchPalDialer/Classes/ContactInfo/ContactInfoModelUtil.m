//
//  ContactInfoModelManager.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/20.
//
//

#import "ContactInfoModelUtil.h"
#import "TPDialerResourceManager.h"
#import "ContactCacheDataManager.h"
#import "ContactInfoUtil.h"
#import "Person.h"
#import "NSString+TPHandleNil.h"
#import "NSString+PhoneNumber.h"
#import "IMDataModel.h"
#import "PhoneNumber.h"
#import "GroupDataModel.h"
#import "ContactGroupDBA.h"
#import "Group.h"
#import "ContactInfoCellModel.h"
#import "CallLog.h"
#import "SmartDailerSettingModel.h"
#import "CallerIDModel.h"
#import "ContactHistoryInfo.h"
#import "UserDefaultsManager.h"
#import "TouchpalMembersManager.h"

@implementation ContactInfoModelUtil

+ (ContactInfoModel *)getContactInfoModelByPersonId:(NSInteger)personId{
    ContactInfoModel *info = [[ContactInfoModel alloc]init];
    info.personId = personId;
    info.infoType = knownInfo;
    info.photoImage = [ContactInfoUtil getPhotoImageByPersonId:personId];
    info.bgImage = [ContactInfoUtil getBgImageByPersonId:personId];
    ContactCacheDataModel *person = [Person getConatctInfoByRecordID:personId];
    
    if ( person ){
        info.firstStr = [person displayName];
        NSString *company = [NSString nilToEmptyTrimmed:[person company]];
        NSString *department = [NSString nilToEmptyTrimmed:[person department]];
        NSString *jobtitle = [NSString nilToEmptyTrimmed:[person jobTitle]];
        NSString *secondStr = company;
        if ( department.length > 0 ){
            if ( secondStr.length > 0 )
                secondStr = [NSString stringWithFormat:@"%@ %@",secondStr,department];
            else
                secondStr = department;
        }
        if ( jobtitle.length > 0 ){
            if ( secondStr.length > 0 )
                secondStr = [NSString stringWithFormat:@"%@ %@",secondStr,jobtitle];
            else
                secondStr = jobtitle;
        }
        info.secondStr = secondStr;
    }
    return info;
}

+ (ContactInfoModel *)getContactInfoModelByPhoneNumber:(NSString *)phoneNumber{
    ContactInfoModel *info = [[ContactInfoModel alloc]init];
    info.phoneNumber = phoneNumber;
    info.infoType = unknownInfo;
    info.photoImage = [ContactInfoUtil getPhotoImageByPhoneNumber:phoneNumber];
    info.bgImage = [ContactInfoUtil getBgImageByPersonId:-1];
    info.firstStr = phoneNumber;
    info.secondStr = [[PhoneNumber sharedInstance] getNumberAttribution:phoneNumber
                                                               withType:attr_type_normal];
    if([SmartDailerSettingModel isChinaSim]){
        CallerIDInfoModel *model = [CallerIDModel queryCallerIDByNumber:phoneNumber];
        if(model.isCallerIdUseful){
            if ( model.name.length != 0 ){
                info.firstStr = model.name;
                info.secondStr = phoneNumber;
            }
            if ( model.callerType != nil && model.callerType.length != 0 ){
                NSString *callerTypeStr = NSLocalizedString(model.callerType,"");
                if ( callerTypeStr != nil && callerTypeStr.length > 0 ){
                    info.secondStr = [NSString stringWithFormat:@"%@ %@",info.secondStr,callerTypeStr];
                }
            }
        }
    }
    return info;
}

+ (NSArray *)getPhoneNumberArrayByPhoneNumber:(NSString *)phoneNumber{
    ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
    info.mainStr = phoneNumber;
    info.subStr = [[PhoneNumber sharedInstance] getNumberAttribution:phoneNumber
                                                            withType:attr_type_normal];;
    info.cellType = CellPhone;
    return [NSArray arrayWithObject:info];
}

+ (NSArray *)getPhoneNumberArrayByPersonId:(NSInteger)personId{
    NSMutableArray *array = [NSMutableArray array];
    if (personId <= 0)
        return array;
    ContactCacheDataModel *model= [Person getConatctInfoByRecordID:personId];
    if (model == nil) {
        return array;
    }
    // phone - NSArray of NSDictionary
    NSArray *phoneModels = [model abAddressBookPhones];
    for (LabelDataModel *model in phoneModels) {
        NSString *value = [[NSString nilToEmptyTrimmed:model.labelValue] formatPhoneNumber];
        NSString *type = [NSString nilToEmptyTrimmed:model.labelKey];
        NSString *locationAttr = [NSString nilToEmptyTrimmed:[[PhoneNumber sharedInstance] getNumberAttribution:value]];
        if ([locationAttr length] != 0) {
            type = [NSString stringWithFormat:@"%@ (%@)", type,locationAttr];
        }
        
        ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
        info.mainStr = value;
        info.subStr = type;
        info.cellType = CellPhone;
        [array addObject:info];
    }
    
    ContactInfoCellModel *faceTimeInfo = [[ContactInfoCellModel alloc]init];
    faceTimeInfo.mainStr = @"FaceTime";
    faceTimeInfo.cellType = CellFaceTime;
    [array addObject:faceTimeInfo];
    
    
    return array;
}

+ (NSArray *)getSubArrayByPersonId:(NSInteger)personId{
    NSMutableArray *array = [NSMutableArray array];
    if (personId <= 0)
        return array;
    ContactCacheDataModel *model = [Person getConatctInfoByRecordID:personId];
    if (model == nil) {
        return array;
    }
    
    // email - NSArray of NSDictionary
    NSArray *emailModels = [model emails];
    for (LabelDataModel *model in emailModels) {
        NSString *value = [NSString nilToEmptyTrimmed:model.labelValue];
        NSString *type = [NSString nilToEmptyTrimmed:model.labelKey];
        if ( type == nil || type.length == 0 )
            type = NSLocalizedString(@"contact_info_email", @"");
        
        ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
        info.mainStr = value;
        info.subStr = type;
        info.cellType = CellEmail;
        [array addObject:info];
    }
    
    // birthday - NSString
    NSString *birthday = [NSString nilToEmptyTrimmed:[model birthday]];
    if ([birthday length] != 0) {
        ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
        info.mainStr = birthday;
        info.subStr = NSLocalizedString(@"Birthday", @"");;
        info.cellType = CellData;
        [array addObject:info];
    }
    
//    // date - NSArray of NSString
//    NSArray *dateModels = [model dates];
//    for (LabelDataModel *model in dateModels) {
//        NSString *dateStr = model.labelValue;
//        NSString *type = NSLocalizedString(@"Date", @"");
//        
//        ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
//        info.mainStr = dateStr;
//        info.subStr = type;
//        info.cellType = CellData;
//        [array addObject:info];
//    }
    
    
    // group - NSArray of NSString
    NSArray* personGroupIds = [ContactGroupDBA getMemberGroups:personId];
    NSMutableArray *groups = [NSMutableArray array];
    for (NSNumber* item in personGroupIds) {
        GroupDataModel *group = [Group getGroupByGroupID:[item intValue]];
        if (group) {
            [groups addObject:[NSString nilToEmptyTrimmed:group.groupName]];
        }
    }
    
    NSString *groupMainStr = nil;
    if ([groups count] == 0) {
        groupMainStr = NSLocalizedString(@"Edit groups", @"");
    } else {
        NSMutableString *groupString = [NSMutableString stringWithCapacity:16];
        for (NSString *str in groups) {
            if ([groupString isEqualToString:@""]) {
                [groupString appendFormat:@"%@", str];
            } else {
                [groupString appendFormat:@", %@", str];
            }
        }
        groupMainStr = groupString;
    }
    ContactInfoCellModel *groupInfo = [[ContactInfoCellModel alloc]init];
    groupInfo.mainStr = groupMainStr;
    groupInfo.subStr = NSLocalizedString(@"Groups", @"");
    groupInfo.cellType = CellGroup;
    if (![UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        [array addObject:groupInfo];
    }
    
    // note - NSString
    NSString *note = [NSString nilToEmptyTrimmed:[model note]];
    if ([note length] == 0)
        note = NSLocalizedString(@"Edit note", @"");
    ContactInfoCellModel *noteInfo = [[ContactInfoCellModel alloc]init];
    noteInfo.mainStr = note;
    noteInfo.subStr = NSLocalizedString(@"Note", @"");
    noteInfo.cellType = CellNote;
    [array addObject:noteInfo];
    
    // url - NSArray of NSDictionary
    NSArray *urlModels = [model URLs];
    for (LabelDataModel *model in urlModels) {
        NSString *value = [NSString nilToEmptyTrimmed:model.labelValue];
        NSString *type = [NSString nilToEmptyTrimmed:model.labelKey];
        NSString *browserurl = value;
        NSRange range = [browserurl rangeOfString:@"://"];
        if (range.location == NSNotFound) {
            browserurl = [NSString stringWithFormat:@"http://%@", value];
        }
        if ( type == nil || type.length == 0 )
            type = NSLocalizedString(@"contact_info_url", @"");;
        ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
        info.mainStr = value;
        info.subStr = type;
        info.url = browserurl;
        info.cellType = CellUrl;
        [array addObject:info];
    }
    
    // address - NSArray of NSDictionary
    NSArray *addressModels = [model address];
    for (LabelDataModel *model in addressModels) {
        NSString *value = [NSString nilToEmptyTrimmed:model.labelValue];
        NSString *type = [NSString nilToEmptyTrimmed:model.labelKey];
        NSString *googleMapUrlPattern = @"http://maps.google.com/maps?q=";
        NSString *browserurl = [NSString stringWithFormat:@"%@%@",googleMapUrlPattern,
                                [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ( type == nil || type.length == 0 )
            type = NSLocalizedString(@"contact_info_address", @"");
        ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
        info.mainStr = value;
        info.subStr = type;
        info.url = browserurl;
        info.cellType = CellAddress;
        [array addObject:info];
    }
    
    
    // local social profiles - NSArray of NSDictionary
    NSArray *localSocialModels = [model localSocialProfiles];
    for (NSDictionary* snsInfo in localSocialModels) {
        NSString *servicetype = [snsInfo objectForKey:@"servicetype"];
        ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
        info.mainStr = [snsInfo objectForKey:@"username"];
        info.cellType = CellSNS;
        info.url = [snsInfo objectForKey:@"url"];
        [array addObject:info];
        if ([servicetype isEqualToString:@"weibo"]) {
            info.subStr = NSLocalizedString(@"Sina Weibo", @"");
        } else if([servicetype isEqualToString:@"facebook"]){
            info.subStr = NSLocalizedString(@"Facebook", @"");
        } else if([servicetype isEqualToString:@"twitter"]){
            info.subStr = NSLocalizedString(@"Twitter", @"");
        }
    }
    
    // im - NSArray of NSString
    NSArray *imModels = [model IMs];
    for (LabelDataModel *model in imModels) {
        IMDataModel *imDataModel = (IMDataModel *)model.labelValue;
        NSString *userName = [NSString nilToEmptyTrimmed:imDataModel.username];
        NSString *service = [NSString nilToEmptyTrimmed:imDataModel.service];
        NSString *imStr;
        if ([userName length] == 0) {
            imStr = service;
        } else {
            imStr = [NSString stringWithFormat:@"%@ (%@)",service,userName];
        }
        ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
        info.mainStr = imStr;
        info.subStr = NSLocalizedString(@"IM", @"");
        info.cellType = CellIM;
        [array addObject:info];
    }
    
    // relatednames - NSArray of NSDictionary
    NSArray *relatedModels = [model relatedNames];
    for (LabelDataModel *model in relatedModels) {
        NSString *value = [NSString nilToEmptyTrimmed:model.labelValue];
        NSString *type = [NSString nilToEmptyTrimmed:model.labelKey];
        ContactInfoCellModel *info = [[ContactInfoCellModel alloc]init];
        info.mainStr = value;
        info.subStr = type;
        info.cellType = CellOther;
        [array addObject:info];
    }
    
    return array;
}

+ (NSArray *)getShareArrayByPersonId:(NSInteger)personId{
    NSMutableArray *array = [NSMutableArray array];
    if (personId <= 0)
        return array;
    ContactCacheDataModel *model= [Person getConatctInfoByRecordID:personId];
    if (model == nil) {
        return array;
    }
    
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        BOOL isRegistered = NO;
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        for (PhoneDataModel *phone in personData.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
            if (resultCode == 1){
                isRegistered = YES;
            }
        }
        
        if (!isRegistered) {
            
            
            if (personData.phones == nil || personData.phones.count == 0) {
                return nil;
            }
            
            
            
            PhoneDataModel * phoneDate = [personData.phones objectAtIndex:0];
            
            
            
            if (phoneDate.number.length>0 && [phoneDate.number hasPrefix:@"0"]) {
                return  nil;
            }
            ContactInfoCellModel *invitingInfo = [[ContactInfoCellModel alloc]init];
            invitingInfo.mainStr = NSLocalizedString(@"invite_friends", @"邀请有奖");
            invitingInfo.subStr = @"好友通话不扣时长，邀请还送200分钟";
            invitingInfo.cellType = CellInviting;
            [array addObject:invitingInfo];
        }
        cootek_log(@"isInContact: %b", isRegistered);
    }
    return array;
}

+ (NSArray *)getShareArrayByPhoneNumber:(NSString *)phoneNumber{
    if ([phoneNumber hasPrefix:@"0"]) {
            return  nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    ContactInfoCellModel *invitingInfo = [[ContactInfoCellModel alloc]init];
    invitingInfo.mainStr = NSLocalizedString(@"invite_friends", @"邀请有奖");
    invitingInfo.subStr = @"好友通话不扣时长，邀请还送200分钟";
    invitingInfo.cellType = CellInviting;
    [array addObject:invitingInfo];
    return array;
}


+ (NSArray *)getCallListByPersonId:(NSInteger)personId{
    NSArray *callDataList = [self getCallDataListByPersonId:personId];
    return [self generateCallLogList:callDataList];
}

+ (NSArray *)getCallListByPhoneNumber:(NSString *)phoneNumber{
    NSArray *callDataList = [self getCallDataListtByPhoneNumber:phoneNumber];
    return [self generateCallLogList:callDataList];
}

+ (NSArray *)getCallDataListtByPhoneNumber:(NSString *)phoneNumber{
    WhereDataModel *condition=[[WhereDataModel alloc] init];
    condition.fieldKey=[DataBaseModel getKWhereKeyPhoneNumber];
    condition.oper=[DataBaseModel getKWhereOperationLike];
    NSString *number = [[PhoneNumber sharedInstance] getOriginalNumber:phoneNumber];
    condition.fieldValue=[DataBaseModel getFormatNumber:number];
    cootek_log(@"original number = %@",number);
    
    NSMutableArray* where_array=[[NSMutableArray alloc] init];
    [where_array addObject:condition];
    condition=[[WhereDataModel alloc] init];
    condition.fieldKey=[DataBaseModel getKWhereKeyPersonID];
    condition.oper=[DataBaseModel getKWhereOperationEqual];
    condition.fieldValue=[NSString stringWithFormat:@"%d",-1];
    [where_array addObject:condition];
    //order by
    LabelDataModel *order_by=[[LabelDataModel alloc] init];
    order_by.labelKey=[DataBaseModel getKOrderByKeyCallTime];
    order_by.labelValue=[DataBaseModel getKOrderByKeyValueDesc];
    NSMutableArray* order_array=[[NSMutableArray alloc] init];
    [order_array addObject:order_by];
    
    NSArray *result = [CallLog calllogsByCondition:where_array
                                      OrderByCause:order_array];
    
    NSString *number_inter = [[PhoneNumber sharedInstance] getNormalizedNumber:phoneNumber] ;
    NSMutableArray *tmp_array = [NSMutableArray arrayWithCapacity:1];
    for (int i =0; i<[result count]; i++) {
        CallLogDataModel *call_log = [result objectAtIndex:i];
        if ([[[PhoneNumber sharedInstance] getNormalizedNumber:call_log.number] hasSuffix:number_inter]) {
            [tmp_array addObject:call_log];
        }
    }
    
    return tmp_array;
}

+ (NSArray *)getCallDataListByPersonId:(NSInteger)personId{
    //where
    WhereDataModel *condition=[[WhereDataModel alloc] init];
    condition.fieldKey=[DataBaseModel getKWhereKeyPersonID];
    condition.oper=[DataBaseModel getKWhereOperationEqual];
    condition.fieldValue=[NSString stringWithFormat:@"%d",personId];
    NSMutableArray* where_array=[[NSMutableArray alloc] init];
    [where_array addObject:condition];
    //order by
    LabelDataModel *order_by=[[LabelDataModel alloc] init];
    order_by.labelKey=[DataBaseModel getKOrderByKeyCallTime];
    order_by.labelValue=[DataBaseModel getKOrderByKeyValueDesc];
    NSMutableArray* order_array=[[NSMutableArray alloc] init];
    [order_array addObject:order_by];
    
    NSArray * calllog_list = [CallLog calllogsByCondition:where_array
                                             OrderByCause:order_array];
    
    return calllog_list;
}

+ (NSArray *)generateCallLogList:(NSArray *)callDataList{
    NSMutableArray *array = [NSMutableArray array];
    
    for ( int i = 0 ; i < callDataList.count ; i ++ ){
        CallLogDataModel *item = [callDataList objectAtIndex:i];
        
        NSString *_dateStr = [ContactInfoUtil getDateStr:item.callTime];
        
        if ( array.count == 0 ){
            ContactHistoryInfo *info = [[ContactHistoryInfo alloc]init];
            info.dateStr = _dateStr;
            [info.dateArray addObject:item];
            [array addObject:info];
        }else{
            ContactHistoryInfo *info = [array objectAtIndex:array.count-1];
            if ( [info.dateStr isEqualToString:_dateStr] ){
                [info.dateArray addObject:item];
            }else{
                ContactHistoryInfo *info = [[ContactHistoryInfo alloc]init];
                info.dateStr = _dateStr;
                [info.dateArray addObject:item];
                [array addObject:info];
            }
        }
    }
    
    return array;
}

@end
