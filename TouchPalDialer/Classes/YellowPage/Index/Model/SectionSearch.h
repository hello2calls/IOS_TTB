//
//  SectionSearch.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#ifndef TouchPalDialer_SectionSearch_h
#define TouchPalDialer_SectionSearch_h

#import "SectionBase.h"

@class SearchItem;
@class CTUrl;

@interface SectionSearch : SectionBase

@property(nonatomic, retain) NSString* tips;
@property(nonatomic, retain) NSString* input;
@property(nonatomic, retain) NSString* city;
@property(nonatomic, retain) CTUrl* ctUrl;

- (id) initWithJson:(NSDictionary*) json;
@end

#endif
