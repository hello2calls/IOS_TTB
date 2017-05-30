/* 
 * participate_voip_oversea_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_PARTICIPATEVOIPOVERSEA_FEATURE_H_
#define EXPORT_PARTICIPATEVOIPOVERSEA_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class ParticipateVoipOverseaRequest : public TPHttpRequest {
 public:
  ParticipateVoipOverseaRequest();
  virtual ~ParticipateVoipOverseaRequest();
  ParticipateVoipOverseaRequest(const ParticipateVoipOverseaRequest& other);
  ParticipateVoipOverseaRequest& operator = (const ParticipateVoipOverseaRequest& other);
};

class ParticipateVoipOverseaResponse : public TPHttpResponse {
 public:
  ParticipateVoipOverseaResponse();
  virtual ~ParticipateVoipOverseaResponse();
  ParticipateVoipOverseaResponse(const ParticipateVoipOverseaResponse& other);
  ParticipateVoipOverseaResponse& operator = (const ParticipateVoipOverseaResponse& other);
};

class ParticipateVoipOverseaFeature : public TPFeature {
 public:
  ParticipateVoipOverseaFeature();
  virtual ~ParticipateVoipOverseaFeature();
  
  ParticipateVoipOverseaFeature(const ParticipateVoipOverseaFeature& other);
  ParticipateVoipOverseaFeature& operator = (const ParticipateVoipOverseaFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_PARTICIPATEVOIPOVERSEA_FEATURE_H_
