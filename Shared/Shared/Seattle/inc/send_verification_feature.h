/* 
 * send_verification_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_SENDVERIFICATION_FEATURE_H_
#define EXPORT_SENDVERIFICATION_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class SendVerificationRequest : public SecureHttpRequest {
 public:
  SendVerificationRequest();
  virtual ~SendVerificationRequest();
  SendVerificationRequest(const SendVerificationRequest& other);
  SendVerificationRequest& operator = (const SendVerificationRequest& other);
};

class SendVerificationResponse : public SecureHttpResponse {
 public:
  SendVerificationResponse();
  virtual ~SendVerificationResponse();
  SendVerificationResponse(const SendVerificationResponse& other);
  SendVerificationResponse& operator = (const SendVerificationResponse& other);
};

class SendVerificationFeature : public SecureFeature {
 public:
  SendVerificationFeature();
  virtual ~SendVerificationFeature();
  
  SendVerificationFeature(const SendVerificationFeature& other);
  SendVerificationFeature& operator = (const SendVerificationFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_SENDVERIFICATION_FEATURE_H_
