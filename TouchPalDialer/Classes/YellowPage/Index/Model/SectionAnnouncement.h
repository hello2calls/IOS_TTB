//
//  SectionAnnouncement.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-15.
//
//

#ifndef TouchPalDialer_SectionAnnouncement_h
#define TouchPalDialer_SectionAnnouncement_h

#import "SectionBase.h"

@class CTUrl;
@class IndexFilter;

@interface SectionAnnouncement : SectionBase

@property(nonatomic, retain) NSString* style;
@property(nonatomic, retain) NSString* text;
@property(nonatomic, retain) CTUrl* ctUrl;

- (id) initWithJson:(NSDictionary*) json;
@end

#endif
