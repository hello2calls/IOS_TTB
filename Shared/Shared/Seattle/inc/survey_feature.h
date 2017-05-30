/* 
 * survey_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_SURVEY_FEATURE_H_
#define EXPORT_SURVEY_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class SurveyRequest : public TPHttpRequest {
 public:
  SurveyRequest();
  virtual ~SurveyRequest();
  SurveyRequest(const SurveyRequest& other);
  SurveyRequest& operator = (const SurveyRequest& other);
};

class SurveyResponse : public TPHttpResponse {
 public:
  SurveyResponse();
  virtual ~SurveyResponse();
  SurveyResponse(const SurveyResponse& other);
  SurveyResponse& operator = (const SurveyResponse& other);
};

class SurveyFeature : public TPFeature {
 public:
  SurveyFeature();
  virtual ~SurveyFeature();
  
  SurveyFeature(const SurveyFeature& other);
  SurveyFeature& operator = (const SurveyFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_SURVEY_FEATURE_H_
