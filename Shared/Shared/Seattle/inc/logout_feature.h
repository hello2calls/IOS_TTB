/* 
 * logout_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_LOGOUT_FEATURE_H_
#define EXPORT_LOGOUT_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class LogoutRequest : public SecureHttpRequest {
 public:
  LogoutRequest();
  virtual ~LogoutRequest();
  LogoutRequest(const LogoutRequest& other);
  LogoutRequest& operator = (const LogoutRequest& other);
};

class LogoutResponse : public SecureHttpResponse {
 public:
  LogoutResponse();
  virtual ~LogoutResponse();
  LogoutResponse(const LogoutResponse& other);
  LogoutResponse& operator = (const LogoutResponse& other);
};

class LogoutFeature : public SecureFeature {
 public:
  LogoutFeature();
  virtual ~LogoutFeature();
  
  LogoutFeature(const LogoutFeature& other);
  LogoutFeature& operator = (const LogoutFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_LOGOUT_FEATURE_H_
