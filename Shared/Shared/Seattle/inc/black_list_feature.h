/* 
 * black_list_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_BLACKLIST_FEATURE_H_
#define EXPORT_BLACKLIST_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class BlackListRequest : public TPHttpRequest {
 public:
  BlackListRequest();
  virtual ~BlackListRequest();
  BlackListRequest(const BlackListRequest& other);
  BlackListRequest& operator = (const BlackListRequest& other);
};

class BlackListResponse : public TPHttpResponse {
 public:
  BlackListResponse();
  virtual ~BlackListResponse();
  BlackListResponse(const BlackListResponse& other);
  BlackListResponse& operator = (const BlackListResponse& other);
};

class BlackListFeature : public TPFeature {
 public:
  BlackListFeature();
  virtual ~BlackListFeature();
  
  BlackListFeature(const BlackListFeature& other);
  BlackListFeature& operator = (const BlackListFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_BLACKLIST_FEATURE_H_
