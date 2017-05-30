//
//  Engine.h
//  TPDialerAdvancedTest
//
//  Created by Elfe Xu on 12-10-9.
//  Copyright (c) 2012年 Elfe Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NumberInfoModel.h"

@interface Engine : NSObject
-(id) initWithNumber:(NSString*) number;
-(void) queryLocation;
-(void) queryCallerId;
@property (nonatomic, retain) NSString* number;
@property (nonatomic, retain) NumberInfoModel* model;
@property (nonatomic, retain) NSString* text1;
@property (nonatomic, retain) NSString* text2;
@property (nonatomic, retain) NSString* text3;

@end

