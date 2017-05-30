//
//  TPQuertyCallog.h
//  TouchPalDialer
//
//  Created by lingmei xie on 12-12-4.
//
//

#import <Foundation/Foundation.h>
#import "SearchResultModel.h"

@protocol TPQuertyCallogDelegate

-(NSArray *)queryCallog;

@end

@interface TPQueryCallogDefault : NSObject<TPQuertyCallogDelegate>

+(TPQueryCallogDefault *)createQueryCalllogObject:(CalllogFilterType)type;

@end

@interface TPQueyCallLogAll : TPQueryCallogDefault

@end

@interface TPQueryCallLogUnknown : TPQueryCallogDefault

@end

@interface TPQueryCallLogIncoming : TPQueryCallogDefault

@end

@interface TPQueryCallLogOutgoing : TPQueryCallogDefault

@end

@interface TPQueryCallLogMissed : TPQueryCallogDefault

@end
