/* 
 * yellowpage_info_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_YELLOWPAGEINFO_FEATURE_H_
#define EXPORT_YELLOWPAGEINFO_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class YellowpageInfoRequest : public TPHttpRequest {
 public:
  YellowpageInfoRequest();
  virtual ~YellowpageInfoRequest();
  YellowpageInfoRequest(const YellowpageInfoRequest& other);
  YellowpageInfoRequest& operator = (const YellowpageInfoRequest& other);
  virtual const HttpMethod get_method();
};

class YellowpageInfoResponse : public TPHttpResponse {
 public:
  YellowpageInfoResponse();
  virtual ~YellowpageInfoResponse();
  YellowpageInfoResponse(const YellowpageInfoResponse& other);
  YellowpageInfoResponse& operator = (const YellowpageInfoResponse& other);
};

class YellowpageInfoFeature : public TPFeature {
 public:
  YellowpageInfoFeature();
  virtual ~YellowpageInfoFeature();
  YellowpageInfoFeature(const YellowpageInfoFeature& other);
  YellowpageInfoFeature& operator = (const YellowpageInfoFeature& other);
};

#endif // EXPORT_YELLOWPAGEINFO_FEATURE_H_
