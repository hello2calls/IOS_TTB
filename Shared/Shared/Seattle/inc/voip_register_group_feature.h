/* 
 * voip_register_group_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_REGISTERGROUP_FEATURE_H_
#define EXPORT_REGISTERGROUP_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class RegisterGroupRequest : public SecureHttpRequest {
 public:
  RegisterGroupRequest();
  virtual ~RegisterGroupRequest();
  RegisterGroupRequest(const RegisterGroupRequest& other);
  RegisterGroupRequest& operator = (const RegisterGroupRequest& other);
};

class RegisterGroupResponse : public SecureHttpResponse {
 public:
  RegisterGroupResponse();
  virtual ~RegisterGroupResponse();
  RegisterGroupResponse(const RegisterGroupResponse& other);
  RegisterGroupResponse& operator = (const RegisterGroupResponse& other);
};

class RegisterGroupFeature : public SecureFeature {
 public:
  RegisterGroupFeature();
  virtual ~RegisterGroupFeature();
  
  RegisterGroupFeature(const RegisterGroupFeature& other);
  RegisterGroupFeature& operator = (const RegisterGroupFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_REGISTERGROUP_FEATURE_H_
