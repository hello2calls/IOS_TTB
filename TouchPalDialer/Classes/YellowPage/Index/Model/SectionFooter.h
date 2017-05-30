//
//  SectionFooter.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#ifndef TouchPalDialer_SectionFooter_h
#define TouchPalDialer_SectionFooter_h

#import "SectionBase.h"

@interface SectionFooter : SectionBase

@property(nonatomic, retain) NSString* normal;
@property(nonatomic, retain) NSString* crazy;

- (id) initWithJson:(NSDictionary*)json;
@end

#endif
