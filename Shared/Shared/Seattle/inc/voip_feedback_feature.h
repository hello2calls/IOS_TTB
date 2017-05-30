/* 
 * voip_feedback_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_VOIPFEEDBACK_FEATURE_H_
#define EXPORT_VOIPFEEDBACK_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class VoipFeedbackRequest : public SecureHttpRequest {
 public:
  VoipFeedbackRequest();
  virtual ~VoipFeedbackRequest();
  VoipFeedbackRequest(const VoipFeedbackRequest& other);
  VoipFeedbackRequest& operator = (const VoipFeedbackRequest& other);
};

class VoipFeedbackResponse : public SecureHttpResponse {
 public:
  VoipFeedbackResponse();
  virtual ~VoipFeedbackResponse();
  VoipFeedbackResponse(const VoipFeedbackResponse& other);
  VoipFeedbackResponse& operator = (const VoipFeedbackResponse& other);
};

class VoipFeedbackFeature : public SecureFeature {
 public:
  VoipFeedbackFeature();
  virtual ~VoipFeedbackFeature();
  
  VoipFeedbackFeature(const VoipFeedbackFeature& other);
  VoipFeedbackFeature& operator = (const VoipFeedbackFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_VOIPFEEDBACK_FEATURE_H_
