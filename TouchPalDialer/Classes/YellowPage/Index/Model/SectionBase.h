//
//  SectionBase.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-22.
//
//

#ifndef TouchPalDialer_SectionBase_h
#define TouchPalDialer_SectionBase_h

@class IndexFilter;

@interface SectionBase : NSObject<NSCopying, NSMutableCopying>

@property (nonatomic, strong) IndexFilter* filter;
@property (nonatomic, strong) NSMutableArray* items;

- (BOOL) isValid;
- (id) validCopy;
@end

#endif
