//
//  SeattleEventHandler.h
//  CallerInfoShow
//
//  Created by Elfe Xu on 13-1-30.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//


#include "ievent_handler.h"
#import "SeattleEngine.h"

class SeattleEventHandler : public IEventHandler {
    virtual TPBOOLEAN execute_feature(RequiredFeatureType feature_type) {
        cootek_log(@"handle error requried feature type = %d", feature_type );
        
        switch (feature_type) {
            case kNeedActivateNewEvent:
                return [SeattleEngine activateWithType:ActivateTypeNew];
            case kNeedActivateRenewEvent:
                return [SeattleEngine activateWithType:ActivateTypeRenew];
            case kNeedCallHistoryEvent:
                return [SeattleEngine uploadCallHistory];
            case kNeedChinaTelecomEvent:
                //[SeattleFeatureExecutor asyncChinaTelecomContribute];
                return TRUE;
            default:
                return FALSE;
        }
        
        return FALSE;
    }
};