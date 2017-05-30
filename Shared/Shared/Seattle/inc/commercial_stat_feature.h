/* 
 * commercial_stat_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_COMMERCIALSTAT_FEATURE_H_
#define EXPORT_COMMERCIALSTAT_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class CommercialStatRequest : public TPHttpRequest {
 public:
  CommercialStatRequest();
  virtual ~CommercialStatRequest();
  CommercialStatRequest(const CommercialStatRequest& other);
  CommercialStatRequest& operator = (const CommercialStatRequest& other);
};

class CommercialStatResponse : public TPHttpResponse {
 public:
  CommercialStatResponse();
  virtual ~CommercialStatResponse();
  CommercialStatResponse(const CommercialStatResponse& other);
  CommercialStatResponse& operator = (const CommercialStatResponse& other);
};

class CommercialStatFeature : public TPFeature {
 public:
  CommercialStatFeature();
  virtual ~CommercialStatFeature();
  
  CommercialStatFeature(const CommercialStatFeature& other);
  CommercialStatFeature& operator = (const CommercialStatFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_COMMERCIALSTAT_FEATURE_H_
