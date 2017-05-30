//
//  PresentHistory.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/4.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FEATURE_ID @"fid"
#define ALREADY_PRESNET_TIMES @"apt"
#define LAST_PRESENT_TIMESTAMP @"lpt"
#define IS_SHOWN @"is_shown"
#define IS_READ @"is_read"
#define IS_CLEAR @"is_clear"
#define CLEAR_TYPE @"clear_type"
#define FILE_PATH @"file_path"
#define IMAGE_PATH @"image_path"

@interface PresentHistory : NSObject

@property (nonatomic, strong) NSString *featureId;
@property (nonatomic, assign) int alreadyPresentTimes;
@property (nonatomic, assign) long lastPresentTimtStamp;
@property (nonatomic, assign) BOOL isShown;
@property (nonatomic, assign) BOOL isClicked;
@property (nonatomic, assign) BOOL isClear;
@property (nonatomic, assign) int clearType;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *imagePath;

- (void)generateWithDictionary:(NSDictionary *)dict andFeatureId:(NSString *)fid;
- (NSDictionary *)historyToDictionary;
- (BOOL)getIsClear;
- (int)getAlreadyPresentTimes;
- (long)getLastPresentTimeStamp;
- (BOOL)getIsShown;
- (BOOL)getisCLicked;
- (void)setFeatureIdAndSave:(NSString *)featureId;//没用
- (void)setAlreadyPresentTimesAndSave:(int)alreadyPresentTimes;
- (void)setLastPresentTimtStampAndSave:(long)lastPresentTimtStamp;
- (void)setIsShownAndSave:(BOOL)isShown;
- (void)setIsClearAndSave:(BOOL)isClear;
- (void)setIsClickedAndSave:(BOOL)isClicked;
- (void)setClearTypeAndSave:(int)clearType;
- (void)setFilePathAndSave:(NSString *)filePath;
- (void)setImagePathAndSave:(NSString *)imagePath;
@end
