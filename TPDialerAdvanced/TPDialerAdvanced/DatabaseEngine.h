//
//  DatabaseEngine.h
//  TPDialerAdvanced
//
//  Created by Elfe Xu on 12-10-9.
//
//

#import <Foundation/Foundation.h>
#import "NumberInfoModel.h"

@interface DatabaseEngine : NSObject

+ (NSArray*) queryAllCityFiles;
+ (void) addData:(NumberInfoModel*) infoData;
+ (BOOL) fillNumberInfo:(NumberInfoModel*) infoDta;

@end
