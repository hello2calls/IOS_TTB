/* 
 * commercial_ad_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_COMMERCIALAD_FEATURE_H_
#define EXPORT_COMMERCIALAD_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class CommercialAdRequest : public TPHttpRequest {
 public:
  CommercialAdRequest();
  virtual ~CommercialAdRequest();
  CommercialAdRequest(const CommercialAdRequest& other);
  CommercialAdRequest& operator = (const CommercialAdRequest& other);
};

class CommercialAdResponse : public TPHttpResponse {
 public:
  CommercialAdResponse();
  virtual ~CommercialAdResponse();
  CommercialAdResponse(const CommercialAdResponse& other);
  CommercialAdResponse& operator = (const CommercialAdResponse& other);
};

class CommercialAdFeature : public TPFeature {
 public:
  CommercialAdFeature();
  virtual ~CommercialAdFeature();
  
  CommercialAdFeature(const CommercialAdFeature& other);
  CommercialAdFeature& operator = (const CommercialAdFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_COMMERCIALAD_FEATURE_H_
