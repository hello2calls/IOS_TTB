/* 
 * set_profile_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_SETPROFILE_FEATURE_H_
#define EXPORT_SETPROFILE_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class SetProfileRequest : public SecureHttpRequest {
 public:
  SetProfileRequest();
  virtual ~SetProfileRequest();
  SetProfileRequest(const SetProfileRequest& other);
  SetProfileRequest& operator = (const SetProfileRequest& other);
};

class SetProfileResponse : public SecureHttpResponse {
 public:
  SetProfileResponse();
  virtual ~SetProfileResponse();
  SetProfileResponse(const SetProfileResponse& other);
  SetProfileResponse& operator = (const SetProfileResponse& other);
};

class SetProfileFeature : public SecureFeature {
 public:
  SetProfileFeature();
  virtual ~SetProfileFeature();
  
  SetProfileFeature(const SetProfileFeature& other);
  SetProfileFeature& operator = (const SetProfileFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_SETPROFILE_FEATURE_H_
