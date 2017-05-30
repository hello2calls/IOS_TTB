/* 
 * voip_deal_strategy_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_VOIPDEALSTRATEGY_FEATURE_H_
#define EXPORT_VOIPDEALSTRATEGY_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class VoipDealStrategyRequest : public SecureHttpRequest {
 public:
  VoipDealStrategyRequest();
  virtual ~VoipDealStrategyRequest();
  VoipDealStrategyRequest(const VoipDealStrategyRequest& other);
  VoipDealStrategyRequest& operator = (const VoipDealStrategyRequest& other);
};

class VoipDealStrategyResponse : public SecureHttpResponse {
 public:
  VoipDealStrategyResponse();
  virtual ~VoipDealStrategyResponse();
  VoipDealStrategyResponse(const VoipDealStrategyResponse& other);
  VoipDealStrategyResponse& operator = (const VoipDealStrategyResponse& other);
};

class VoipDealStrategyFeature : public SecureFeature {
 public:
  VoipDealStrategyFeature();
  virtual ~VoipDealStrategyFeature();
  
  VoipDealStrategyFeature(const VoipDealStrategyFeature& other);
  VoipDealStrategyFeature& operator = (const VoipDealStrategyFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_VOIPDEALSTRATEGY_FEATURE_H_
