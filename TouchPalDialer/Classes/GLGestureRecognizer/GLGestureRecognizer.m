//
//  GLGestureRecognizer.m
//  Gestures
//
//  Created by Adam Preble on 4/28/09.  adam@giraffelab.com
//  
//  Largely an implementation of the $1 Unistroke Recognizer:
//  http://depts.washington.edu/aimgroup/proj/dollar/
//  Jacob O. Wobbrock, Andrew D. Wilson, Yang Li
//  
#import "GLGestureRecognizer.h"

#define kSamplePointsCount (16)

// Utility/Math Functions:
CGPoint Centroid(CGPoint *samples, int samplePoints);
void Translate(CGPoint *samples, int samplePoints, float x, float y);
void Rotate(CGPoint *samples, int samplePoints, float radians);
void Scale(CGPoint *samples, int samplePoints, float xScale, float yScale);
float Distance(CGPoint p1, CGPoint p2);
float PathDistance(CGPoint *pts1, CGPoint *pts2, int count);
float DistanceAtAngle(CGPoint *samples, int samplePoints, CGPoint *template, float theta);
float DistanceAtBestAngle(CGPoint *samples, int samplePoints, CGPoint *template);


@implementation GLGestureRecognizer

@synthesize templates, resampledPoints, touchPoints;

- (id)init
{
	if (self = [super init])
	{
		self.touchPoints = [NSMutableArray array];
		self.templates = [NSMutableDictionary dictionary];
		self.resampledPoints = [NSMutableArray array];
	}
	return self;
}
- (void)dealloc
{
	self.touchPoints = nil;
	self.templates = nil;
	[super dealloc];
}

- (void)addTouches:(NSSet*)set fromView:(UIView *)view
{
	[self addTouchAtPoint:[[set anyObject] locationInView:view]];
}
- (void)addTouchAtPoint:(CGPoint)point
{
     cootek_log(@"*********x=%f,y=%f",point.x,point.y);
	[[self touchPoints] addObject:[NSValue valueWithCGPoint:point]];
}
- (void)addPointList:(NSMutableArray *)pointList{
    if ([pointList count] > 0) {
        [[self touchPoints] addObjectsFromArray:pointList];
    }
}
- (void)resetTouches
{
	self.touchPoints = [NSMutableArray array];
}
- (NSString *)findBestMatch
{
	return [self findBestMatchCenter:NULL angle:NULL score:NULL];
}
- (NSString *)findBestMatchCenter:(CGPoint*)outCenter angle:(float*)outRadians score:(float*)outScore
{
    if([self touchPoints].count < kSamplePointsCount) {
        cootek_log(@"Error: the sample points count is %d", [self touchPoints].count);
        return @"";
    }
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// Adapted from description on: http://depts.washington.edu/aimgroup/proj/dollar/ / http://blog.makezine.com/archive/2008/11/gesture_recognition_for_javasc.html
	// 1. Resampling the recorded path into a fixed number of points that are evenly spaced along the path
	// 2. Rotate the path so that the first point is directly to the right of the path's center of mass
	// 3. Scaling the path (non-uniformly) to a fixed height and width
	// 4. For each reference path, calculating the average distance for the corresponding points in the input path. The path with the lowest average point distance is the match.
	int i;
    
	const int samplePointsCount = kSamplePointsCount;
	CGPoint samples[samplePointsCount];
	int c = [[self touchPoints] count];
	// Load up the samples.  We use a very simplistic method for this; the JavaScript version is much more sophisticated.
	for (i = 0; i < samplePointsCount; i++)
	{
        int index = MAX(0, (c-1)*i/(samplePointsCount-1));
        if (index<c && index >=0) {
            //Elfe ?? index > 0 or index >= 0
            samples[i] = [[[self touchPoints] objectAtIndex:index] CGPointValue];
        }
	}
	
	CGPoint center = Centroid(samples, samplePointsCount);
	if (outCenter) {
		*outCenter = center;
    }
	Translate(samples, samplePointsCount, -center.x, -center.y); // Recenter
	
	// Now rotate the path around 0,0, since the points have been transformed to that point.
	// Find the angle of the first point:
	CGPoint firstPoint = samples[0];
	float firstPointAngle = atan2(firstPoint.y, firstPoint.x);
	cootek_log(@"firstPointAngle=%0.2f", firstPointAngle*360.0f/(2.0f*M_PI));
	if (outRadians) {
		*outRadians = firstPointAngle;
    }
	Rotate(samples, samplePointsCount, -firstPointAngle);
	
	CGPoint lowerLeft = CGPointMake(0, 0), upperRight = CGPointMake(0, 0);
	for (i = 0; i < samplePointsCount; i++)
	{
		CGPoint pt = samples[i];
		if (pt.x < lowerLeft.x)
			lowerLeft.x = pt.x;
		if (pt.y < lowerLeft.y)
			lowerLeft.y = pt.y;
		if (pt.x > upperRight.x)
			upperRight.x = pt.x;
		if (pt.y > upperRight.y)
			upperRight.y = pt.y;
	}
	float scale = 2.0f/MAX(upperRight.x - lowerLeft.x, upperRight.y - lowerLeft.y);
	Scale(samples, samplePointsCount, scale, scale);
	
	center = Centroid(samples, samplePointsCount);
	Translate(samples, samplePointsCount, -center.x, -center.y); // Recenter
   
	// Now we can compare the samples against our known samples:
	NSString *bestTemplateName = nil;
	float best = INFINITY;
	for (NSString *templateName in [templates allKeys])
	{
		NSArray *templateSamples = [templates objectForKey:templateName];
		CGPoint template[samplePointsCount];
		NSAssert(samplePointsCount == [templateSamples count], @"Template size mismatch");
		for (i = 0; i < samplePointsCount; i++)
		{
			template[i] = [[templateSamples objectAtIndex:i] CGPointValue];
		}
		float score = DistanceAtBestAngle(samples, samplePointsCount, template);
		NSLog(@"  %@ => %0.2f", templateName, score);
		if (score < best)
		{
			bestTemplateName = [NSString stringWithString:templateName];
			best = score;
		}
	}
	cootek_log(@"Best: %@ with %0.2f", bestTemplateName, best);
	if (outScore) {
		*outScore = best;
    }
	
	self.resampledPoints = [NSMutableArray arrayWithCapacity:samplePointsCount];
	for (i = 0; i < samplePointsCount; i++)
	{
		CGPoint pt = samples[i];
		[resampledPoints addObject:[NSValue valueWithCGPoint:pt]];
	}

	[bestTemplateName retain]; // +1 retain count because it is autoreleased, and we're about to drain the pool.
	[pool release];
	return [bestTemplateName autorelease];
}
- (void)customGesture:(NSString *)name{
    if([self touchPoints].count < kSamplePointsCount) {
        cootek_log(@"Error: the sample points count is %d", [self touchPoints].count);
        return;
    }
    
    if([name length] == 0){
        return;
    }
    
    cootek_log(@"touchPoints=**********%@**********",touchPoints);
    int i = 0;
    const int samplePoints = kSamplePointsCount;
	CGPoint samples[samplePoints];
	int c = [[self touchPoints] count];
	
	// Load up the samples.  We use a very simplistic method for this; the JavaScript version is much more sophisticated.
	for (i = 0; i < samplePoints; i++)
	{
        int index = MAX(0, (c-1)*i/(samplePoints-1));
        if (index<c && index >= 0) {
            samples[i] = [[[self touchPoints] objectAtIndex:index] CGPointValue];
        }
	}
	
	CGPoint center = Centroid(samples, samplePoints);
	Translate(samples, samplePoints, -center.x, -center.y); // Recenter
    
	// Now rotate the path around 0,0, since the points have been transformed to that point.
	// Find the angle of the first point:
	CGPoint firstPoint = samples[0];
	float firstPointAngle = atan2(firstPoint.y, firstPoint.x);
	Rotate(samples, samplePoints, -firstPointAngle);

	CGPoint lowerLeft = CGPointMake(0, 0), upperRight = CGPointMake(0, 0); // For finding the boundaries of the gesture
	for (i = 0; i < samplePoints; i++)
	{
		CGPoint pt = samples[i];
		if (pt.x < lowerLeft.x)
			lowerLeft.x = pt.x;
		if (pt.y < lowerLeft.y)
			lowerLeft.y = pt.y;
		if (pt.x > upperRight.x)
			upperRight.x = pt.x;
		if (pt.y > upperRight.y)
			upperRight.y = pt.y;
	}

	float scale = 2.0f/MAX(upperRight.x - lowerLeft.x, upperRight.y - lowerLeft.y);

	Scale(samples, samplePoints, scale, scale);

	center = Centroid(samples, samplePoints);
	Translate(samples, samplePoints, -center.x, -center.y); // Recenter
    
    NSMutableArray *input = [NSMutableArray arrayWithCapacity:1];
	for (i = 0; i < samplePoints; i++)
	{
		CGPoint pt = samples[i];
        [input addObject:[NSValue valueWithCGPoint:pt]];
	}
    if ([input count] > 0) {
        [self.templates setObject:input forKey:name];
    }


}
//void ouputPointlist(CGPoint samples[], int count){
//	for (int i = 0; i < count; i++)
//	{		
//        CGPoint pt = samples[i];
//        cootek_log(@"Smapes i=%f,%f", pt.x, pt.y);
//	}
//}
- (void)removeGesture:(NSString *)name{
    [self.templates removeObjectForKey:name];
}
@end

CGPoint Centroid(CGPoint *samples, int samplePoints)
{
	CGPoint center = CGPointZero;
	for (int i = 0; i < samplePoints; i++)
	{
		CGPoint pt = samples[i];
		center.x += pt.x;
		center.y += pt.y;
	}
	center.x /= samplePoints;
	center.y /= samplePoints;
	return center;
}
void Translate(CGPoint *samples, int samplePoints, float x, float y)
{
	for (int i = 0; i < samplePoints; i++)
	{
		CGPoint pt = samples[i];
		samples[i] = CGPointMake(pt.x+x, pt.y+y);
	}
}
void Rotate(CGPoint *samples, int samplePoints, float radians)
{
	CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(radians);
	for (int i = 0; i < samplePoints; i++)
	{
		CGPoint pt0 = samples[i];
		CGPoint pt = CGPointApplyAffineTransform(pt0, rotateTransform);
		samples[i] = pt;
	}
}
void Scale(CGPoint *samples, int samplePoints, float xScale, float yScale)
{
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(xScale, yScale); //1.0f/(upperRight.x - lowerLeft.x), 1.0f/(upperRight.y - lowerLeft.y));
	for (int i = 0; i < samplePoints; i++)
	{
		CGPoint pt0 = samples[i];
		CGPoint pt = CGPointApplyAffineTransform(pt0, scaleTransform);
		samples[i] = pt;
	}
}
float Distance(CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	return sqrtf(dx * dx + dy * dy);
}
float PathDistance(CGPoint *pts1, CGPoint *pts2, int count)
{
	float d = 0.0;
	for (int i = 0; i < count; i++) // assumes pts1.length == pts2.length
		d += Distance(pts1[i], pts2[i]);
	return d / (float)count;
}
float DistanceAtAngle(CGPoint *samples, int samplePoints, CGPoint *template, float theta)
{
	const int maxPoints = 128;
	CGPoint newPoints[maxPoints];
	assert(samplePoints <= maxPoints);
	memcpy(newPoints, samples, sizeof(CGPoint)*samplePoints);
	Rotate(newPoints, samplePoints, theta);
	return PathDistance(newPoints, template, samplePoints);
}
float DistanceAtBestAngle(CGPoint *samples, int samplePoints, CGPoint *template)
{
	float a = -0.25f*M_PI;
	float b = -a;
	float threshold = 0.1f;
	float Phi = 0.5 * (-1.0 + sqrtf(5.0)); // Golden Ratio
	float x1 = Phi * a + (1.0 - Phi) * b;
	float f1 = DistanceAtAngle(samples, samplePoints, template, x1);
	float x2 = (1.0 - Phi) * a + Phi * b;
	float f2 = DistanceAtAngle(samples, samplePoints, template, x2);
	while (fabs(b - a) > threshold)
	{
		if (f1 < f2)
		{
			b = x2;
			x2 = x1;
			f2 = f1;
			x1 = Phi * a + (1.0 - Phi) * b;
			f1 = DistanceAtAngle(samples, samplePoints, template, x1);
		}
		else
		{
			a = x1;
			x1 = x2;
			f1 = f2;
			x2 = (1.0 - Phi) * a + Phi * b;
			f2 = DistanceAtAngle(samples, samplePoints, template, x2);
		}
	}
	return MIN(f1, f2);
}
