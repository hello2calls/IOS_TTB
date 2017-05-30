//
//  VoipCommercialModel.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/7/29.
//
//

#import <Foundation/Foundation.h>
#import "AdMessageModel.h"

@interface HangupCommercialModel : AdMessageModel

@property (atomic, strong)UIImage *materialPic;
@property (nonatomic) NSString *localMaterial;
@end
