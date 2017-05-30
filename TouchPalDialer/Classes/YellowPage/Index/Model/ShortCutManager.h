//
//  ShortCutManager.h
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 16/5/17.
//
//

#ifndef ShortCutManager_h
#define ShortCutManager_h
@interface ShortCutManager : NSObject<NSCopying, NSMutableCopying, NSCoding>

@property (nonatomic, assign) BOOL sendToDeskTop;
@property (nonatomic, retain) NSString* shortCutTitle;
@property (nonatomic, retain) NSString* shortCutIcon;

- (id)initWithJson:(NSDictionary*) json;
- (BOOL)isValid;

@end

#endif /* ShortCutManager_h */
