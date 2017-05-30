//
//  SearchResultModel.m
//  TouchPalDialer
//
//  Created by Alice on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchResultModel.h"

@implementation SearchItemModel
@synthesize personID;
@synthesize name = name_;
@synthesize number;
@synthesize hitNameInfo;
@synthesize hitNumberInfo;
@synthesize attributeID;
-(id) init{
	self = [super init];
	if(self != nil){
		hitNameInfo=[[NSMutableArray alloc] init];
	}
	return self;
}

-(SearchItemModel *)copy {
    SearchItemModel *item = [[SearchItemModel alloc] init];
    item.personID = self.personID;
    item.name = self.name;
    item.number = self.number;
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:self.hitNameInfo];
    item.hitNameInfo = tmp;
    item.hitNumberInfo = self.hitNumberInfo;
    item.attributeID = self.attributeID;
    return item;
}

@end

@implementation SearchResultModel
@synthesize searchKey;
@synthesize searchResults;
@synthesize searchType;
-(id) init{
	self = [super init];
	if( self != nil ) {
		self.searchResults=[NSMutableArray arrayWithCapacity:1];
	}
	return self;
}
-(SearchResultModel *)copy{
    SearchResultModel *search_result=[[SearchResultModel alloc] init];
    search_result.searchKey = self.searchKey;
    search_result.searchType = self.searchType;

    NSMutableArray *tmpSearchResults =[[NSMutableArray alloc] initWithArray:self.searchResults];
    search_result.searchResults = tmpSearchResults;
    return search_result;
}
@end
