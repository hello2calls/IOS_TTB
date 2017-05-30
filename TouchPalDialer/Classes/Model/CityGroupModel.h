//
//  CityGroupModel.h
//  TouchPalDialer
//
//  Created by Liangxiu on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityGroupModel : NSObject
@property(nonatomic,retain)NSString *cityName;
@property(nonatomic,retain)NSArray *contactIDs;
NSInteger sortCityGroupByFirstChar(id obj1, id obj2, void *context);
NSInteger sortCityGroupByGroupMemberNum(id obj1, id obj2, void *context);
@end
