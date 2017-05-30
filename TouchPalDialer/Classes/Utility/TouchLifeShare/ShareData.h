//
//  ShareData.h
//  TouchPalDialer
//
//  Created by junhzhan on 8/12/15.
//
//

#import <Foundation/Foundation.h>

@interface ShareData : NSObject
@property (readonly) NSString* instantBonusType;
@property (readonly) NSString* instantBonusQuantity;
@property (readonly) NSString* shareBonusMessage;
@property (readonly) NSString* shareBonusQuantity;
@property (readonly) NSString* shareBonusHint;
@property (readonly) NSString* shareMessage;
@property (readonly) NSString* shareUrl;
@property (readonly) NSString* shareTitle;
@property (readonly) NSString* shareImageUrl;
@property (readonly) NSString* shareButtonTitle;
@property (readonly) NSString* uiVersion;

- (id)initWithInstantBonusType:(NSString*)str instantBonusQuantity:(NSString*)str shareBonusMessage:(NSString*)str shareBonusQuantity:(NSString*)str shareBonusHint:(NSString*)str shareMessage:(NSString*)str shareUrl:(NSString*)str shareTitle:(NSString*)str shareImageUrl:(NSString*)str shareButtonTitle:(NSString*)str uiVersion:(NSString*)str;
@end
