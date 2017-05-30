//
//  SearchResultModel.h
//  TouchPalDialer
//
//  Created by Alice on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactsCellStrategy.h"
#import "CallerIDInfoModel.h"

typedef enum {
     DialSearch,
     ContactSearch,
     YellowSearch,
     PickerSearch,
     ContactWithPhoneSearch,
     InviteSearch,
     GestureSearch,
}SearchType;

typedef enum {
    AllCallLogFilter,
    MissedCalllogFilter,
    UnknowCallLogFilter,
    OutgoingFilter,
    IncomingFilter,
}CalllogFilterType;

@protocol BaseContactsDataSource <NSObject>

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *number;
@property(nonatomic,assign)NSInteger personID;

@end

@protocol BaseCallerIDDataSource <NSObject>

@property(nonatomic,retain) CallerIDInfoModel *callerID;

@end

@interface  SearchItemModel : NSObject<BaseContactsDataSource> {
	NSInteger personID;
	NSString *name_;
	NSString *number;
	NSMutableArray  *hitNameInfo;
	NSRange  hitNumberInfo;
}
@property(nonatomic,assign) NSInteger personID;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *number;
@property(nonatomic,retain) NSMutableArray  *hitNameInfo;
@property(nonatomic,assign) NSRange hitNumberInfo;
@property(nonatomic,assign) NSInteger attributeID;
@end

@interface SearchResultModel : NSObject {
	NSString *searchKey;
	NSMutableArray  *searchResults;
    SearchType searchType;
}
@property(nonatomic,copy)NSString *searchKey;
@property(nonatomic,retain)NSMutableArray  *searchResults;
@property(nonatomic,assign)SearchType searchType;
-(SearchResultModel *)copy;
@end
