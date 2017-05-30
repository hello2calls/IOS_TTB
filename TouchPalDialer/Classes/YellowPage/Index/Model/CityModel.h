//
//  CityModel.h
//  TouchPalDialer
//
//  Created by tanglin on 15/8/26.
//
//

#import <Foundation/Foundation.h>

@interface CityModel : NSObject
@property(nonatomic, strong) NSString* capital;
@property(nonatomic, strong) NSArray* value;
@property(nonatomic, assign) BOOL expandable;
@property(nonatomic, assign) BOOL isExpanded;
@end
