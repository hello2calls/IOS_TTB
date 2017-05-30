/* 
 * voip_reward_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_VOIPREWARD_FEATURE_H_
#define EXPORT_VOIPREWARD_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class VoipRewardRequest : public SecureHttpRequest {
 public:
  VoipRewardRequest();
  virtual ~VoipRewardRequest();
  VoipRewardRequest(const VoipRewardRequest& other);
  VoipRewardRequest& operator = (const VoipRewardRequest& other);
};

class VoipRewardResponse : public SecureHttpResponse {
 public:
  VoipRewardResponse();
  virtual ~VoipRewardResponse();
  VoipRewardResponse(const VoipRewardResponse& other);
  VoipRewardResponse& operator = (const VoipRewardResponse& other);
};

class VoipRewardFeature : public SecureFeature {
 public:
  VoipRewardFeature();
  virtual ~VoipRewardFeature();
  
  VoipRewardFeature(const VoipRewardFeature& other);
  VoipRewardFeature& operator = (const VoipRewardFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_VOIPREWARD_FEATURE_H_
