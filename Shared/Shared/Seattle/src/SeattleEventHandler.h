//
//  SeattleEventHandler.h
//  CallerInfoShow
//
//  Created by Elfe Xu on 13-1-30.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//


#include "ievent_handler.h"
#include "SeattleFeatureExecutor.h"
#import "VOIPCall.h"
#import "TouchPalDialerAppDelegate.h"
#import "EditVoipViewController.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"

class SeattleEventHandler : public IEventHandler {
    virtual TPBOOLEAN execute_feature(RequiredFeatureType feature_type) {
        cootek_log(@"handle error requried feature type = %d", feature_type );
        
        switch (feature_type) {
            case kNeedActivateNewEvent:
                return [SeattleFeatureExecutor activateWithType:ActivateTypeNew];
            case kNeedActivateRenewEvent:
                return [SeattleFeatureExecutor activateWithType:ActivateTypeRenew];
            case kSignNeedActivateAndLogin:
                [SeattleFeatureExecutor reLogin];
                return [SeattleFeatureExecutor activateWithType:ActivateTypeRenew];
            case kSignNeedLoginEvent:{
                [SeattleFeatureExecutor reLogin];
                return TRUE;
            }
            default:
                return FALSE;
        }
        return FALSE;
    }
};