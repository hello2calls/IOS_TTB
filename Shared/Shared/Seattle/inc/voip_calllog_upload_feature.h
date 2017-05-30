/* 
 * voip_calllog_upload_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_VOIPCALLLOGUPLOAD_FEATURE_H_
#define EXPORT_VOIPCALLLOGUPLOAD_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class VoipCalllogUploadRequest : public SecureHttpRequest {
 public:
  VoipCalllogUploadRequest();
  virtual ~VoipCalllogUploadRequest();
  VoipCalllogUploadRequest(const VoipCalllogUploadRequest& other);
  VoipCalllogUploadRequest& operator = (const VoipCalllogUploadRequest& other);
};

class VoipCalllogUploadResponse : public SecureHttpResponse {
 public:
  VoipCalllogUploadResponse();
  virtual ~VoipCalllogUploadResponse();
  VoipCalllogUploadResponse(const VoipCalllogUploadResponse& other);
  VoipCalllogUploadResponse& operator = (const VoipCalllogUploadResponse& other);
};

class VoipCalllogUploadFeature : public SecureFeature {
 public:
  VoipCalllogUploadFeature();
  virtual ~VoipCalllogUploadFeature();
  
  VoipCalllogUploadFeature(const VoipCalllogUploadFeature& other);
  VoipCalllogUploadFeature& operator = (const VoipCalllogUploadFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_VOIPCALLLOGUPLOAD_FEATURE_H_
