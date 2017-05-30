/* 
 * voip_call_reward_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_VOIPCALLREWARD_FEATURE_H_
#define EXPORT_VOIPCALLREWARD_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class VoipCallRewardRequest : public SecureHttpRequest {
 public:
  VoipCallRewardRequest();
  virtual ~VoipCallRewardRequest();
  VoipCallRewardRequest(const VoipCallRewardRequest& other);
  VoipCallRewardRequest& operator = (const VoipCallRewardRequest& other);
};

class VoipCallRewardResponse : public SecureHttpResponse {
 public:
  VoipCallRewardResponse();
  virtual ~VoipCallRewardResponse();
  VoipCallRewardResponse(const VoipCallRewardResponse& other);
  VoipCallRewardResponse& operator = (const VoipCallRewardResponse& other);
};

class VoipCallRewardFeature : public SecureFeature {
 public:
  VoipCallRewardFeature();
  virtual ~VoipCallRewardFeature();
  
  VoipCallRewardFeature(const VoipCallRewardFeature& other);
  VoipCallRewardFeature& operator = (const VoipCallRewardFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_VOIPCALLREWARD_FEATURE_H_
