/* 
 * smssync_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_SMSSYNC_FEATURE_H_
#define EXPORT_SMSSYNC_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class SmsSyncRequest : public TPHttpRequest {
 public:
  SmsSyncRequest();
  virtual ~SmsSyncRequest();
  SmsSyncRequest(const SmsSyncRequest& other);
  SmsSyncRequest& operator = (const SmsSyncRequest& other);
};

class SmsSyncResponse : public TPHttpResponse {
 public:
  SmsSyncResponse();
  virtual ~SmsSyncResponse();
  SmsSyncResponse(const SmsSyncResponse& other);
  SmsSyncResponse& operator = (const SmsSyncResponse& other);
};

class SmsSyncFeature : public TPFeature {
 public:
  SmsSyncFeature();
  virtual ~SmsSyncFeature();
  virtual TPNUMERIC get_max_retry_time();
  SmsSyncFeature(const SmsSyncFeature& other);
  SmsSyncFeature& operator = (const SmsSyncFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_SMSSYNC_FEATURE_H_
