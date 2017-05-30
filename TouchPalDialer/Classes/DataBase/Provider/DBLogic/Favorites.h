//
//  Favorites.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-12.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoriteDataModel.h"
@interface Favorites : NSObject

+ (NSArray *)getFavoriteList;

+ (BOOL)addFavoriteByRecordIdArray:(NSArray *)recordId_array;

+ (BOOL)addFavoriteByRecordId:(NSInteger)recordId
                      isArray:(BOOL)is_array;

+ (BOOL)removeFavoriteByRecordId:(NSInteger)recordId;

+ (BOOL)removeFavoriteByRecordId:(NSInteger)recordId
                        isNotify:(BOOL)is_array;

+ (BOOL)removeFavoriteByRecordIdArray:(NSArray *)recordId_array;

+ (BOOL)addFavoriteByRecordId:(NSInteger)recordId;

+ (BOOL)isExistFavorite:(NSInteger)recordId;


@end
