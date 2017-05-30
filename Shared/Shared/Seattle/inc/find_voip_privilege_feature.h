/* 
 * find_voip_privilege_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_FINDVOIPPRIVILEGE_FEATURE_H_
#define EXPORT_FINDVOIPPRIVILEGE_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class FindVoipPrivilegeRequest : public SecureHttpRequest {
 public:
  FindVoipPrivilegeRequest();
  virtual ~FindVoipPrivilegeRequest();
  FindVoipPrivilegeRequest(const FindVoipPrivilegeRequest& other);
  FindVoipPrivilegeRequest& operator = (const FindVoipPrivilegeRequest& other);
};

class FindVoipPrivilegeResponse : public SecureHttpResponse {
 public:
  FindVoipPrivilegeResponse();
  virtual ~FindVoipPrivilegeResponse();
  FindVoipPrivilegeResponse(const FindVoipPrivilegeResponse& other);
  FindVoipPrivilegeResponse& operator = (const FindVoipPrivilegeResponse& other);
};

class FindVoipPrivilegeFeature : public SecureFeature {
 public:
  FindVoipPrivilegeFeature();
  virtual ~FindVoipPrivilegeFeature();
  
  FindVoipPrivilegeFeature(const FindVoipPrivilegeFeature& other);
  FindVoipPrivilegeFeature& operator = (const FindVoipPrivilegeFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_FINDVOIPPRIVILEGE_FEATURE_H_
