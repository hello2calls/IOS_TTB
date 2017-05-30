//
//  LCDUpdator.h
//  TPDialerAdvanced
//
//  Created by Xu Elfe on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    UTUnknown,
    UTMobilePhone,
    UTFull,
    UTOldFull
} UpdatorType;

@interface LCDUpdator : NSObject

@property (nonatomic, retain) id hookee; //The object been hooked
@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) NSString* label;
@property (nonatomic, retain) NSString* number;
@property unsigned breakPoint;
@property UpdatorType updatorType;

-(void) update;

@end
