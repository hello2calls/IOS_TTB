//
//  TouchpalHistoryManager.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/26.
//
//

#import "TouchpalHistoryManager.h"
#import "TouchpalHistoryDBA.h"

@implementation TouchpalHistoryManager

-(id)init
{
    self = [super init];
    if ( self != nil ){
        self.touchpalHistoryCacheArray = [[NSMutableArray array] init];
    }
    return self;
    
}

- (void) loadArrayWithBonusType:(NSInteger)bonusType
{
    self.touchpalHistoryCacheArray = [TouchpalHistoryDBA getAllTouchpalHistory:bonusType];
}


+ (BOOL) insertHistory:(C2CHistoryInfo *)info{
    BOOL ifInsertSuccess = NO;
    BOOL result = [TouchpalHistoryDBA insertHistory:info];
    if ( result ){
        ifInsertSuccess = YES;
    }else{
        cootek_log(@"error insert history info");
    }
    return ifInsertSuccess;
    
}

+ (NSInteger) getLatestDatetime:(NSInteger)bonusType{
    return [TouchpalHistoryDBA getLatestDatetime:bonusType];
}

+ (void)deleteAllData{
    [TouchpalHistoryDBA deleteAllData];
}



@end
