/* 
 * register_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_REGISTER_FEATURE_H_
#define EXPORT_REGISTER_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class RegisterRequest : public SecureHttpRequest {
 public:
  RegisterRequest();
  virtual ~RegisterRequest();
  RegisterRequest(const RegisterRequest& other);
  RegisterRequest& operator = (const RegisterRequest& other);
};

class RegisterResponse : public SecureHttpResponse {
 public:
  RegisterResponse();
  virtual ~RegisterResponse();
  RegisterResponse(const RegisterResponse& other);
  RegisterResponse& operator = (const RegisterResponse& other);
};

class RegisterFeature : public SecureFeature {
 public:
  RegisterFeature();
  virtual ~RegisterFeature();
  virtual TPNUMERIC get_max_retry_time();
  RegisterFeature(const RegisterFeature& other);
  RegisterFeature& operator = (const RegisterFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_REGISTER_FEATURE_H_
