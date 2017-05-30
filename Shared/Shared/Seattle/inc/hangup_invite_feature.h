/* 
 * hangup_invite_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_HANGUPINVITE_FEATURE_H_
#define EXPORT_HANGUPINVITE_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class HangupInviteRequest : public SecureHttpRequest {
 public:
  HangupInviteRequest();
  virtual ~HangupInviteRequest();
  HangupInviteRequest(const HangupInviteRequest& other);
  HangupInviteRequest& operator = (const HangupInviteRequest& other);
};

class HangupInviteResponse : public SecureHttpResponse {
 public:
  HangupInviteResponse();
  virtual ~HangupInviteResponse();
  HangupInviteResponse(const HangupInviteResponse& other);
  HangupInviteResponse& operator = (const HangupInviteResponse& other);
};

class HangupInviteFeature : public SecureFeature {
 public:
  HangupInviteFeature();
  virtual ~HangupInviteFeature();
  
  HangupInviteFeature(const HangupInviteFeature& other);
  HangupInviteFeature& operator = (const HangupInviteFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_HANGUPINVITE_FEATURE_H_
