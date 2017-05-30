/* 
 * cancel_survey_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_CANCELSURVEY_FEATURE_H_
#define EXPORT_CANCELSURVEY_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class CancelSurveyRequest : public TPHttpRequest {
 public:
  CancelSurveyRequest();
  virtual ~CancelSurveyRequest();
  CancelSurveyRequest(const CancelSurveyRequest& other);
  CancelSurveyRequest& operator = (const CancelSurveyRequest& other);
};

class CancelSurveyResponse : public TPHttpResponse {
 public:
  CancelSurveyResponse();
  virtual ~CancelSurveyResponse();
  CancelSurveyResponse(const CancelSurveyResponse& other);
  CancelSurveyResponse& operator = (const CancelSurveyResponse& other);
};

class CancelSurveyFeature : public TPFeature {
 public:
  CancelSurveyFeature();
  virtual ~CancelSurveyFeature();
  
  CancelSurveyFeature(const CancelSurveyFeature& other);
  CancelSurveyFeature& operator = (const CancelSurveyFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_CANCELSURVEY_FEATURE_H_
