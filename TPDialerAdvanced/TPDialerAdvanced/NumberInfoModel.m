//
//  NumberInfoModel.m
//  TPDialerAdvanced
//
//  Created by Elfe Xu on 12-10-9.
//
//

#import "NumberInfoModel.h"
#import "NumberUtil.h"
#import "OrlandoEngine.h"
#import "DatabaseEngine.h"
#import "SeattleEngine.h"
#import "Util.h"
#import "TPDialerAdvanced.h"
#import "AdvancedSettingKeys.h"

#define attr_type 1
#define attr_type_short 3

#define SECURITY_LEVEL_NOMAL @"normal"
#define SECURITY_LEVEL_CRANK @"crank"
#define SECURITY_LEVEL_FRAUD @"fraud"
#define CALLER_TYPE_OTHERS   @"others"
#define TAG_FRAUD_PHONE      @"maybe fraud"
#define TAG_CRANK_PHONE      @"maybe crank"

@implementation NumberInfoModel

@synthesize rawNumber;
@synthesize normalizedNumber;
@synthesize name;
@synthesize location;
@synthesize classify;
@synthesize markCount;
@synthesize isCallerId;

static NSArray* allKnownCallerTypes;

+ (void)initialize
{
    allKnownCallerTypes = [[NSArray alloc] initWithObjects:
                           @"house agent",
                           @"insurance",
                           @"financial products",
                           @"headhunting",
                           @"promote sales",
                           @"repair",
                           @"book hotel/airline",
                           @"public services",
                           @"express",
                           @"fraud",
                           @"crank",
                           nil];
}


- (id) initWithNumber:(NSString*) number {
    [super init];
    self.normalizedNumber = [NumberUtil getNormalizedNumberAccordingNetwork:number];
    self.name = @"";
    self.location = @"";
    self.classify = @"";
    self.markCount = 0;
    self.isCallerId = NO;
    return self;
}

-(void) loadLocation {
    // Get location
    // For Chinese cities, the string is usually short, so we can use full location string.
    // Otherwise, we will get short location string to save display space.
    NSInteger attrType = [normalizedNumber hasPrefix:@"+86"] ? attr_type : attr_type_short;
    NSString* loc = [NumberUtil getNumberAttr:normalizedNumber withType:attrType];
    if(loc != nil && [loc length] > 0) {
        self.location = [NSString stringWithFormat:@"(%@)", loc];
    } else {
        self.location = @"";
    }
}

//-(BOOL) fillCallerIdForTest
//{
//    if([self.normalizedNumber isEqualToString:@"***111"]) {
//        self.securityLevel = SECURITY_LEVEL_FRAUD;
//        self.crankType = @"others";
//        self.name = @"";
//        self.isCallerId = YES;
//        self.crankCount = 0;
//        self.fraudCount = 0;
//        return YES;
//    }
//    
//    return NO;
//}

-(BOOL) loadCallerId {
    cootek_log_function;
    
    BOOL found = NO;
//#if DEBUG
//    found = [self fillCallerIdForTest];
//    if(found) {
//        cootek_log(@"this is a test number");
//        return found;
//    }
//    
//#endif
    
    NSNumber* useNetwork = [TPDialerAdvanced querySetting:ADVANCED_SETTING_USE_NETWORK_SMART_EYE];
    cootek_log(@"%@", useNetwork);
    if([useNetwork boolValue]) {
        found = [SeattleEngine fillNumberInfo:self];
        if(found) {
            [DatabaseEngine addData:self];
            return self.isCallerId;
        }
    }
    
    found = [DatabaseEngine fillNumberInfo:self];
    if(found) {
        cootek_log(@"found item in database.");
        return found;
    }
    
    found = [OrlandoEngine fillNumberInfo:self];
    if(found) {
        cootek_log(@"found item in orlando.");
        [DatabaseEngine addData:self];
        return found;
    }

    return found;
}

- (BOOL) isCallerIdUseful {
    if(self.name.length > 0) {
        return YES;
    }
    
    return [self hasTag];
}

- (BOOL) hasTag {
    return [self.classify length] > 0;
}

- (void) printInfo {
    cootek_log(@"%@ %@ %@ %d", rawNumber, name, classify, markCount);
}

- (NSString*) localizedTag {
    if(!self.isCallerId) {
        return @"";
    }

    NSString* tag = [self classify];

    tag = NSLocalizedStringFromTable(tag, @"TPDialerAdvanced", @"");
    NSString* addTag = @"";
    if (markCount > 0) {
        NSString* format = NSLocalizedStringFromTable(@"(%d marks)", @"TPDialerAdvanced", @"");
        addTag = [NSString stringWithFormat:format, markCount];
    }

	return [NSString stringWithFormat:@"%@%@",tag, addTag];
}

- (NSString*) textForNumber:(NSString*) number originalText:(NSString*) oriText originalLabel:(NSString*) oriLabel hasLocation:(BOOL)hasLocation {
    NSString* surfix = self.name;
    
    NSString* prefix = [self localizedTag];
    
    surfix = [NumberInfoModel removeDupelicateStr:surfix forText:oriText label:oriLabel];
    prefix = [NumberInfoModel removeDupelicateStr:prefix forText:oriText label:oriLabel];
    
    if(surfix != nil && [surfix length] > 0) {
        surfix = [NSString stringWithFormat:@" %@ ", surfix];
    } else {
        surfix = @"";
    }
    
    if(prefix != nil && [prefix length] > 0) {
        prefix = [NSString stringWithFormat:@"%@:", prefix];
    } else {
        prefix = @"";
    }
    
    if(hasLocation) {
        if(self.location != nil && [self.location length] > 0) {
            if([oriText containsSubString:self.location]) {
                oriText = [oriText stringByReplacingOccurrencesOfString:self.location withString:@""];
            }
        } 
        return [NSString stringWithFormat:@"%@%@%@%@", prefix, oriText, surfix, self.location];
    } else {
        return [NSString stringWithFormat:@"%@%@%@", prefix, oriText, surfix];
    }
}

+(NSString*) removeDupelicateStr:(NSString*) str forText:(NSString*) oriText label:(NSString*) oriLabel {
    if(str != nil && [str length] > 0) {
        if(oriText != nil && [oriText containsSubString:str]) {
            cootek_log(@"text %@ already contains %@", oriText, str);
            return nil;
        }
        
        if(oriLabel != nil && [oriLabel containsSubString:str]) {
            cootek_log(@"label %@ already contains %@", oriLabel, str);
            return nil;
        }
    }
    
    return str;
}

@end

@implementation NSString(tputil)

-(BOOL) containsSubString:(NSString *)str {
    cootek_log_function;
    if([self length] == 0 ) {
        return [str length] == 0;
    }
    
    NSRange r = [self rangeOfString:str];
    return (r.location != NSNotFound);
}

@end
