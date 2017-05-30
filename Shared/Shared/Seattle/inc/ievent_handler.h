/*
 * ievent_handler.h
 *
 *  Created on: 2013-1-30
 *      Author: ElfeXu
 */

#ifndef IEVENT_HANDLER_H_
#define IEVENT_HANDLER_H_

#include "define.h"

enum RequiredFeatureType {
  kNeedActivateNewEvent,
  kNeedActivateRenewEvent,
  kNeedRefreshEdenTokenEvent,
  kVoipNeedTokenEvent,
  kVoipNeedPermission,
  kVoipNeedLogoutEventWithActive,
  kVoipNeedLogoutEvent,
  kSignNeedLoginEvent,
  kSignNeedActivateAndLogin,
};

class IEventHandler
{
public:
  IEventHandler() {};
  virtual ~IEventHandler() {};

  // execute the corresponding feature in the same thread, return TRUE if executing success
  virtual TPBOOLEAN execute_feature(RequiredFeatureType feature_type) = 0;
};

#endif /* IEVENT_HANDLER_H_ */
