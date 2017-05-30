//
//  DataBaseModel.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-7.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "DataBaseModel.h"
#import "SyncContactWhenAppEnterForground.h"
#import "ContactCacheDataManager.h"
#import "CallLogDBA.h"
#import "BasicUtil.h"
#import "DataBaseScripts.h"
#import "UserDefaultsManager.h"

#define MAX_COUNT_IN_ONE_QUERY 100

@interface DataBaseModel ()

+ (BOOL)openDatabase:(sqlite3**)ppDatabase;

+ (void)closeDatabase:(sqlite3*)database;

@end

@implementation DataBaseModel

static dispatch_queue_t _search_queue = NULL;
static dispatch_queue_t _forground_queue = NULL;
static dispatch_queue_t _background_queue = NULL;
static DataBaseModel *_sharedSingletonModel = NULL;
static int searchKey;
static int foregroundKey;
static int backgroundKey;

@synthesize databaseForSearch;
@synthesize foregroundDatabase;
@synthesize backgroundDatabase;

+ (DataBaseModel *)instance
{
	if (_sharedSingletonModel)
		return _sharedSingletonModel;
	
	@synchronized([DataBaseModel class])
	{
		if (!_sharedSingletonModel){
			_sharedSingletonModel=[[self alloc] init];
		}		
		return _sharedSingletonModel;
	}	
}

+ (id)alloc
{

	if (!_sharedSingletonModel) {	
		_sharedSingletonModel = [super alloc];
         _search_queue = dispatch_queue_create("com.touchpal.dialer.database.search", NULL);
        CFStringRef specificValueSearch = CFSTR("com.touchpal.dialer.database.search");
        dispatch_queue_set_specific(_search_queue, &searchKey, (void*)specificValueSearch, NULL);
        
        _forground_queue = dispatch_queue_create("com.touchpal.dialer.database.foreground", NULL);
        CFStringRef specificValueForeground = CFSTR("com.touchpal.dialer.database.foreground");
        dispatch_queue_set_specific(_forground_queue, &foregroundKey, (void*)specificValueForeground, NULL);
        
        _background_queue = dispatch_queue_create("com.touchpal.dialer.database.background", NULL);
        CFStringRef specificValueBackground = CFSTR("com.touchpal.dialer.database.background");
        dispatch_queue_set_specific(_background_queue, &backgroundKey, (void*)specificValueBackground, NULL);
	}
	return _sharedSingletonModel;

}

- (id)init
{
	self = [super init];
	if (self != nil) {
		//新建电话本
        cootek_log(@"TouchPal root up  DataBase**************");
        [self initSqliteDataBase];
        cootek_log(@"end root up  DataBase**************");
	}
	return self;
}

+ (BOOL)executeSingleScript:(const char*)script
                 OnDatabase:(sqlite3*)db
{
    __block BOOL result = NO;
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        char *errorMsg;
        result = (sqlite3_exec(db, script, NULL, NULL, &errorMsg) == SQLITE_OK);
        sqlite3_free(errorMsg);
    }];
    return result;
}

+ (BOOL)executeScriptOnDatabase:(sqlite3*)db
             ForOriginalVersion:(NSInteger) originalVersion
{
    if(originalVersion < 0) {
        originalVersion = -1;
    }
    
    int count = sizeof(SQL_SCRIPTS) / sizeof(char*) - 1;
    for(int i=originalVersion; i < count; i++) {
        const char* script = SQL_SCRIPTS[i+1];
        BOOL result = [DataBaseModel executeSingleScript:script OnDatabase:db];
        if(!result) {
            return NO;
        }
    }
    
    return YES;
}

-(void)initSqliteDataBase
{
	
    cootek_log(@"init database model");
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *filepath = [documentDirectory stringByAppendingPathComponent:@"data.sqlite"];

    BOOL hasDBFile = [[NSFileManager defaultManager] fileExistsAtPath:filepath];
	
    [DataBaseModel openDatabase:&foregroundDatabase];
    
    NSInteger oriVersion = -1;
    if(hasDBFile) {
        oriVersion = [UserDefaultsManager intValueForKey:SQL_DATABASE_VERSION_KEY];
    }
    
    BOOL success = [DataBaseModel executeScriptOnDatabase:foregroundDatabase ForOriginalVersion:oriVersion];
    
    if(!success) {
        if(hasDBFile) {
            cootek_log(@"Got errors when execute sql scripts. Delete the database and re-create one.");
            [DataBaseModel closeDatabase:foregroundDatabase];
            [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
            [DataBaseModel openDatabase:&foregroundDatabase];
            
            success = [DataBaseModel executeScriptOnDatabase:foregroundDatabase ForOriginalVersion:-1];
        }
    }
    
    if(success) {
        NSInteger latestVersion = sizeof(SQL_SCRIPTS) / sizeof(char*) - 1;
        [UserDefaultsManager setIntValue:latestVersion forKey:SQL_DATABASE_VERSION_KEY];
    }
    
    [DataBaseModel openDatabase:&databaseForSearch];
    [DataBaseModel openDatabase:&backgroundDatabase];
    
    //syn 
    if ([AdvancedCalllog isAccessCallDB]) {
        [AdvancedCalllog synCalllog];
    }
}

+ (BOOL)openDatabase:(sqlite3**)ppDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *filepath = [documentDirectory stringByAppendingPathComponent:@"data.sqlite"];
	//数据库连接建立
    int openResult = sqlite3_open([filepath UTF8String], ppDatabase);
	if (SQLITE_OK != openResult) {
        [self closeDatabase:*ppDatabase];
		cootek_log(@"failed to open database:%@", filepath);
        return NO;
	} else {
        sqlite3_busy_timeout(*ppDatabase, 10000);
    } 
    return YES;
}

+ (void)closeDatabase:(sqlite3*)database
{
    if (SQLITE_OK != sqlite3_close(database)) {
        cootek_log(@"failed to close database.");
    }
}


+ (NSString *)getKGroupByKeyPersonId
{
	return @"personID";
}

+ (NSString *)getKGroupByKeyPhoneNumber
{
	return @"phoneNumber";
}

+ (NSString *)getKGroupByKeyCallTime
{
	return @"callTime";
}

//Order By key
+ (NSString *)getKOrderByKeyCallTime
{
	return @"callTime";
}
+ (NSString *)getKOrderByKeyCallCount
{
	return @"CallCount";
}

+ (NSString *)getKOrderByKeyValueDesc
{
	return @"desc";
}

+ (NSString *)getKOrderByKeyValueAsc
{
	return @"asc";
}

+ (NSString *)getKWhereKeyCallTime
{
	return @"callTime";
}

+ (NSString *)getKWhereKeyPhoneNumber
{
	return @"phoneNumber";
}

+ (NSString *)getKWhereKeyPersonID
{
	return @"PersonID";
}

+ (NSString *)getKWhereKeyCallType
{
	return @"callType";
}

+ (NSString *)getKWhereKeyRowID
{
	return @"rowId";
}

+ (NSString *)getKWhereSameDay
{
	return @"(callTime/86400)";
}

+ (NSString *)getKWhereOperationLike
{
	return @"like";
}

+ (NSString *)getKWhereOperationLargerThen
{
	return @">=";
}

+ (NSString *)getKWhereOperationLarger
{
	return @">";
}

+ (NSString *)getKWhereOperationEqual
{
	return @"=";
}

+ (NSString *)getKWhereOperationSmall
{
	return @"<";
}

+ (NSString *)getKWhereOperationSmallThen
{
	return @"<=";
}

+ (NSString *)switchOperString:(NSString *)oper
                  CompareValue:(NSString *)value
                       withKey:(NSString *)key
{
	NSString *cause=@"  ";
	if (!value) {
		return cause;
	}
	if ([oper isEqual:[self getKWhereOperationLike]]) {
		cause=[cause stringByAppendingString:oper];	
		cause=[cause stringByAppendingString:@" \"%"];	
		cause=[cause stringByAppendingString:value];
		cause=[cause stringByAppendingString:@"%\" "];	
	}else {
		if ([key isEqualToString:[self getKWhereKeyPhoneNumber]]) {
			cause=[cause stringByAppendingString:oper];	
			cause=[cause stringByAppendingString:@"'"];
			cause=[cause stringByAppendingString:[DataBaseModel getFormatNumber:value]];
			cause=[cause stringByAppendingString:@"'"];
		}else {
			cause=[cause stringByAppendingString:oper];	  
			cause=[cause stringByAppendingString:value];			
		}
	}
	return cause;
}

+ (BOOL )getKWhereKeyType:(NSString *)whereby_key
{
	if ([whereby_key isEqualToString:@"phoneNumber"]||
        [whereby_key isEqualToString:@"phoneLabel"]||
        [whereby_key isEqualToString:@"personName"] ) {
		 return NO;
	 }
	else {
		return YES;
	}

}

+ (NSString *)switchOperString:(NSString *)oper
                      withKey:(NSString *)key
{
	NSString *cause=@"  ";
    cause=[cause stringByAppendingString:oper];	  
    cause=[cause stringByAppendingString:@"?"];
	return cause;
}

+ (NSString *)getWhereCause:(NSArray *)where
                DeleteFlag:(BOOL)flag
{
	if (where) {
		int count =[where count];
		if (count>0) {
			NSString *cause=@"";
			int first_Flag=0;
			for (int i=0; i<count; i++) {
				WhereDataModel *where_temp=[where objectAtIndex:i];
				if ([self isExistsWhereKey:where_temp.fieldKey]) {	
					if (first_Flag==0) {
						cause=@" where  ";
						first_Flag=first_Flag+1;
					}				
					cause=[cause stringByAppendingString:where_temp.fieldKey];		
					if(flag==YES)
					{		
						cause=[cause stringByAppendingString:[self switchOperString:where_temp.oper withKey:where_temp.fieldKey]];						   
					}else{
						cause=[cause stringByAppendingString:[self switchOperString:where_temp.oper CompareValue:where_temp.fieldValue withKey:where_temp.fieldKey]];
					}
					cause=[cause stringByAppendingString:@"  and  "];
				}
			}
		 if([cause length]>7)	
		  {cause=[cause substringToIndex:[cause length]-5];}			 
		 return	cause;	 
		}
	}
	return @"";
}

+ (BOOL)isExistsWhereKey:(NSString *)fieldKey
{
	if ([fieldKey isEqualToString:[self getKWhereKeyPhoneNumber]]) {return YES;}
    else if([fieldKey isEqualToString:[self getKWhereKeyCallTime]]){return YES;}
	else if([fieldKey isEqualToString:[self getKWhereKeyCallType]]){return YES;}
	else if([fieldKey isEqualToString:[self getKWhereKeyPersonID]]){return YES;}
	else if([fieldKey isEqualToString:[self getKWhereKeyRowID]]){return YES;}
	else if([fieldKey isEqualToString:[self getKWhereKeyPhoneNumber]]){return YES;}
	else if([fieldKey isEqualToString:[self getKWhereSameDay]]){return YES;}
	else {
		return NO;
	}
}

+ (BOOL)isExistsGroupByKey:(NSString *)fieldKey
{
	if ([fieldKey isEqual:[self getKGroupByKeyPersonId]]) {
		return YES;
	}
	else if([fieldKey isEqual:[self getKGroupByKeyPhoneNumber]]){return YES;}
	else if([fieldKey isEqual:[self getKGroupByKeyCallTime]]){return YES;}
	else if([fieldKey isEqual:@"callTime/86400"]){return YES;}
    else if([fieldKey isEqual:[self getKOrderByKeyCallCount]]){return YES;}
	else {
		return NO;
	}
}

+ (NSString *)getGroupByCause:(NSArray *)groupby
{
	if (groupby) {
		int count =[groupby count];
		if (count>0) {
			NSString *cause=@"";
			int first_Flag=0;
			for (int i=0; i<[groupby count]; i++) {
				NSString *groupby_temp=[groupby objectAtIndex:i];
				if ([self isExistsGroupByKey:groupby_temp]) {	
					if (first_Flag==0) {
						cause=@"group by ";
						first_Flag=first_Flag+1;
					}
					cause=[cause stringByAppendingString:groupby_temp];
					cause=[cause stringByAppendingString:@","];
				}
			}
			if([cause length]>1)	
			{	
				cause=[cause substringToIndex:[cause length]-1];
				cause=[cause stringByAppendingString:@")  "];
			}			 
			return	cause;	 
		}
	}
	return @"";
}

+ (BOOL)isExistsOrderByKey:(NSString *)fieldKey
{
	if ([fieldKey isEqualToString:[self getKOrderByKeyCallTime]]) {
		return YES;
	}
	else if([fieldKey isEqualToString:[self getKOrderByKeyCallCount]]){return YES;}
	else {
		return NO;
	}

}

+ (NSString *)getOrderByCause:(NSArray *)orderby
{
	if (orderby) {
		int count =[orderby count];
		if (count>0) {
			NSString *cause=@"";
			int first_Flag=0;
			for (int i=0; i<[orderby count]; i++) {
            LabelDataModel *orderby_temp=[orderby objectAtIndex:i];
                if ([self isExistsGroupByKey:orderby_temp.labelKey]){
                if (first_Flag==0) {
                    cause=@"order by ";
                    first_Flag=first_Flag+1;
                }
                cause=[cause stringByAppendingString:orderby_temp.labelKey];
                cause=[cause stringByAppendingString:@" "];
                cause=[cause stringByAppendingString:orderby_temp.labelValue];
                cause=[cause stringByAppendingString:@","];
                }
            }
			
			if([cause length]>1)	
			{
                cause=[cause substringToIndex:[cause length]-1];
                cause=[NSString stringWithFormat:@"%@ limit 0,%d",cause,MAX_COUNT_IN_ONE_QUERY];
            }
			return	cause;	 
		}
	}
	return @"";
}
+ (NSString *)getFormatNumber:(NSString *)number
{
    NSString *formatNumber = @"";
    if ([number hasPrefix:@"+"]) {
        formatNumber = @"+";
        if ([number length] > 1) {
            number = [number substringFromIndex:1];
        }else {
            return number;
        }
    }
    NSRange position = NSMakeRange(0,1);
    for (int i=0 ; i<[number length]; i++) {
        unichar indexLetter = [number characterAtIndex:i];
        if((indexLetter >= '0' && indexLetter <='9')
             ||(indexLetter >= 'a' && indexLetter <='z')
             ||(indexLetter >=  'A' && indexLetter <='Z'))
        { 
            position.location = i;
            NSString *tmp = [number substringWithRange:position];
            formatNumber = [formatNumber stringByAppendingString:tmp];
        }
    }
    cootek_log(@"farmat string number= %@ original number = %@",formatNumber,number);
    return formatNumber;
}

- (void)dealloc
{
    SAFE_CLOSE_DATABASE(databaseForSearch);
    SAFE_CLOSE_DATABASE(foregroundDatabase);
    SAFE_CLOSE_DATABASE(backgroundDatabase);
}

+ (void)execute:(DataBaseExecutionMode) mode
     inDatabase:(void (^)(sqlite3* db))block
{
    dispatch_queue_t q = NULL;
    sqlite3* db = NULL;
    bool isSync = true;
    int *key;
    
    switch (mode) {
        case DataBaseExecutionModeNew:
        {
            [DataBaseModel instance];
            if (![DataBaseModel openDatabase:&db]) {
                return;
            }
            break;
        }
        case DataBaseExecutionModeForSearch:
            q = _search_queue;
            db = [DataBaseModel instance].databaseForSearch;
            key=&searchKey;
            break;
        case DataBaseExecutionModeForeground:
            q = _forground_queue;
            key =&foregroundKey;
            db = [DataBaseModel instance].foregroundDatabase;
            break;
        case DataBaseExecutionModeBackground:
            q = _background_queue;
            db = [DataBaseModel instance].backgroundDatabase;
            key = &backgroundKey;
            break;
        default:
            cootek_log(@"The DataBaseExecutionMode is invalid. Skip the execution.");
            return;
    }
    if(q == NULL || dispatch_get_specific(key))
    {
        block(db);
    } else {
        if(isSync) {
            dispatch_sync(q, ^() {
                block(db);
            });
        } else {
            dispatch_async(q, ^() {
                block(db); 
            });
        }
    }
    
    if(mode == DataBaseExecutionModeNew)
    {
        [DataBaseModel closeDatabase:db];
    }
}

@end
