/* 
 * if_participate_voip_oversea_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_IFPARTICIPATEVOIPOVERSEA_FEATURE_H_
#define EXPORT_IFPARTICIPATEVOIPOVERSEA_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class IfParticipateVoipOverseaRequest : public TPHttpRequest {
 public:
  IfParticipateVoipOverseaRequest();
  virtual ~IfParticipateVoipOverseaRequest();
  IfParticipateVoipOverseaRequest(const IfParticipateVoipOverseaRequest& other);
  IfParticipateVoipOverseaRequest& operator = (const IfParticipateVoipOverseaRequest& other);
};

class IfParticipateVoipOverseaResponse : public TPHttpResponse {
 public:
  IfParticipateVoipOverseaResponse();
  virtual ~IfParticipateVoipOverseaResponse();
  IfParticipateVoipOverseaResponse(const IfParticipateVoipOverseaResponse& other);
  IfParticipateVoipOverseaResponse& operator = (const IfParticipateVoipOverseaResponse& other);
};

class IfParticipateVoipOverseaFeature : public TPFeature {
 public:
  IfParticipateVoipOverseaFeature();
  virtual ~IfParticipateVoipOverseaFeature();
  
  IfParticipateVoipOverseaFeature(const IfParticipateVoipOverseaFeature& other);
  IfParticipateVoipOverseaFeature& operator = (const IfParticipateVoipOverseaFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_IFPARTICIPATEVOIPOVERSEA_FEATURE_H_
