/* 
 * exchange_traffic_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_EXCHANGETRAFFIC_FEATURE_H_
#define EXPORT_EXCHANGETRAFFIC_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class ExchangeTrafficRequest : public SecureHttpRequest {
 public:
  ExchangeTrafficRequest();
  virtual ~ExchangeTrafficRequest();
  ExchangeTrafficRequest(const ExchangeTrafficRequest& other);
  ExchangeTrafficRequest& operator = (const ExchangeTrafficRequest& other);
};

class ExchangeTrafficResponse : public SecureHttpResponse {
 public:
  ExchangeTrafficResponse();
  virtual ~ExchangeTrafficResponse();
  ExchangeTrafficResponse(const ExchangeTrafficResponse& other);
  ExchangeTrafficResponse& operator = (const ExchangeTrafficResponse& other);
};

class ExchangeTrafficFeature : public SecureFeature {
 public:
  ExchangeTrafficFeature();
  virtual ~ExchangeTrafficFeature();
  
  ExchangeTrafficFeature(const ExchangeTrafficFeature& other);
  ExchangeTrafficFeature& operator = (const ExchangeTrafficFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_EXCHANGETRAFFIC_FEATURE_H_
