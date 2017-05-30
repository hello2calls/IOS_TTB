//
//  ActivityItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15-5-11.
//
//

#ifndef TouchPalDialer_ActivityItem_h
#define TouchPalDialer_ActivityItem_h

@class IndexFilter;
@interface ActivityItem : NSObject

@property(nonatomic, retain) IndexFilter* filter;
@property(nonatomic, retain) NSNumber* count;
@property(nonatomic, retain) NSString* iconZipLink;
@property(nonatomic, retain) NSString* iconPicLink;

- (id)initWithJson:(NSDictionary*)json;
- (BOOL) isValid;
@end

#endif
