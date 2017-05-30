//
//  GZipUltis.h
//  TouchPalDialer
//
//  Created by Alice on 12-1-12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSDataExtension)

// GZIP
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;
@end
