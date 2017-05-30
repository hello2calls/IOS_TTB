//
//  PrepareAdModel.m
//  TouchPalDialer
//
//  Created by lingmeixie on 16/9/12.
//
//

#import "PrepareAdModel.h"


@interface PrepareAdItem ()
@end

@implementation PrepareAdItem

+ (PrepareAdItem *)adItems:(NSString *)htmlPath
                    adPath:(NSString *)adPath
                   request:(NSString *)uuid
                   expired:(long)expired
                      idws:(BOOL)idws
                     wtime:(int)wtime
{
    PrepareAdItem *ad = [[PrepareAdItem alloc] init];
    ad.htmlPath = htmlPath;
    ad.expired = expired;
    ad.idws = idws;
    ad.wtime = wtime;
    ad.adPath = adPath;
    ad.uuid = uuid;
    return ad;
}

- (BOOL)isItemExpired {
    long interval = (long)[[NSDate date] timeIntervalSince1970] * 1000;
    return ((long)interval - self.expired) >= 0;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.htmlPath forKey:@"htmlPath"];
    [aCoder encodeObject:self.adPath forKey:@"adPath"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeInt64:self.expired forKey:@"expired"];
    [aCoder encodeInt32:self.wtime forKey:@"wtime"];
    [aCoder encodeBool:self.idws forKey:@"idws"];
    [aCoder encodeBool:self.dispaly forKey:@"display"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.htmlPath = [aDecoder decodeObjectForKey:@"htmlPath"];
        self.adPath = [aDecoder decodeObjectForKey:@"adPath"];
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.expired = [aDecoder decodeInt64ForKey:@"expired"];
        self.wtime =  [aDecoder decodeInt32ForKey:@"wtime"];
        self.idws = [aDecoder decodeBoolForKey:@"idws"];
        self.dispaly = [aDecoder decodeBoolForKey:@"display"];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    PrepareAdItem *ad = [[PrepareAdItem alloc] init];
    ad.htmlPath = [self.htmlPath copy];
    ad.expired = self.expired;
    ad.idws = self.idws;
    ad.wtime = self.wtime;
    ad.adPath = [self.adPath copy];
    ad.dispaly = self.dispaly;
    ad.uuid = [self.uuid copy];
    ad.fullHtmlPath = [self.fullHtmlPath copy];
    return ad;
}

@end

@implementation PrepareAdModel

@synthesize tu = _tu;

- (PrepareAdModel *)initWithTu:(NSString *)tu delegate:(id<PrepareAdDelegate>) delegate {
    self = [super init];
    if (self) {
        _tu = [tu copy];
        _delegate = delegate;
    }
    return self;
}

- (BOOL)needRequestPrepare {
    return true;
}

- (BOOL)deleteAd {
     return true;
}

- (BOOL)executePrepareAd {
     return true;
}

- (BOOL)saveAd {
    return true;
}

- (BOOL)downloadAdResource {
    return true;
}

- (BOOL)allResourceDownloaded {
    return true;
}

- (PrepareAdItem *)prepareItem {
    return nil;
}

- (void)didShowPrepareAd {
}
@end
