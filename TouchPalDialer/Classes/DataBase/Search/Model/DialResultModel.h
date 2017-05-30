//
//  DialResultModel.h
//  AddressBook_DB
//
//  Created by Alice on 11-8-1.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallerIDInfoModel.h"
#import "SearchResultModel.h"

typedef enum {
    DailQueryTypeNationYellow,
    DailQueryTypeContactName,
    DailQueryTypeContactCallog,
    DailQueryTypeContactNumber,
}DailQueryType;


@interface DialResultModel : SearchItemModel <BaseCallerIDDataSource>
@property(nonatomic,assign) DailQueryType type;
@end
