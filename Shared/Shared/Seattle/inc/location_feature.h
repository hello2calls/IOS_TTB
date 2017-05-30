/* 
 * location_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_LOCATION_FEATURE_H_
#define EXPORT_LOCATION_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class LocationRequest : public TPHttpRequest {
 public:
  LocationRequest();
  virtual ~LocationRequest();
  LocationRequest(const LocationRequest& other);
  LocationRequest& operator = (const LocationRequest& other);
};

class LocationResponse : public TPHttpResponse {
 public:
  LocationResponse();
  virtual ~LocationResponse();
  LocationResponse(const LocationResponse& other);
  LocationResponse& operator = (const LocationResponse& other);
};

class LocationFeature : public TPFeature {
 public:
  LocationFeature();
  virtual ~LocationFeature();
  
  LocationFeature(const LocationFeature& other);
  LocationFeature& operator = (const LocationFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_LOCATION_FEATURE_H_
