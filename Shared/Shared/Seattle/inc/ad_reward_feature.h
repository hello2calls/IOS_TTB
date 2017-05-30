/* 
 * ad_reward_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_ADREWARD_FEATURE_H_
#define EXPORT_ADREWARD_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class ADRewardRequest : public SecureHttpRequest {
 public:
  ADRewardRequest();
  virtual ~ADRewardRequest();
  ADRewardRequest(const ADRewardRequest& other);
  ADRewardRequest& operator = (const ADRewardRequest& other);
};

class ADRewardResponse : public SecureHttpResponse {
 public:
  ADRewardResponse();
  virtual ~ADRewardResponse();
  ADRewardResponse(const ADRewardResponse& other);
  ADRewardResponse& operator = (const ADRewardResponse& other);
};

class ADRewardFeature : public SecureFeature {
 public:
  ADRewardFeature();
  virtual ~ADRewardFeature();
  
  ADRewardFeature(const ADRewardFeature& other);
  ADRewardFeature& operator = (const ADRewardFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_ADREWARD_FEATURE_H_
