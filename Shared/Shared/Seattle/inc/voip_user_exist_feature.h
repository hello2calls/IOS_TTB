/* 
 * voip_user_exist_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_VOIPUSEREXIST_FEATURE_H_
#define EXPORT_VOIPUSEREXIST_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class VoipUserExistRequest : public SecureHttpRequest {
 public:
  VoipUserExistRequest();
  virtual ~VoipUserExistRequest();
  VoipUserExistRequest(const VoipUserExistRequest& other);
  VoipUserExistRequest& operator = (const VoipUserExistRequest& other);
};

class VoipUserExistResponse : public SecureHttpResponse {
 public:
  VoipUserExistResponse();
  virtual ~VoipUserExistResponse();
  VoipUserExistResponse(const VoipUserExistResponse& other);
  VoipUserExistResponse& operator = (const VoipUserExistResponse& other);
};

class VoipUserExistFeature : public SecureFeature {
 public:
  VoipUserExistFeature();
  virtual ~VoipUserExistFeature();
  
  VoipUserExistFeature(const VoipUserExistFeature& other);
  VoipUserExistFeature& operator = (const VoipUserExistFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_VOIPUSEREXIST_FEATURE_H_
