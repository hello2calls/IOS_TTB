//
//  CityGroupModel.m
//  TouchPalDialer
//
//  Created by Liangxiu on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CityGroupModel.h"
#import "LangUtil.h"

@implementation CityGroupModel
@synthesize cityName;
@synthesize contactIDs;

NSInteger sortCityGroupByFirstChar(id obj1, id obj2, void *context) {
    CityGroupModel *group1 = obj1;
    CityGroupModel *group2 = obj2;
    if(group1.contactIDs.count != group2.contactIDs.count){
        return NSOrderedAscending;
    }else{
        
        NSString *obj1_str = ((CityGroupModel*)obj1).cityName;
        NSString *obj2_str = ((CityGroupModel*)obj2).cityName;
        wchar_t char_1 = getFirstLetter(NSStringToFirstWchar(obj1_str));
        wchar_t char_2 = getFirstLetter(NSStringToFirstWchar(obj2_str));
        if (char_1 > char_2) {
            return NSOrderedDescending;
        } else if (char_1 == char_2) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
   }
}
NSInteger sortCityGroupByGroupMemberNum(id obj1, id obj2, void *context) {
    int obj1_num = ((CityGroupModel*)obj1).contactIDs.count;
    int obj2_num = ((CityGroupModel*)obj2).contactIDs.count;
   
    if (obj1_num > obj2_num) {
        return NSOrderedAscending;
    } else if (obj1_num == obj2_num) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}
@end
