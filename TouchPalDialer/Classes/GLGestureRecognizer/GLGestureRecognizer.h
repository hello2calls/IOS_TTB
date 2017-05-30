//
//  GLGestureRecognizer.h
//  Gestures
//
//  Created by Adam Preble on 4/28/09.  adam@giraffelab.com
//

#import <Foundation/Foundation.h>


@interface GLGestureRecognizer : NSObject {
	NSMutableArray *touchPoints;
	NSMutableArray *resampledPoints;
	NSMutableDictionary *templates;
}
@property (nonatomic, retain) NSMutableDictionary *templates;
@property (nonatomic, retain) NSMutableArray *touchPoints;
@property (nonatomic, retain) NSArray *resampledPoints;

- (void)addTouches:(NSSet*)set fromView:(UIView *)view;
- (void)addTouchAtPoint:(CGPoint)point;
- (void)addPointList:(NSMutableArray *)pointList;
- (void)resetTouches;
- (NSString *)findBestMatch;
- (NSString *)findBestMatchCenter:(CGPoint*)outCenter angle:(float*)outRadians score:(float*)outScore;
- (void)customGesture:(NSString *)name;
- (void)removeGesture:(NSString *)name;
@end
