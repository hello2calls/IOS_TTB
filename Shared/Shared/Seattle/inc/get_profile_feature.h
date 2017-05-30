/* 
 * get_profile_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_GETPROFILE_FEATURE_H_
#define EXPORT_GETPROFILE_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class GetProfileRequest : public SecureHttpRequest {
 public:
  GetProfileRequest();
  virtual ~GetProfileRequest();
  GetProfileRequest(const GetProfileRequest& other);
  GetProfileRequest& operator = (const GetProfileRequest& other);
};

class GetProfileResponse : public SecureHttpResponse {
 public:
  GetProfileResponse();
  virtual ~GetProfileResponse();
  GetProfileResponse(const GetProfileResponse& other);
  GetProfileResponse& operator = (const GetProfileResponse& other);
};

class GetProfileFeature : public SecureFeature {
 public:
  GetProfileFeature();
  virtual ~GetProfileFeature();
  
  GetProfileFeature(const GetProfileFeature& other);
  GetProfileFeature& operator = (const GetProfileFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_GETPROFILE_FEATURE_H_
