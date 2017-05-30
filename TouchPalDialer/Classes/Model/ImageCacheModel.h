//
//  ImageCacheModel.h
//  TouchPalDialer
//
//  Created by Alice on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCacheModel : NSObject {
	UIImage __strong *contact_default_photo;
}
+ (ImageCacheModel *)getShareInstance;
- (UIImage *)getContactPhoto;
- (void)loadData;
@end
