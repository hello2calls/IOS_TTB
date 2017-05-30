//
//  YPTaskBase.h
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ADTaskType) {
    ADTaskNews  = 0,
    ADTaskDavinci,
    ADTaskBaidu,
    ADTaskGDT
} ;


typedef NS_ENUM(NSInteger, ADStyle) {
    ADStyleLarge  = 0,
    ADStyleSmall,
    ADStyleMulti,
};

@interface YPTaskBase : NSBlockOperation

@property (assign, getter=getType) ADTaskType type;
@property (strong, getter=getResult) NSArray* result;
@property(strong, setter=setQueryId:)NSString * queryId;
@property(nonatomic, retain)NSString* placementId;
@property (assign) BOOL finishTask;
@property (strong, setter=setSSPid:) NSNumber* sspid;
@property(nonatomic, assign, setter=setStyle:)ADStyle style;

- (BOOL) isTaskSucceeded;
- (void) setResults:(NSMutableArray *)result;

@end
