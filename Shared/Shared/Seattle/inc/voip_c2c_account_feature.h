/* 
 * voip_c2c_account_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_VOIPC2CACCOUNT_FEATURE_H_
#define EXPORT_VOIPC2CACCOUNT_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class VoipC2CAccountRequest : public SecureHttpRequest {
 public:
  VoipC2CAccountRequest();
  virtual ~VoipC2CAccountRequest();
  VoipC2CAccountRequest(const VoipC2CAccountRequest& other);
  VoipC2CAccountRequest& operator = (const VoipC2CAccountRequest& other);
};

class VoipC2CAccountResponse : public SecureHttpResponse {
 public:
  VoipC2CAccountResponse();
  virtual ~VoipC2CAccountResponse();
  VoipC2CAccountResponse(const VoipC2CAccountResponse& other);
  VoipC2CAccountResponse& operator = (const VoipC2CAccountResponse& other);
};

class VoipC2CAccountFeature : public SecureFeature {
 public:
  VoipC2CAccountFeature();
  virtual ~VoipC2CAccountFeature();
  
  VoipC2CAccountFeature(const VoipC2CAccountFeature& other);
  VoipC2CAccountFeature& operator = (const VoipC2CAccountFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_VOIPC2CACCOUNT_FEATURE_H_
