/* 
 * commercial_web_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_COMMERCIALWEB_FEATURE_H_
#define EXPORT_COMMERCIALWEB_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class CommercialWebRequest : public TPHttpRequest {
 public:
  CommercialWebRequest();
  virtual ~CommercialWebRequest();
  CommercialWebRequest(const CommercialWebRequest& other);
  CommercialWebRequest& operator = (const CommercialWebRequest& other);
};

class CommercialWebResponse : public TPHttpResponse {
 public:
  CommercialWebResponse();
  virtual ~CommercialWebResponse();
  CommercialWebResponse(const CommercialWebResponse& other);
  CommercialWebResponse& operator = (const CommercialWebResponse& other);
};

class CommercialWebFeature : public TPFeature {
 public:
  CommercialWebFeature();
  virtual ~CommercialWebFeature();
  
  CommercialWebFeature(const CommercialWebFeature& other);
  CommercialWebFeature& operator = (const CommercialWebFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_COMMERCIALWEB_FEATURE_H_
