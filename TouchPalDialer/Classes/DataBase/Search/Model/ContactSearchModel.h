//
//  ContactSearchModel.h
//  TouchPalDialer
//
//  Created by Alice on 11-12-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchEngineThread.h"
#import "SearchEngineInputSource.h"
#import "SearchResultModel.h"
#import "TPContactSeach.h"

@interface ContactSearchModel : NSObject

- (void)query:(NSString *)content;

- (id)initWithSearchType:(SearchType)type;

@end
