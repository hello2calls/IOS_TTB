//
//  Favorites.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-12.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "Favorites.h"
#import "PersonDBA.h"
#import "FavoritesDBA.h"
#import "consts.h"
#import "CootekNotifications.h"
#import "ContactCacheDataManager.h"

@implementation Favorites

+ (NSArray *)getFavoriteList
{
	NSArray *record_list = [FavoritesDBA getFavoriteList];
	if (record_list) {
		int record_count = [record_list count];
		NSMutableArray *favorite_list = [[NSMutableArray alloc] init];
		for (int i = 0; i < record_count; i++) {
			NSInteger  person_id = [[record_list objectAtIndex:i] integerValue];
			ContactCacheDataModel *person = [[ContactCacheDataManager instance] contactCacheItem:person_id];
			if (person) {	
				FavoriteDataModel *favorite=[[FavoriteDataModel alloc] init];
				favorite.personID = person_id;
				favorite.personName = [person displayName];
				favorite.photoData = [person image];
				favorite.mainPhone = [person mainPhone];
				[favorite_list addObject:favorite];
			}else {
				[self removeFavoriteByRecordId:person_id isNotify:NO];
			}		
		}
		return favorite_list;	
	}else {
		return nil;
	}
}

+ (BOOL)addFavoriteByRecordId:(NSInteger)recordId
                      isArray:(BOOL)is_array
{
	BOOL is_add=[FavoritesDBA addFavoriteByRecordId:recordId];
	if (is_array == NO && is_add == YES) {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_FAVORITE_DATA_CHANGED object:nil userInfo:nil];
	}
	return is_add;
}

+ (BOOL)addFavoriteByRecordId:(NSInteger)recordId
{
	return [self addFavoriteByRecordId:recordId
                               isArray:NO];
}

+ (BOOL)removeFavoriteByRecordId:(NSInteger)recordId
{
	return [self removeFavoriteByRecordId:recordId
                                  isNotify:YES];
}

+ (BOOL)removeFavoriteByRecordId:(NSInteger)recordId
                         isNotify:(BOOL)isNotify
{
	BOOL isDelete=[FavoritesDBA removeFavoriteByRecordId:recordId];
	if (isDelete == YES && isNotify == YES) {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_FAVORITE_DATA_DELETE_ID
                                                            object:nil
														  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:recordId] 
                                                                                               forKey:KEY_FAVORITE_DElETE_PERSON_ID]];
	}
	return isDelete;
}

+ (BOOL)isExistFavorite:(NSInteger)recordId
{
	return [FavoritesDBA isExistFavorite:recordId];
}

+ (BOOL)removeFavoriteByRecordIdArray:(NSArray *)recordId_array
{
	if (!recordId_array || [recordId_array count] <= 0) {
		return NO;
	}
	BOOL resultDelete = NO;
	int record_count = [recordId_array count];
	for (int i = 0; i < record_count; i++) {
		if ([self removeFavoriteByRecordId:[[recordId_array objectAtIndex:i] integerValue] isNotify:NO])
		{
			resultDelete = YES;
		}
	}
	if (resultDelete == YES) {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_FAVORITE_DATA_CHANGED object:nil userInfo:nil];
	}
	return resultDelete;
}

+ (BOOL)addFavoriteByRecordIdArray:(NSArray *)recordId_array
{
	if (!recordId_array||[recordId_array count]<=0) {
		return NO;
	}
	BOOL resultAdd=NO;
	int record_count=[recordId_array count];
	for (int i=0; i<record_count; i++) {
		if ([self addFavoriteByRecordId:[[recordId_array objectAtIndex:i] integerValue] isArray:YES]==YES){
			resultAdd=YES;
		} 
	}
	if (resultAdd==YES) {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_FAVORITE_DATA_CHANGED object:nil userInfo:nil];
	}
	return resultAdd;
}
@end
