//
//  NumberInfoModel.h
//  TPDialerAdvanced
//
//  Created by Elfe Xu on 12-10-9.
//
//

#import <Foundation/Foundation.h>

@interface NumberInfoModel : NSObject

- (id) initWithNumber:(NSString*) number;
-(void) loadLocation;
-(BOOL) loadCallerId;

- (BOOL) isCallerIdUseful;
- (BOOL) hasTag;
- (void) printInfo;

- (NSString*) textForNumber:(NSString*) number originalText:(NSString*) oriText originalLabel:(NSString*) oriLabel hasLocation:(BOOL)hasLocation;

@property (nonatomic, retain) NSString* rawNumber;
@property (nonatomic, retain) NSString* normalizedNumber;
@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* classify;
@property (nonatomic, retain) NSString* versionTime;
@property (nonatomic, assign) BOOL verified;
@property (nonatomic, assign) NSInteger markCount;
@property (nonatomic, assign) NSInteger cacheLevel;
@property (nonatomic, assign) NSInteger vipId;
@property (nonatomic, assign) BOOL isCallerId;

@end

@interface NSString(tputil)

-(BOOL) containsSubString:(NSString *)str;

@end
