//
//  AdvancedSettingUtility.h
//  TPDialerAdvanced
//
//  Created by Elfe Xu on 12-10-15.
//
//

#import <Foundation/Foundation.h>

@interface AdvancedSettingUtility : NSObject

+(NSString*) dialerAppPath;
+(NSString*) dialerDocumentPath;
+(NSString*) dialerApplicationPath;
+(NSString*) numberAttributePath ;
+(NSString*) mainDatabasePath;
+(NSString*) seattleDatabasePath;
+(NSString*) cityDataFolderPath;
+(NSString*) advancedSettingPath;
+(id) querySetting:(NSString*) key;
+(id) queryAdvancedSetting:(NSString*) key;
+(void) setAdvancedSetting:(NSString*) key
                     value:(NSString*) value;

@end
