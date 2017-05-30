//
//  SQLiteManager.h
//  Dialer
//
//  Created by Jaison_Li_893 on 11-4-21.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoritesDBA: NSObject
//Description:get Favorites List
//Input:nil
//return:NSArray
+ (NSArray *)getFavoriteList;

//Description:add person to Favorites 
//Input:recordID
//return:bool
+ (BOOL)addFavoriteByRecordId:(NSInteger)recordId;

//Description:delete person from Favorites 
//Input:recordID
//return:bool
+ (BOOL)removeFavoriteByRecordId:(NSInteger)recordId;

//Description:the person is in Favorites 
//Input:recordID
//return:bool
+ (BOOL)isExistFavorite:(NSInteger)recordId;

@end
