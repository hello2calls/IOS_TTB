//
//  IndexFilter.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-22.
//
//

#ifndef TouchPalDialer_IndexFilter_h
#define TouchPalDialer_IndexFilter_h

@interface IndexFilter : NSObject<NSCopying, NSMutableCopying, NSCoding>

@property (nonatomic, retain) NSString* os;
@property (nonatomic, retain) NSNumber* start;
@property (nonatomic, retain) NSNumber* duration;
@property (nonatomic, retain) NSArray* openCities;
@property (nonatomic, retain) NSArray* closeCities;
//TODO:
@property (nonatomic, retain) NSNumber* minApiLevel;
@property (nonatomic, retain) NSNumber* maxApiLevel;
@property (nonatomic, retain) NSNumber* minVersion;
@property (nonatomic, retain) NSNumber* maxVersion;
@property (nonatomic, retain) NSNumber* minZip;
@property (nonatomic, retain) NSNumber* maxZip;

@property (nonatomic, retain) NSNumber* minOSVersion;
@property (nonatomic, retain) NSNumber* maxOSVersion;
- (id) initWithJson:(NSDictionary*) json;
- (BOOL) isValid;
@end


#endif
