/* 
 * yellowpage_info2_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_YELLOWPAGEINFO2_FEATURE_H_
#define EXPORT_YELLOWPAGEINFO2_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class YellowpageInfo2Request : public TPHttpRequest {
 public:
  YellowpageInfo2Request();
  virtual ~YellowpageInfo2Request();
  YellowpageInfo2Request(const YellowpageInfo2Request& other);
  YellowpageInfo2Request& operator = (const YellowpageInfo2Request& other);
};

class YellowpageInfo2Response : public TPHttpResponse {
 public:
  YellowpageInfo2Response();
  virtual ~YellowpageInfo2Response();
  YellowpageInfo2Response(const YellowpageInfo2Response& other);
  YellowpageInfo2Response& operator = (const YellowpageInfo2Response& other);
};

class YellowpageInfo2Feature : public TPFeature {
 public:
  YellowpageInfo2Feature();
  virtual ~YellowpageInfo2Feature();
  
  YellowpageInfo2Feature(const YellowpageInfo2Feature& other);
  YellowpageInfo2Feature& operator = (const YellowpageInfo2Feature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_YELLOWPAGEINFO2_FEATURE_H_
