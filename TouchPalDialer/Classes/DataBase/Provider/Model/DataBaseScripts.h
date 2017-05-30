//
//  DataBaseScripts.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef TouchPalDialer_DataBaseScripts_h
#define TouchPalDialer_DataBaseScripts_h

const char* SQL_SCRIPTS[] = {
    // Create original V0 table
    "CREATE TABLE IF NOT EXISTS favorite(rowId INTEGER PRIMARY KEY,recordId INTEGER,createTime TEXT);"
    "CREATE TABLE IF NOT EXISTS reminder(rowId INTEGER PRIMARY KEY, person_id INTEGER, phone_number TEXT, call_status INTEGER, tag_time INTEGER, tag_type INTEGER, is_done INTEGER);"
    "CREATE TABLE IF NOT EXISTS contact_group(row_id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER);"
    "CREATE TABLE IF NOT EXISTS group_member(row_id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER, person_id INTEGER, source_type INTEGER);"
    "CREATE TABLE IF NOT EXISTS call_log(rowId INTEGER PRIMARY KEY,personID INTEGER,phoneNumber TEXT,personName TEXT,phoneLabel Text,callCount INTEGER, callTime INTEGER);"
    ,
    
    // upgrade from V0 to V1
    "CREATE TABLE IF NOT EXISTS calllog(rowId INTEGER PRIMARY KEY,personID INTEGER,phoneNumber TEXT, callType INTEGER, duration INTEGER, callTime INTEGER);"
    "BEGIN TRANSACTION;"
    "INSERT INTO calllog SELECT rowId, personID, phoneNumber, 1, 0, callTime FROM call_log;"
    "DROP TABLE call_log;"
    "COMMIT;"
    ,
    
    // upgrade from V1 to V2
    "CREATE TABLE IF NOT EXISTS  YELLOWLOG(rowId INTEGER PRIMARY KEY,shopID INTEGER,number TEXT,callTime INTEGER,city TEXT,name TEXT,mainShopID INTEGER);"
    "CREATE TABLE  CITY(cityId TEXT ,name TEXT,mainFilePath TEXT,updateFilePath TEXT,mainVersion TEXT,updateVersion TEXT,mainSize INTEGER,updateSize INTEGER,isDownload INTEGER,PRIMARY KEY(cityId,isDownload));"    
    "CREATE TABLE  SHOP(shopID INTEGER,name TEXT,number TEXT PRIMARY KEY);"
    "CREATE TABLE  CALLER(name TEXT,number TEXT PRIMARY KEY,level text,type,text,fraudCount INTEGER,crankCount,dateTime INTEGER,isCallerID INTEGER);"
    ,
    
    // upgrade from v2 to v3
    "DROP TABLE IF EXISTS CALLER;"
    "CREATE TABLE  CALLER(name TEXT,number TEXT PRIMARY KEY,level text,type text,fraudCount INTEGER,crankCount INTEGER,dateTime INTEGER,cacheLevel INTEGER,vipID INTEGER,versionTime text);"
    ,
    // upgrade from v3 to v4
    "CREATE TABLE IF NOT EXISTS  USER_MARKED_NUMBERS(number TEXT PRIMARY KEY,markTime INTEGER,isSucess INTEGER);"
    
    ,
    // upgrade from v4 to v5, caller table change 
    "DROP TABLE IF EXISTS CALLER;"
    "CREATE TABLE IF NOT EXISTS  CALLER(name TEXT,number TEXT PRIMARY KEY, callerType TEXT, verifyType INTEGER, markCount INTEGER,dateTime INTEGER,cacheLevel INTEGER, vipID INTEGER, versionTime TEXT);"
    ,
    // upgrade from v5 to v6
    "CREATE TABLE IF NOT EXISTS contact(personID INTEGER PRIMARY KEY,name TEXT,lastUpdateTime INTEGER);"
    "CREATE TABLE IF NOT EXISTS numbers(personID INTEGER ,number TEXT,normalizedNumber TEXT,PRIMARY KEY(personID,number));"
    ,
    //upgrade from v6 to v7, add table touchpal_numbers
    "CREATE TABLE IF NOT EXISTS touchpal_numbers(row_Id INTEGER PRIMARY KEY AUTOINCREMENT, normalize_number TEXT, if_cootek_user INTEGER );"
    ,
    //upgrade from v7 to v8, add table touchpal_history
    "CREATE TABLE IF NOT EXISTS touchpal_history(row_Id INTEGER PRIMARY KEY AUTOINCREMENT, event_name TEXT, bonus INTEGER, bonus_type INTEGER, datetime INTEGER, pop INTEGER);"
    ,
    //upgrade from v8 to v9 ,add column to calllog
    "ALTER TABLE calllog ADD COLUMN ifVoip INTEGER DEFAULT 0;",
    
    "CREATE TABLE IF NOT EXISTS public_number_info(user_phone TEXT, send_id TEXT, name TEXT, data TEXT, menus TEXT, error_url TEXT, icon_link TEXT, logo_link TEXT, company_name TEXT, desc TEXT, available INTEGER, new_msg_time INTEGER, new_msg_count INTEGER, new_msg_desc TEXT,PRIMARY KEY(send_id, user_phone));"
    "CREATE TABLE IF NOT EXISTS public_number_message(message_id TEXT PRIMARY KEY, user_phone TEXT, type TEXT, notify_type TEXT, title TEXT, desc TEXT, notification TEXT, remark TEXT, keynotes TEXT, send_id TEXT, create_time INTEGER, receive_time INTEGER, status INTEGER, source TEXT, pre_msg TEXT, url TEXT);"
    "CREATE TABLE IF NOT EXISTS public_number_icons(link TEXT PRIMARY KEY, path TEXT);",
    
    //upgrade from v9 to v10 ,add column to public_number_message
    "ALTER TABLE public_number_message ADD COLUMN native_url TEXT;",
    
    //upgrade from v10 to v11 ,add column to public_number_message
    "ALTER TABLE public_number_message ADD COLUMN if_noah INTEGER DEFAULT 0;",
    
    //upgrade from v11 to v12, create table contact_smart_search
    "CREATE TABLE IF NOT EXISTS contact_smart_search(smart_search_key TEXT, person_id INTEGER, hit_type INTEGER, clicked_times INTEGER);",
    
    //upgrade from v12 to v13, add column to public_number_message, add column to public_numer_info
    "ALTER TABLE public_number_message ADD COLUMN stat_key TEXT;",
    "ALTER TABLE public_number_info ADD COLUMN url TEXT;"
    
};

#endif
