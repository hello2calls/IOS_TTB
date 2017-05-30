//
//  RuleModel.h
//  TouchDataAcess
//
//  Created by Alice on 11-9-5.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DialMethordModel.h"
//Romaing Type

#define Romaing_INTERNATIONAL      0
#define Romaing_INTER_MSC          1
#define Romaing_REGIONAL           2
#define Romaing_DOMESTIC           3
#define Romaing_HOME_ONLY          4
#define Romaing_INTER_MSC_AND_HOME 5
#define Romaing_REGIONAL_AND_HOME  6
#define Romaing_DOMESTIC_AND_HOME  7
#define Romaing_ANY                8

//Destination Type
#define Destination_HOME                  0
#define Destination_REGION                1
#define Destination_DOMESTIC              2
#define Destination_INTER_MSC             3
#define Destination_INTERNATION           4
#define Destination_ANY                   5
#define Destination_CROSS_INTERNATIONALLY 6
#define Destination_CROSS_DOMESTICLY      7
#define Destination_PATTERN               8

//dial Type
#define Dial_DEFAULT   0
#define Dial_E164      1
#define Dial_DOMESTIC  2
#define Dial_LOCAL     3
#define Dial_CALL_BACK 4
#define Dial_CARD      5
#define Dial_DIRECT    6
#define Dial_VOIP      7
#define Dial_ANY       8


@interface RuleModel : NSObject
@property(nonatomic,assign) NSInteger ID;
@property(nonatomic,assign) NSInteger romaingType;
@property(nonatomic,assign) NSInteger source;
@property(nonatomic,assign) NSInteger destinationType;
@property(nonatomic,assign) BOOL isEnable;
@property(nonatomic,assign) NSInteger dailruleType;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *key;
@property(nonatomic,retain) NSString *description;
@property(nonatomic,retain) NSString *destinationPattern;
@property(nonatomic,retain) NSString *number;
@property(nonatomic,retain) DialMethordModel *dialMethod;

@end
