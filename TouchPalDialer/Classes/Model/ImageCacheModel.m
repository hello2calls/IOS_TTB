//
//  ImageCacheModel.m
//  TouchPalDialer
//
//  Created by Alice on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCacheModel.h"
#import "TPDialerResourceManager.h"
#import "PersonDBA.h"

@implementation ImageCacheModel

static ImageCacheModel *_sharedSingletonModel = nil;

+ (void)initialize
{
    _sharedSingletonModel = [[ImageCacheModel alloc] init];
}

+ (ImageCacheModel *)getShareInstance
{
	return _sharedSingletonModel;
}

- (id)init
{
	self = [super init];
	if (self != nil) {
        [self loadData];
    }
	return self;
}

- (void)loadData
{
    contact_default_photo =
    [PersonDBA getDefaultColorImageWithoutPersonID];
}

- (UIImage *)getContactPhoto
{
	return contact_default_photo;
}
@end
