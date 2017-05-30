/* 
 * get_control_server_data_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_GETCONTROLSERVERDATA_FEATURE_H_
#define EXPORT_GETCONTROLSERVERDATA_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class GetControlServerDataRequest : public TPHttpRequest {
 public:
  GetControlServerDataRequest();
  virtual ~GetControlServerDataRequest();
  GetControlServerDataRequest(const GetControlServerDataRequest& other);
  GetControlServerDataRequest& operator = (const GetControlServerDataRequest& other);
};

class GetControlServerDataResponse : public TPHttpResponse {
 public:
  GetControlServerDataResponse();
  virtual ~GetControlServerDataResponse();
  GetControlServerDataResponse(const GetControlServerDataResponse& other);
  GetControlServerDataResponse& operator = (const GetControlServerDataResponse& other);
};

class GetControlServerDataFeature : public TPFeature {
 public:
  GetControlServerDataFeature();
  virtual ~GetControlServerDataFeature();
  
  GetControlServerDataFeature(const GetControlServerDataFeature& other);
  GetControlServerDataFeature& operator = (const GetControlServerDataFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_GETCONTROLSERVERDATA_FEATURE_H_
