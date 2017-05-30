//
//  VoipBackCall.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/2/3.
//
//

#import <Foundation/Foundation.h>
#import "ICallState.h"


@interface VoipBackCall : NSObject

@property (nonatomic, retain)NSString *callId;

- (id)initWithNumber:(NSString *)number
                edge:(NSString *)edge
            location:(NSString *)location
         andDelegate:(id<CallStateChangeDelegate>)delegate;

- (void)sendInviteMsg;

@end
