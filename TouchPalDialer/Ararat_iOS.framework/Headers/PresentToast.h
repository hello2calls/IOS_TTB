//
//  PresentToast.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/26.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentAction.h"
#import "PresentFeature.h"
#import "PresentationSystem.h"

@class PresentFeature;
@class PresentAction;

typedef enum :NSInteger{
    CRAfterAction = 1,
    CRAfterClose = 2,
    CRNone = 4,
}ClearRule;

typedef enum :NSInteger{
    NSANone = 0,
    NSAAfterClick = 1,
    NSAAfterClean = 2,
    NSAAfterAction = 4,
}NotShowAgain;

typedef enum :NSInteger{
    ENWifi = 1,
    ENMobile = 2,
    ENAny = 3,
    ENNone = 4,
}EnsureNetwork;

typedef enum :NSInteger{
    DSAfterParse = 0,
    DSAfterMatch,
}DownloadStrategy;

@interface PresentToast : NSObject

@property (nonatomic, assign) BOOL allowClean;
@property (nonatomic, assign) BOOL clickClean;
@property (nonatomic, assign) ClearRule clearRule;
@property (nonatomic, assign) NotShowAgain notShowAgain;
@property (nonatomic, assign) EnsureNetwork ensureNetwork;
@property (nonatomic, strong) NSString *display;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *actionConfirm;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *autoDownloadUrl;
@property (nonatomic, assign) DownloadStrategy downloadStrategy;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *toastId;
@property (nonatomic, strong) PresentFeature *feature;
@property (nonatomic, strong) PresentAction *action;

- (void)generateWithDictonary:(NSDictionary *) dict;
- (void)tryRunBackgroundTask;
- (BOOL)needRunBackgroundTask:(BOOL) canDownload;
- (BOOL)canShow;
- (NSString *)getImagePathInner;
- (NSString *)getDownloadFilePathInner;
- (void)setImagePath:(NSString *)imagePath;
- (void)setDownloadFilePath:(NSString *)filePath;
- (BOOL)clearRuleSupported:(ClearRule)rule;
- (void)setFeatureAndId:(PresentFeature *)feature;
- (BOOL)isShowing;
- (void)onToastClicked;
- (void)onToastCleared:(int)clearType;
- (void)onToastShown;
- (void)onClicked;
- (void)onCleared;
- (void)onShown;
- (void)addStatisticItem:(int)actionType;

@end
