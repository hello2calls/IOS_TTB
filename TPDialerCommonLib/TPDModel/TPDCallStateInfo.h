//
//  TPDCallStateInfo.h
//  TouchPalDialer
//
//  Created by weyl on 17/1/22.
//
//

#import <Foundation/Foundation.h>

@interface TPDCallStateInfo : NSObject
@property (nonatomic) NSInteger balance;
@property (nonatomic,strong) NSString* callId;
@property (nonatomic,strong) NSString* callMode;
@property (nonatomic) NSInteger isActive;
@property (nonatomic,strong) NSString* msgType;
@property (nonatomic,strong) NSString* promotion;
@property (nonatomic) NSInteger registered;
@property (nonatomic,strong) NSString* type;
@end
