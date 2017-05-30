//
//  SectionFavourite.h
//  TouchPalDialer
//
//  Created by tanglin on 15-6-25.
//
//

#ifndef TouchPalDialer_SectionFavourite_h
#define TouchPalDialer_SectionFavourite_h

#import "SectionBase.h"

@class IndexFilter;
@interface SectionFavourite : SectionBase

@property(nonatomic,retain) NSString* title;

- (id) initWithJson: (NSDictionary*) json;
@end

#endif
