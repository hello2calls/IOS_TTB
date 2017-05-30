//
//  DatabaseFactory.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/10.
//
//

#import <Foundation/Foundation.h>
#import "BaseDB.h"

@interface DatabaseFactory : NSObject

+(BaseDB*)newDataBase:(NSString*)dbFilePath;

@end
