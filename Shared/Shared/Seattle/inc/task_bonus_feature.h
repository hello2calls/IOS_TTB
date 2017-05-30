/* 
 * task_bonus_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_TASKBONUS_FEATURE_H_
#define EXPORT_TASKBONUS_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class TaskBonusRequest : public SecureHttpRequest {
 public:
  TaskBonusRequest();
  virtual ~TaskBonusRequest();
  TaskBonusRequest(const TaskBonusRequest& other);
  TaskBonusRequest& operator = (const TaskBonusRequest& other);
};

class TaskBonusResponse : public SecureHttpResponse {
 public:
  TaskBonusResponse();
  virtual ~TaskBonusResponse();
  TaskBonusResponse(const TaskBonusResponse& other);
  TaskBonusResponse& operator = (const TaskBonusResponse& other);
};

class TaskBonusFeature : public SecureFeature {
 public:
  TaskBonusFeature();
  virtual ~TaskBonusFeature();
  
  TaskBonusFeature(const TaskBonusFeature& other);
  TaskBonusFeature& operator = (const TaskBonusFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_TASKBONUS_FEATURE_H_
