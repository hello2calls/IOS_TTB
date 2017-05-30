/* 
 * sms_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_SMS_FEATURE_H_
#define EXPORT_SMS_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class SmsRequest : public TPHttpRequest {
 public:
  SmsRequest();
  virtual ~SmsRequest();
  SmsRequest(const SmsRequest& other);
  SmsRequest& operator = (const SmsRequest& other);
};

class SmsResponse : public TPHttpResponse {
 public:
  SmsResponse();
  virtual ~SmsResponse();
  SmsResponse(const SmsResponse& other);
  SmsResponse& operator = (const SmsResponse& other);
};

class SmsFeature : public TPFeature {
 public:
  SmsFeature();
  virtual ~SmsFeature();
  
  SmsFeature(const SmsFeature& other);
  SmsFeature& operator = (const SmsFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_SMS_FEATURE_H_
