//
//  GuidePointNode.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/3.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSInteger{
    PTHide = 0,
    PTNew = 1,
    PTDot = 2,
    PTNum = 3,
    PTUpdate = 4,
}PointType;

typedef enum: NSInteger{
    DRAny = 1,
    DRAll = 2,
    DRSelf = 3,
    DRShow = 4,
    DRNever = 5,
}DismissRule;

@interface GuidePointNode : NSObject

@property (nonatomic, strong) NSString *pointId;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) DismissRule dismissRule;
@property (nonatomic, strong) NSString *holderShowConditions;
@property (nonatomic, strong) NSString *selfShowConditions;
@property (nonatomic, strong) NSString *extensionId;
@property (nonatomic, strong) GuidePointNode *parentPoint;
@property (nonatomic, strong) NSMutableArray *childPoints;

- (void)generateGuidePointWithDictionary:(NSDictionary *)dict;
- (BOOL)canSelfShow;
- (BOOL)canHolderShow;
- (BOOL)isLeaf;
@end
