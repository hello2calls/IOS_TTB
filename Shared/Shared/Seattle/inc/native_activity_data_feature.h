/* 
 * native_activity_data_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_NATIVEACTIVITY_FEATURE_H_
#define EXPORT_NATIVEACTIVITY_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class NativeActivityRequest : public SecureHttpRequest {
 public:
  NativeActivityRequest();
  virtual ~NativeActivityRequest();
  NativeActivityRequest(const NativeActivityRequest& other);
  NativeActivityRequest& operator = (const NativeActivityRequest& other);
};

class NativeActivityResponse : public SecureHttpResponse {
 public:
  NativeActivityResponse();
  virtual ~NativeActivityResponse();
  NativeActivityResponse(const NativeActivityResponse& other);
  NativeActivityResponse& operator = (const NativeActivityResponse& other);
};

class NativeActivityFeature : public SecureFeature {
 public:
  NativeActivityFeature();
  virtual ~NativeActivityFeature();
  
  NativeActivityFeature(const NativeActivityFeature& other);
  NativeActivityFeature& operator = (const NativeActivityFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_NATIVEACTIVITY_FEATURE_H_
