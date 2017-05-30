//
//  SectionSeparator.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#ifndef TouchPalDialer_SectionSeparator_h
#define TouchPalDialer_SectionSeparator_h

#import "SectionBase.h"

@interface SectionSeparator : SectionBase
@property(nonatomic, strong) NSDictionary* attrs;
- (id) initWithJson: (NSDictionary*) json;
@end

#endif
