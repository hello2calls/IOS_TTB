/* 
 * voip_callstat_upload_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_VOIPCALLSTATUPLOAD_FEATURE_H_
#define EXPORT_VOIPCALLSTATUPLOAD_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class VoipCallStatUploadRequest : public SecureHttpRequest {
 public:
  VoipCallStatUploadRequest();
  virtual ~VoipCallStatUploadRequest();
  VoipCallStatUploadRequest(const VoipCallStatUploadRequest& other);
  VoipCallStatUploadRequest& operator = (const VoipCallStatUploadRequest& other);
};

class VoipCallStatUploadResponse : public SecureHttpResponse {
 public:
  VoipCallStatUploadResponse();
  virtual ~VoipCallStatUploadResponse();
  VoipCallStatUploadResponse(const VoipCallStatUploadResponse& other);
  VoipCallStatUploadResponse& operator = (const VoipCallStatUploadResponse& other);
};

class VoipCallStatUploadFeature : public SecureFeature {
 public:
  VoipCallStatUploadFeature();
  virtual ~VoipCallStatUploadFeature();
  
  VoipCallStatUploadFeature(const VoipCallStatUploadFeature& other);
  VoipCallStatUploadFeature& operator = (const VoipCallStatUploadFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_VOIPCALLSTATUPLOAD_FEATURE_H_
