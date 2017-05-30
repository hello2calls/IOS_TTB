//
//  GestureProvider.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GestureRecognizer.h"
#import "GLGestureRecognizer.h"
#import "GLGestureRecognizer+JSONTemplates.h"
#import "ContactCacheDataManager.h"
#import "NumberPersonMappingModel.h"
#import "CJSONSerialization.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "FunctionUtility.h"
#import "math.h"
#import "GestureUtility.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
//strokie
@implementation Strokie

@synthesize pointsArray = _pointsArray;

- (id)init{
    self = [super init];
    if (self) {
        _pointsArray = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}
-(void)addPointToStroike:(CGPoint)point{
    [_pointsArray addObject:[NSValue valueWithCGPoint:point]];
}
-(void)removeAllPoints{
    [_pointsArray removeAllObjects];
}

@end

//gestures
@implementation Gesture

@synthesize name = _name;
@synthesize strokiesArray = _strokiesArray;

-(CGRect) boundBox:(NSArray *)points {
    float minX = FLT_MAX;
    float maxX = -FLT_MAX;
    float minY = FLT_MAX;
    float maxY = -FLT_MAX;
    
    NSEnumerator *eachPoint = [points objectEnumerator];
    NSValue *v;
    CGPoint pt;
    while ( (v = (NSValue *)[eachPoint nextObject]) ) {
        pt = [v CGPointValue];
        
        if( pt.x < minX )
            minX = pt.x;
        if( pt.y < minY )
            minY = pt.y;
        if( pt.x > maxX )
            maxX = pt.x;
        if( pt.y > maxY )
            maxY = pt.y;
    }
    
    return CGRectMake(minX, minY, (maxX-minX), (maxY-minY));
}

// Get the square bound box. 
// If the original bound box is not a square, expand the width or height and keep the image in center.
-(CGRect) squareBoundBox:(NSArray *) points {
    CGRect box = [self boundBox:points];
    float width = box.size.width;
    float height = box.size.height;
    
    CGPoint newPoint;
    CGSize newSize;
    
    if (width == height) {
        return box;
    }else if(width > height) {
        float diff = width - height;
        newPoint = CGPointMake(box.origin.x, box.origin.y - diff/2);
        newSize = CGSizeMake(width, width);
    } else {
        float diff = height - width;
        newPoint = CGPointMake(box.origin.x - diff/2, box.origin.y);
        newSize = CGSizeMake(height, height);
    }
    
    return CGRectMake(newPoint.x, newPoint.y, newSize.width, newSize.height);
}

// Mapping the old point in old box, to new box.
-(CGPoint) mapPoint:(CGPoint)oldPoint fromOrigin:(CGPoint) origin  withPadding:(float)padding; { 
    float newX = (oldPoint.x - origin.x)  + padding;
    float newY = (oldPoint.y - origin.y) + padding;
    return CGPointMake(newX, newY);
}

-(UIImage *) convertToImage{
    const float paddingRatio = 0.2;
    
    // Currently only support 1 stroke. Need to modify a little bit to support multiple strokes.
    if([_strokiesArray count] != 1) {
        return nil;
    }
    
    NSArray *pointsArray= [[_strokiesArray objectAtIndex:0] pointsArray];
    if([pointsArray count] <=1) {
        return nil;
    }
    
    // get the square bound box
    CGRect box = [self squareBoundBox:pointsArray];
    float padding = box.size.width * paddingRatio;
    
    CGRect imageRect = CGRectMake(0, 0, box.size.width + padding * 2, box.size.height + padding * 2);
    UIGraphicsBeginImageContext(imageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, imageRect);
   
    CGContextSetLineWidth(context, (ceilf(imageRect.size.width/40) * 2));
    UIColor *color = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]?[TPDialerResourceManager getColorForStyle:@"skinGestureDrawBoardStroke_color"]:[[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"gestureDrawBoard_stroke_color"];
    CGContextSetStrokeColorWithColor(context,[color CGColor]);
          
    int pointCount = [pointsArray count];
    CGPoint tmpPoint =[self mapPoint:[[pointsArray objectAtIndex:0] CGPointValue] fromOrigin:box.origin withPadding:padding];
    CGContextMoveToPoint(context, tmpPoint.x, tmpPoint.y);
    for(int i=1; i<pointCount; i++) {
        tmpPoint = [self mapPoint:[[pointsArray objectAtIndex:i] CGPointValue] fromOrigin:box.origin withPadding:padding];
        CGContextAddLineToPoint(context, tmpPoint.x, tmpPoint.y);
    }          
                  
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(id)initWithGesture:(NSString *)name{
    self = [super init];
    if (self) {
        _strokiesArray = [[NSMutableArray alloc] initWithCapacity:1];
        self.name = name;
    }
    return self;

}
-(void)addStrokieToGesture:(Strokie *)strokie{
    if (strokie) {
        [_strokiesArray addObject:strokie];
    }
 }
-(void)removeStrokieToGesture:(Strokie *)strokie{
    if (strokie) {
        [_strokiesArray removeObject:strokie];
    }
}

-(void)removeAllStrokies{
    [_strokiesArray removeAllObjects];
}
@end

//gestures
@implementation GesturesResults

@synthesize name = _name;
@synthesize score = _score;

@end

@interface GestureRecognizer (){
    GLGestureRecognizer *recognizer;
}
-(NSString *)getGesturePath;
-(NSString *)getLibriayPath;
-(NSString *)getOptionalGesturePath;
-(NSString *)getGesturePathVersion4310;
-(NSMutableDictionary *)loadLibrary;
-(NSMutableDictionary *)loadOptionalLibrary;
-(NSString *)getGestureKeyPath;
-(void)reloadTempalteData;
-(void)validateGesture;
@end

@implementation GestureRecognizer
-(NSString *)getLibriayPath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return  [documentDirectory stringByAppendingPathComponent:@"Library.json"];
}
-(NSString *)getGestureKeyPath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return  [documentDirectory stringByAppendingPathComponent:@"GestureName.plist"];
}
-(NSString *)getOptionalGesturePath{
    NSString *fileTemplatesPath = [[NSBundle mainBundle] pathForResource:@"GesturesLibrary" ofType:@"json"];
    return fileTemplatesPath;
}
-(NSString *)getGesturePath{
    NSString *fileVersionPath = [self getGesturePathVersion4310];
    return fileVersionPath;
}
-(void)reloadTempalteData{
    NSMutableDictionary  *dicPoint = [self loadLibrary];
    NSArray *keys =[dicPoint allKeys];
    for (NSString *name in keys) {
        NSMutableArray *pointList = [dicPoint objectForKey:name];
        if (pointList) {
            //read
            Gesture *gesture = [[Gesture alloc] initWithGesture:name];
            Strokie *stroke = [[Strokie alloc] init];
            stroke.pointsArray = pointList;
            [gesture addStrokieToGesture:stroke];
            //write
            [recognizer resetTouches];
            [recognizer addPointList:stroke.pointsArray];
            [recognizer customGesture:gesture.name];
        }
    }
    [recognizer saveTemplatesAsJsonData:[self getGesturePath]];
}
-(NSString *)getGesturePathVersion4310{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return  [documentDirectory stringByAppendingPathComponent:@"GesturesVersion4310.json"];
}
-(NSMutableDictionary *)loadOptionalLibrary{
    NSString *path = [self getOptionalGesturePath];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
	NSError *error = nil;
	NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	NSMutableDictionary *output = [NSMutableDictionary dictionary];
	for (NSString *key in [dict allKeys])
	{
		NSArray *value = [dict objectForKey:key];
		NSMutableArray *points = [NSMutableArray array];
		for (NSArray *pointArray in value)
		{
			[points addObject:[NSValue valueWithCGPoint:CGPointMake([[pointArray objectAtIndex:0] floatValue], [[pointArray objectAtIndex:1] floatValue])]];
		}
		[output setObject:points forKey:key];
	}
    return output;
}
-(void)validateGesture{
    NSString *path = [self getGestureKeyPath];
    NSMutableArray *keyNameArray = [NSMutableArray arrayWithContentsOfFile:path];
    NSMutableArray *removeKeyArray = [NSMutableArray arrayWithCapacity:1];
    int count = [keyNameArray count];
    for (int i=0;i<count;i++) {  
        NSString *key = [keyNameArray objectAtIndex:count-i-1];
        BOOL is_number = [GestureUtility isValideGesture:key];
        if (!is_number) {
            [removeKeyArray addObject:key];
        }
    }
    for (NSString *key in removeKeyArray) {
        [self removeGesture:key];
    }
}
-(NSMutableDictionary *)loadLibrary{
    NSString *path = [self getLibriayPath];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
	NSError *error = nil;
	NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	NSMutableDictionary *output = [NSMutableDictionary dictionary];
	for (NSString *key in [dict allKeys])
	{
		NSArray *value = [dict objectForKey:key];
		NSMutableArray *points = [NSMutableArray array];
		for (NSArray *pointArray in value)
		{
			[points addObject:[NSValue valueWithCGPoint:CGPointMake([[pointArray objectAtIndex:0] floatValue], [[pointArray objectAtIndex:1] floatValue])]];
		}
		[output setObject:points forKey:key];
	}

    return output;
}

//public
-(DefaultGestureType)getDefaultGestureType;{
    
    NSMutableDictionary  *dicPoint = [self loadLibrary];
    if (dicPoint) {
        NSArray *tmpCall = [dicPoint objectForKey:@"Call_First"];
        NSArray *tmpSms = [dicPoint objectForKey:@"Sms_First"];
        if (tmpSms&&tmpCall) {
            return DefaultGestureBoth;
        }else if (tmpSms){
            return DefaultGestureSms;
        }else if (tmpCall){
            return DefaultGestureCall;
        }
    }
    return DefaultGestureNone;
}


-(NSArray *)getGestureList{
    
    [self validateGesture];
    NSMutableDictionary  *dicPoint = [self loadLibrary];
    if (dicPoint) {
        NSMutableArray *gesture_list = [NSMutableArray arrayWithCapacity:1];
        NSString *path = [self getGestureKeyPath];
        NSMutableArray *keyNameArray = [NSMutableArray arrayWithContentsOfFile:path];
        int count = [keyNameArray count];
        for (int i=0;i<count;i++) {  
            NSString *key = [keyNameArray objectAtIndex:count-i-1];
            NSMutableArray *pointList = [dicPoint objectForKey:key];
            if (pointList) {
                Gesture *gesture = [[Gesture alloc] initWithGesture:key];
                Strokie *stroke = [[Strokie alloc] init];
                stroke.pointsArray = pointList;
                [gesture addStrokieToGesture:stroke];
                [gesture_list addObject:gesture];
            }
        }
        return gesture_list;

    }
    return nil;
    
}
//public
-(NSArray *)getOptionalGestureList{
    NSMutableDictionary  *dicPoint = [self loadOptionalLibrary ];
    if (dicPoint) {
        NSMutableArray *gesture_list = [NSMutableArray arrayWithCapacity:1];
        for (NSString *key in [dicPoint allKeys]) {
            NSMutableArray *pointList = [dicPoint objectForKey:key];
            if (pointList) {
                Gesture *gesture = [[Gesture alloc] initWithGesture:key];
                Strokie *stroke = [[Strokie alloc] init];
                stroke.pointsArray = pointList;
                [gesture addStrokieToGesture:stroke];
                [gesture_list addObject:gesture];
            }
        }
        return gesture_list;
    }
    return nil;

}
-(Gesture *)getGesture:(NSString *)name
{
    [self validateGesture];
    NSMutableDictionary  *dicPoint = [self loadLibrary];
    NSMutableArray *pointList = [dicPoint objectForKey:name];
    if (pointList) {
        Gesture *gesture = [[Gesture alloc] initWithGesture:name];
        Strokie *stroke = [[Strokie alloc] init];
        stroke.pointsArray = pointList;
        [gesture addStrokieToGesture:stroke];
        return gesture;
    }
    return nil;
}
-(id)initGestureRecognizer{
    self = [super init];
    if (self) {
        NSFileManager *fm = [NSFileManager defaultManager]; 
        NSString *filePath = [self getGesturePath];
        NSString *originalPath = [self getLibriayPath];
        
        BOOL isExtisGesturePath = [fm fileExistsAtPath:filePath];
        BOOL isExtisOriginal = [fm fileExistsAtPath:originalPath];
        
        recognizer = [[GLGestureRecognizer alloc] init];
        if (!isExtisGesturePath&&isExtisOriginal) {
            [self reloadTempalteData];
        }else {
            if (isExtisOriginal) {
                [recognizer loadTemplatesFromJsonData:filePath]; 
            }
        }
    }
    return self;
}
-(void)addGesture:(Gesture *)gesture{
    if (gesture) {
        
        if ([gesture.strokiesArray count] == 1
             && [gesture.name length] > 0) {
            [recognizer resetTouches];
             Strokie *stokie = [gesture.strokiesArray objectAtIndex:0];
            [recognizer addPointList:stokie.pointsArray];
            [recognizer customGesture:gesture.name];
            [recognizer saveTemplatesAsJsonData:[self getGesturePath]];
            
            //record original point array
            NSMutableDictionary *originaldic = [self loadLibrary];
            if (originaldic == nil) {
                originaldic = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            [originaldic setObject:stokie.pointsArray forKey:gesture.name];
            
            //save original
            NSString *path = [self getLibriayPath];
            NSError *error = nil;
            NSData *jsonData = [[CJSONSerializer serializer] serializeDictionary:originaldic error:&error];
            [jsonData writeToFile:path atomically:YES];
            
            //key name
            path = [self getGestureKeyPath];
            NSMutableArray *keyNameArray = [NSMutableArray arrayWithContentsOfFile:path];
            if (!keyNameArray) {
                keyNameArray =[NSMutableArray arrayWithCapacity:1];
            }
            if (![keyNameArray containsObject:gesture.name]) {
                [keyNameArray addObject:gesture.name];
            }
            [keyNameArray writeToFile:path atomically:YES];      
        }
    }
}
-(void)removeGesture:(NSString *)gestureName{
    if (gestureName) {
        [recognizer removeGesture:gestureName];    
        [recognizer saveTemplatesAsJsonData:[self getGesturePath]];
        
        //save original files
        NSMutableDictionary *originaldic = [self loadLibrary];
        if (originaldic != nil) {
            [originaldic removeObjectForKey:gestureName];
            //save original
            NSString *path = [self getLibriayPath];
            NSError *error = nil;
            NSData *jsonData = [[CJSONSerializer serializer] serializeDictionary:originaldic error:&error];
            [jsonData writeToFile:path atomically:YES];
            //key name
            path = [self getGestureKeyPath];
            NSMutableArray *keyNameArray = [NSMutableArray arrayWithContentsOfFile:path];
            if (!keyNameArray) {
                keyNameArray =[NSMutableArray arrayWithCapacity:1];
            }
            if ([keyNameArray containsObject:gestureName]) {
                  [keyNameArray removeObject:gestureName];
            }
          
            [keyNameArray writeToFile:path atomically:YES];  
        }
    
    }
}
-(GesturesResults *)recognizerGesture:(Gesture *)gesture{
    if (gesture) {
        if ([gesture.strokiesArray count] == 1) {
            [recognizer resetTouches];
            Strokie *stokie = [gesture.strokiesArray objectAtIndex:0];
            [recognizer addPointList:stokie.pointsArray];
        }
        //save original files
    }
    CGPoint center = CGPointZero;
	float score =INFINITY;
    float angle = 0;
	NSString *gestureName = [recognizer findBestMatchCenter:&center angle:&angle score:&score];
	cootek_log(@"%@",[NSString stringWithFormat:@"%@ (%0.2f, %d)", gestureName, score, (int)(360.0f*angle/(2.0f*M_PI))]);
    GesturesResults *reuslt = [[GesturesResults  alloc] init];
    reuslt.name = gestureName;
    reuslt.score = score;
    return reuslt;
}
@end
