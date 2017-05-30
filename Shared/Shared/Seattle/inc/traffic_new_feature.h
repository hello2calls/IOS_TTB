/* 
 * traffic_new_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_TRAFFICNEW_FEATURE_H_
#define EXPORT_TRAFFICNEW_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class TrafficNewRequest : public SecureHttpRequest {
 public:
  TrafficNewRequest();
  virtual ~TrafficNewRequest();
  TrafficNewRequest(const TrafficNewRequest& other);
  TrafficNewRequest& operator = (const TrafficNewRequest& other);
};

class TrafficNewResponse : public SecureHttpResponse {
 public:
  TrafficNewResponse();
  virtual ~TrafficNewResponse();
  TrafficNewResponse(const TrafficNewResponse& other);
  TrafficNewResponse& operator = (const TrafficNewResponse& other);
};

class TrafficNewFeature : public SecureFeature {
 public:
  TrafficNewFeature();
  virtual ~TrafficNewFeature();
  
  TrafficNewFeature(const TrafficNewFeature& other);
  TrafficNewFeature& operator = (const TrafficNewFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_TRAFFICNEW_FEATURE_H_
