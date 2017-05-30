//
//  BaseItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#ifndef TouchPalDialer_SectionGroup_h
#define TouchPalDialer_SectionGroup_h

@interface SectionGroup : NSObject
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, retain) NSString* sectionType;
@property(nonatomic, retain) NSMutableArray* sectionArray;
@property(nonatomic, assign) NSInteger current;

- (id) initWithType: (NSString*) type andIndex: (NSInteger)idx;
- (BOOL) isValid;
- (id) validCopy;
- (id) copyAll;
- (id) getPreviousItem;
- (id) getNextItem;
@end
#endif