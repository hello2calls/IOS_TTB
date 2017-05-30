//
//  HighLightItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-17.
//
//

#ifndef TouchPalDialer_HighLightItem_h
#define TouchPalDialer_HighLightItem_h

@interface HighLightItem : NSObject<NSCopying, NSMutableCopying, NSCoding>

@property(nonatomic, retain) NSString* type;
@property(nonatomic, retain) NSString* hotKey;
@property(nonatomic,retain) NSNumber* highlightStart;
@property(nonatomic,retain) NSNumber* highlightDuration;
@property(nonatomic, assign) BOOL hiddenOnclick;

-(BOOL) isValid;
- (id) initWithJson:(NSDictionary*) json;
@end

#endif
