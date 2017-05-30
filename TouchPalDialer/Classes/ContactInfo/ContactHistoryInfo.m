//
//  ContactHistoryInfo.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/24.
//
//

#import "ContactHistoryInfo.h"

@implementation ContactHistoryInfo
- (instancetype)init{
    self = [super init];
    if ( self ){
        _dateArray = [NSMutableArray array];
    }
    return self;
}
@end
