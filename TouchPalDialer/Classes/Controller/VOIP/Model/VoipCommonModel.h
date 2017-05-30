//
//  VoipCommonModel.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-10-24.
//
//

#import <Foundation/Foundation.h>

@interface FrequentCallModel : NSObject
@property(nonatomic, copy) NSString *number;
@property(nonatomic, assign)long personID;
@property(nonatomic, assign) NSInteger callCount;
@end

