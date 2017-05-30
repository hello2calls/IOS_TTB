//
//  OperationCommandCreator.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-13.
//
//

#import <Foundation/Foundation.h>

#import "OperationCommandBase.h"

typedef enum {
    CommandTypeEditContact,
    CommandTypeRemoveCalls,
    CommandTypeEditToCall,
    CommandTypeSendSMS,
    CommandTypeShareContact,
    CommandTypeCopyPhoneNumber,
    CommandTypeDeleteContact,
    CommandTypeAlipayTA,
    CommandTypeAddToContact,
    CommandTypeEditGroup,
    CommandTypeMakeCall,
    CommandTypeReportShop,
    CommandTypeMarkNumber,
    CommandTypeMore,
    CommandTypeAddToFavorite,
} CommandType;

@interface OperationCommandCreator : NSObject

+ (OperationCommandBase *)commandForType:(CommandType)commandType withData:(id)data;

@end
