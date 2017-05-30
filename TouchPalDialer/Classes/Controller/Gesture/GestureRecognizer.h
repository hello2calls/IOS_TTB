//
//  GestureProvider.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GESTURE_RECOGNIZER_THREHOLD 0.45


typedef enum {
    DefaultGestureNone,
    DefaultGestureSms,
    DefaultGestureCall,
    DefaultGestureBoth,
}DefaultGestureType;


@interface Strokie : NSObject{
	NSMutableArray *_pointsArray;
}
@property(nonatomic,retain)NSMutableArray *pointsArray;

-(void)addPointToStroike:(CGPoint)point;
-(void)removeAllPoints;

@end

@interface Gesture : NSObject{
    NSString *_name;
	NSMutableArray *_strokiesArray;
}
@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSMutableArray *strokiesArray;

-(UIImage *)convertToImage;
-(CGRect) boundBox:(NSArray *)points; 
-(CGRect) squareBoundBox:(NSArray *) points;
-(CGPoint) mapPoint:(CGPoint)oldPoint fromOrigin:(CGPoint) origin  withPadding:(float)padding;
-(id)initWithGesture:(NSString *)name;
-(void)addStrokieToGesture:(Strokie *)strokie;
-(void)removeStrokieToGesture:(Strokie *)strokie;
-(void)removeAllStrokies;
@end

@interface GesturesResults : NSObject{
	NSString *_name;
    float _score;
}

@property(nonatomic,retain)NSString *name;
@property(nonatomic,assign)float score;
@end

@interface GestureRecognizer : NSObject
-(id)initGestureRecognizer;
-(void)addGesture:(Gesture *)gesture;
-(void)removeGesture:(NSString *)gestureName;
-(GesturesResults *)recognizerGesture:(Gesture *)gesture;
-(Gesture *)getGesture:(NSString *)name;
-(NSArray *)getOptionalGestureList;
-(NSArray *)getGestureList;
-(DefaultGestureType)getDefaultGestureType;
@end
