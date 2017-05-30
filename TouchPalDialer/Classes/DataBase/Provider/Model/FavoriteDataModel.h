//
//  FavoriteDataModel.h
//  Dialer
//
//  Created by Ben_Lin_1373 on 11-4-28.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneDataModel.h"

@interface FavoriteDataModel : NSObject

@property (nonatomic , assign) NSInteger  personID ;
@property (nonatomic , retain) NSString  *personName ;
@property (nonatomic , retain) PhoneDataModel  *mainPhone ;
@property (nonatomic , retain) UIImage   *photoData ;

@end
