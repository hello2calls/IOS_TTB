//
//  RegisterProtocol.h
//  TouchPalDialer
//
//  Created by Alice on 11-10-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RegisterProtocolDelegate
@optional
-(void)selectCountry;
-(void)selectCountryWithCountryName:(NSString *)name countryCode:(NSString *)code;
-(void)selectCountryWithCountryName:(NSString *)name countryCode:(NSString *)code carrier:(NSString *)carrier;
@end
