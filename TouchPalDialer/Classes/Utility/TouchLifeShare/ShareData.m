//
//  ShareData.m
//  TouchPalDialer
//
//  Created by junhzhan on 8/12/15.
//
//

#import "ShareData.h"

@implementation ShareData

- (id)initWithInstantBonusType:(NSString*)typeStr instantBonusQuantity:(NSString*)quantityStr shareBonusMessage:(NSString*)message shareBonusQuantity:(NSString*)shareQuantity shareBonusHint:(NSString*)hint shareMessage:(NSString*)shareMessage shareUrl:(NSString*)shareUrl shareTitle:(NSString*)shareTitle shareImageUrl:(NSString*)imageUrl shareButtonTitle:(NSString*)shareButtontTitle uiVersion:(NSString*)uiVersion{
    self = [super init];
    if (self) {
        _instantBonusType = typeStr;
        _instantBonusQuantity = quantityStr;
        _shareBonusMessage = message;
        _shareBonusQuantity = shareQuantity;
        _shareBonusHint = hint;
        _shareMessage = shareMessage;
        _shareUrl = shareUrl;
        _shareTitle = shareTitle;
        _shareImageUrl = imageUrl;
        _shareButtonTitle = shareButtontTitle;
        _uiVersion = uiVersion;
    }
    return self;
}
@end
