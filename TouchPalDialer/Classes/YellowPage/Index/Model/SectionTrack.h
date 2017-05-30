//
//  SectionTrack.h
//  TouchPalDialer
//
//  Created by tanglin on 15/10/26.
//
//

#import "SectionBase.h"
#import "IndexFilter.h"

@interface SectionTrack : SectionBase

@property(nonatomic, retain) IndexFilter* filter;

-(id) initWithJson:(NSDictionary*) json;
@end
