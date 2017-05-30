//
//  TPSearch.m
//  TouchPalDialer
//
//  Created by lingmei xie on 12-12-3.
//
//

#import "TPSearch.h"
#import "CallLogDBA.h"
#import "CallLog.h"
#import "OrlandoEngine+Letter.h"
#import "ContactCacheDataManager.h"
#import "DialResultModel.h"
#import "NSString+PhoneNumber.h"
#import "ContractResultModel.h"
#import "ContactPropertyCacheManager.h"
#import "ContactPropertyCacheModel.h"
#import <AddressBook/ABPerson.h>
#import "IMDataModel.h"

@implementation NSMutableArray (HandleNilArray)

- (void)insertObjectsFromArray:(NSArray *)otherArray
{
    if (otherArray) {
        [self addObjectsFromArray:otherArray];
    }
}

@end

@implementation NSString (HandleQueryContent)

- (BOOL)isContentLetter
{
    for (int i=0 ; i<[self length]; i++) {
        unichar indexLetter = [self characterAtIndex:i];
        if(indexLetter < '0'||indexLetter >'9' )
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isQueryName
{
   return !([self length] == 1&&
    ([self isEqualToString:@"0"]
     ||[self isEqualToString:@"1"]
     ||[self isEqualToString:@"#"]
     ||[self isEqualToString:@"+"]
     ||[self isEqualToString:@"*"]));
}

- (NSRange)isContainString:(NSString *)target
{
	NSRange range=[target rangeOfString:self options:NSCaseInsensitiveSearch];
	if (range.length!=0) {
		return range;
	}
	int src_length=[self length];
	BOOL is_contain_CJK_src=NO;
	for (int i=0; i<src_length; i++) {
		int char_i=(int)[self characterAtIndex:i];
		//>=19968
		//<=40869
		if(char_i>=19968&&char_i<=40869)
		{
			is_contain_CJK_src=YES;
			break;
		}
	}
	int tar_length=[target length];
	BOOL is_contain_CJK_tar=NO;
	for (int i=0; i<tar_length; i++) {
		int char_i=(int)[target characterAtIndex:i];
		//>=19968
		//<=40869
		if(char_i>=19968&&char_i<=40869)
		{
			is_contain_CJK_tar=YES;
			break;
		}
	}
	if (is_contain_CJK_src==1&&is_contain_CJK_tar==1) {
		//NSLog(@"%@",src);
		//NSLog(@"%@",target);
		NSString *target_i=@"";
		NSString *src_i=@"";
		NSRange sub_str;
		sub_str.length=1;
		int tar_length=[target length];
		//除去特殊字符
		for (int i=0; i<tar_length; i++) {
			int char_i=(int)[target characterAtIndex:i];
	        sub_str.location=i;
			if (![OrlandoEngine isLetterOrDigit:char_i]) {
				target_i=[target_i stringByAppendingString:[target substringWithRange:sub_str]];
				//NSLog(@"target=%@",target_i);
			}
		}
		//除去特殊字符
		for (int i=0; i<src_length; i++) {
			int char_i=(int)[self characterAtIndex:i];
	        sub_str.location=i;
			if (![OrlandoEngine isLetterOrDigit:char_i]) {
				src_i=[src_i stringByAppendingString:[self substringWithRange:sub_str]];
			}
		}
		//NSLog(@"src=%@,target=%@",src_i,target_i);
		range=[target_i rangeOfString:src_i options:NSCaseInsensitiveSearch];
		//命中信息需处理
		if (range.length!=0) {
			NSString *first_letter=[src_i substringToIndex:1];
			NSString *last_letter=[src_i substringFromIndex:[src_i length]-1];
			NSRange temp;
			temp.length=1;
			for (int i=range.location; i<tar_length; i++)
			{
				temp.location=i;
				NSString *temp_first=[target substringWithRange:temp];
				if ([first_letter isEqualToString:temp_first]) {
					range.location=i;
					for (int j=i+range.length-1; j<tar_length;j++) {
						temp.location=j;
						NSString *temp_last=[target substringWithRange:temp];
						if ([last_letter isEqualToString:temp_last]) {
							range.length=j-i+1;
							return range;
						}
					}
				}
                
			}
		}
		return range;
	}else {
		return range;
	}
}
@end

@implementation TPDefaultSearch

@synthesize dataSource;

- (SearchResultModel *)wrapResults:(NSArray *)records
                        serachKey:(NSString *)key
{
    return nil;
}

- (SearchResultModel *)wrapResults:(NSArray *)records
                         serachKey:(NSString *)key
                        searchType:(SearchType)type
{
    SearchResultModel *search_result = [[SearchResultModel alloc] init];
    search_result.searchKey = key;
    search_result.searchType = type;
    NSMutableArray *tmpSearchResults = [[NSMutableArray alloc] initWithArray:records];
    search_result.searchResults = tmpSearchResults;
    return search_result;
    
}

-(NSArray *)completeQuery:(NSArray *)records
{
    return records;
}

-(BOOL)isExcuteQuery:(NSString *)content
               count:(NSInteger)count
{
    return ([content length] > 0);
}

-(NSArray *)query:(NSString *)content
{
    return nil;
}

-(NSArray *)removeRepeatRecord:(NSArray *)records
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:1];
    for (SearchItemModel *item in records) {
        if (item.personID > 0) {
            SearchItemModel *tmpItem = [resultDic objectForKey:[NSNumber numberWithInt:item.personID]];
            if (!tmpItem) {
                [results addObject:item];
                [resultDic setObject:item forKey:[NSNumber numberWithInt:item.personID]];
            }else{
                if (tmpItem.attributeID == kABPersonPhoneProperty) {
                    [results addObject:item];
                    [resultDic setObject:item forKey:[NSNumber numberWithInt:item.personID]];
                }
            }
        }else{
            [results addObject:item];
        }
    }
    return results;
}
@end

@implementation TPNameSearch

- (NSArray *)completeQuery:(NSArray *)records
{
    NSMutableDictionary *old_result_list=[NSMutableDictionary dictionaryWithCapacity:1];
	NSMutableArray *result_list=[NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *calllogdic = [CallLog getPersonCallLogList];
	if ([records count]>0) {
		for (int i=0; i<[records count]; i++) {
			SearchItemModel *result=[records objectAtIndex:i];
            CallLogDataModel *callLog = [calllogdic objectForKey:[NSNumber numberWithInt:result.personID]];
            if (callLog) {
                result.number = callLog.number;
            }else{
                PhoneDataModel *phone=[[[ContactCacheDataManager instance] contactCacheItem:result.personID] mainPhone];
                if ([phone.displayNumber length] > 0) {
                    result.number=phone.displayNumber;
                }
            }
            if (result.number) {
                [result_list addObject:result];
            }
			[old_result_list setObject:result forKey:[NSNumber numberWithInt:result.personID]];
		}
	}
    return result_list;
}
- (BOOL)isOnlyNumberContact
{
    return YES;
}
- (NSArray *)query:(NSString *)content
{
    //查询数据源
	NSArray *contract_list=[[ContactCacheDataManager instance].contactsCacheDict allValues];
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:1];
	for (ContactCacheDataModel *cache_item in contract_list) {
        //遍历姓名
        NSString *name=cache_item.fullName;
        NSRange range=[content isContainString:name];
        if (range.length!=0&&name)
        {
            ContractResultModel *result = [[ContractResultModel alloc] init];
            result.personID = cache_item.personID;
            result.name = cache_item.fullName;
            [result.hitNameInfo addObject:[NSNumber numberWithInt:range.location]];
            [result.hitNameInfo addObject:[NSNumber numberWithInt:range.length]];
            [names addObject:result];
        }
    }
    return names;
}
@end

@implementation TPContactNameSearch

- (BOOL)isOnlyNumberContact
{
    return NO;
}

- (BOOL)isExcuteQuery:(NSString *)content
                count:(NSInteger)count
{
    BOOL isQuery = [super isExcuteQuery:content count:count];
    if (isQuery) {
        isQuery = [content isContentLetter];
    }
    return isQuery;
}

- (NSArray *)query:(NSString *)content
{
    NSArray *names  = [[OrlandoEngine instance] queryByContractName:content
                                                        hasNumber:[self isOnlyNumberContact]];
    return names;
}

- (NSArray *)completeQuery:(NSArray *)records
{
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:1];
    for (int i =0; i<[records count]; i++) {
        ContractResultModel *item = [records objectAtIndex:i];
        if (item.name && [item.hitNameInfo count] > 0) {
            ContactCacheDataModel *person = [[ContactCacheDataManager instance] contactCacheItem:item.personID];
            NSArray *phoneList = [person phones];
            for (int j =0; j<[phoneList count]; j++) {
                ContractResultModel *result= [[ContractResultModel alloc] init];
                result.personID = item.personID;
                result.hitNameInfo = item.hitNameInfo;
                result.name = item.name;
                result.number = [[phoneList objectAtIndex:j] number];
                result.hitNumberInfo = item.hitNumberInfo;
                result.attributeID = item.attributeID;
                [returnArray addObject:result];
            }
        }else {
            [returnArray addObject:item];
        }
    }
    return returnArray ;
}
@end

@implementation TPGestureNameSearch

- (NSArray *)completeQuery:(NSArray *)records
{
	NSMutableArray *result_list=[NSMutableArray arrayWithCapacity:1];
	if ([records count]>0) {
		for (int i=0; i<[records count]; i++) {
            ContactCacheDataModel *result=[records objectAtIndex:i];
            ContactCacheDataModel *contact=[[ContactCacheDataManager instance] contactCacheItem:result.personID];
            NSMutableArray* phones = [contact phones];
            for (int j = 0; j < [phones count]; j++) {
                ContactCacheDataModel *item = [result copy];
                item.number = [phones[j] displayNumber];
                if (item.number) {
                    [result_list addObject:item];
                }
            }
		}
	}
    return result_list;
}
- (BOOL)isOnlyNumberContact
{
    return YES;
}
- (NSArray *)query:(NSString *)content
{
    //查询数据源
	NSArray *contract_list=[[ContactCacheDataManager instance].contactsCacheDict allValues];
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:1];
	for (ContactCacheDataModel *cache_item in contract_list) {
        //遍历姓名
        NSString *name=cache_item.fullName;
        NSRange range=[content isContainString:name];
        if (range.length!=0&&name)
        {
            ContractResultModel *result = [[ContractResultModel alloc] init];
            result.personID = cache_item.personID;
            result.name = cache_item.fullName;
            [result.hitNameInfo addObject:[NSNumber numberWithInt:range.location]];
            [result.hitNameInfo addObject:[NSNumber numberWithInt:range.length]];
            [names addObject:result];
        }
    }
    return names;
}
@end

@implementation TPDailNameSearch

- (BOOL)isExcuteQuery:(NSString *)content
                count:(NSInteger)count
{
    BOOL isQuery = [super isExcuteQuery:content
                                  count:count];
    if (isQuery) {
        isQuery = [content isQueryName];
    }
    return isQuery;
}

- (NSArray *)query:(NSString *)content
{
    NSArray *names  = [[OrlandoEngine instance] queryByContractName:content
                                                          hasNumber:[self isOnlyNumberContact]];
    
    return [self completeQuery:names];
}

@end

@implementation TPT9NameSearch

-(NSArray *)query:(NSString *)content
{
    return [super query:content];
}

@end

@implementation TPQwertyNameSearch

-(NSArray *)query:(NSString *)content
{
    cootek_log_function;
    return [super query:content];
}

-(BOOL)isExcuteQuery:(NSString *)content
               count:(NSInteger)count
{
    BOOL isQuery = [super isExcuteQuery:content count:count];
    if (isQuery) {
        isQuery = [content isContentLetter];
    }
    return isQuery;
}
@end

@implementation TPCalllogSearch

-(NSArray *)query:(NSString *)content
{
    cootek_log_function;
    NSArray *logs = [CallLogDBA searchCalllog:content];
    return logs;
}

@end
@implementation TPNumberSearch

-(NSArray *)query:(NSString *)content
{
    int length = [content length];
    NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:1];
    NSString *query_content = [content digitNumber];
    NSArray *contract_list=[[ContactCacheDataManager instance] getAllCacheContact];
    for (ContactCacheDataModel *cache_item in contract_list) {
        NSMutableDictionary *number_result_list = [NSMutableDictionary dictionaryWithCapacity:1];
        for (PhoneDataModel *phone in cache_item.phones) {
            SearchItemModel *tmpResultNumber = [number_result_list objectForKey:phone.displayNumber];
            if (!tmpResultNumber) {
                NSRange matchRange = [phone.displayNumber rangeOfStringInNumbers:query_content digitNumber:phone.digitNumber];
                if(matchRange.length >= length) {
                    NSString * matchString = [phone.displayNumber substringWithRange:matchRange];
                    if ([[matchString digitNumber] length] == length) {
                        SearchItemModel *tmp_result=[[SearchItemModel alloc] init];
                        tmp_result.personID=cache_item.personID;
                        tmp_result.name=cache_item.fullName;
                        tmp_result.number=phone.displayNumber;
                        tmp_result.hitNumberInfo=matchRange;
                        tmp_result.attributeID = kABPersonPhoneProperty;
                        [numbers addObject:tmp_result];
                        [number_result_list setObject:tmp_result forKey:phone.displayNumber];
                    }
                }
            }
        }
    }
    return numbers;
}

- (BOOL)isExcuteQuery:(NSString *)content
                count:(NSInteger)count{
    return !(count > 20 && [content length] < 4);
}
@end

@implementation TPAttributeSearch

- (BOOL)validateQuery:(NSString *)content
{
    NSString *current = [self.dataSource lastestQueryContent];
    if (![current isEqualToString:current]) {
        return NO;
    }
    return YES;
}
//属性查询
- (NSArray *)query:(NSString *)content
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
    NSDictionary *contract_cache_data =  [[ContactPropertyCacheManager shareManager] allCachePropertyValuesDict];
    for (NSNumber *key in contract_cache_data) {
        if (![self validateQuery:content]) {
            return nil;
        }
        NSInteger attr = [key integerValue];
        if (attr == kABPersonCreationDateProperty) {
            continue;
        }
        ContactPropertyCacheModel *propertyModel =(ContactPropertyCacheModel *)[contract_cache_data objectForKey:key] ;
        NSArray *single_attr_list = [propertyModel contactPropertyValues];
        if (single_attr_list) {
            [results insertObjectsFromArray:[self queryContractSingleAtrribute:single_attr_list
                                                                 SearchContent:content
                                                                     Attribute:attr]];
        }
    }

    return results;
}
- (NSArray *)queryContractSingleAtrribute:(NSArray *)attr_value_list
                            SearchContent:(NSString *)query_content
                                Attribute:(NSInteger)attr_id
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
	if (attr_value_list) {
		for (AttributeModel *item in attr_value_list) {
           ContractResultModel *result = [self setQueryAttributeResult:attr_id AttributeValue:item QueryContent:query_content];
            if (result) {
                if ([result.number length] > 0) {
                    [results addObject:result];
                }
            }
		}
	}
    return results;
}
- (ContractResultModel *)setQueryAttributeResult:(NSInteger)attr_id
                                  AttributeValue:(AttributeModel *)item
                                    QueryContent:(NSString *)content
{
    ContractResultModel *result = nil;
    if (attr_id==kABPersonNicknameProperty
        ||attr_id==kABPersonOrganizationProperty
        ||attr_id==kABPersonJobTitleProperty
        ||attr_id==kABPersonDepartmentProperty
        ||attr_id==kABPersonBirthdayProperty
        ||attr_id==kABPersonCreationDateProperty)
    {
		
        NSString *value=(NSString *)item.attribute;
        NSRange range=[value rangeOfString:content options:NSCaseInsensitiveSearch];
        if ([value length] > 0)
        {
            if(([content length]==1&&[value hasPrefix:content])
               ||([content length]>1&&range.length > 0)){
                result =[[ContractResultModel alloc] init];
                result.personID=item.personID;
                result.name=[[ContactCacheDataManager instance] contactCacheItem:result.personID].fullName;
                result.number=value;
                result.hitNumberInfo=range;
                CFStringRef tmpString = ABPersonCopyLocalizedPropertyName(attr_id);
                result.type=(__bridge NSString *)tmpString;
                result.attributeID = attr_id;
                SAFE_CFRELEASE_NULL(tmpString);
            }
        }
    } else if (attr_id==kABPersonNoteProperty) {
        NSString *value=(NSString *)item.attribute;
        NSRange range=[value rangeOfString:content options:NSCaseInsensitiveSearch];
        if([content length]>0&&range.length > 0){
            result =[[ContractResultModel alloc] init];
            result.personID=item.personID;
            result.name=[[ContactCacheDataManager instance] contactCacheItem:result.personID].fullName;
            result.number=value;
            result.hitNumberInfo=range;
            CFStringRef tmpString = ABPersonCopyLocalizedPropertyName(attr_id);
            result.type=(__bridge NSString *)tmpString;
            result.attributeID = attr_id;
            SAFE_CFRELEASE_NULL(tmpString);
        }
    }else {
        NSArray *value=(NSArray *)item.attribute;
        for (LabelDataModel *item_value in value ) {
            if(attr_id==kABPersonInstantMessageProperty){
                IMDataModel *im=(IMDataModel *)item_value.labelValue;
                NSString *im_values=im.username;
                if([im_values  length]<1){continue;}
                NSRange range=[im_values  rangeOfString:content options:NSCaseInsensitiveSearch];
                if ((([content length]==1&&[im_values hasPrefix:content])
					 ||([content length]>1&&range.length!=0))
                    &&im_values)
                {
                    result=[[ContractResultModel alloc] init];
                    result.personID=item.personID;
                    result.name=[[ContactCacheDataManager instance] contactCacheItem:result.personID].fullName;
                    result.number=im_values;
                    result.hitNumberInfo=range;
                    result.type=im.service;
                    result.attributeID=attr_id;
                    break;
                }
            }else {
				if([item_value.labelValue length]<1){continue;}
                NSRange range=[item_value.labelValue  rangeOfString:content options:NSCaseInsensitiveSearch];
                if (([content length]==1&&[item_value.labelValue hasPrefix:content])
                    ||([content length]>1&&range.length!=0)) {
                    result=[[ContractResultModel alloc] init];
                    result.personID=item.personID;
                    result.name=[[ContactCacheDataManager instance] contactCacheItem:result.personID].fullName;
                    result.number=item_value.labelValue;
                    result.hitNumberInfo=range;
                    result.type=item_value.labelKey;
                    result.attributeID=attr_id;
                    break;
                }
            }
        }
    }
    return result;
}
@end



