/* 
 * voip_c2c_history_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_C2CHISTORY_FEATURE_H_
#define EXPORT_C2CHISTORY_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class C2CHistoryRequest : public SecureHttpRequest {
 public:
  C2CHistoryRequest();
  virtual ~C2CHistoryRequest();
  C2CHistoryRequest(const C2CHistoryRequest& other);
  C2CHistoryRequest& operator = (const C2CHistoryRequest& other);
};

class C2CHistoryResponse : public SecureHttpResponse {
 public:
  C2CHistoryResponse();
  virtual ~C2CHistoryResponse();
  C2CHistoryResponse(const C2CHistoryResponse& other);
  C2CHistoryResponse& operator = (const C2CHistoryResponse& other);
};

class C2CHistoryFeature : public SecureFeature {
 public:
  C2CHistoryFeature();
  virtual ~C2CHistoryFeature();
  
  C2CHistoryFeature(const C2CHistoryFeature& other);
  C2CHistoryFeature& operator = (const C2CHistoryFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_C2CHISTORY_FEATURE_H_
