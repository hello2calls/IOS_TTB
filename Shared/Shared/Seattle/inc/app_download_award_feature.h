/* 
 * app_download_award_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_APPDOWNLOADAWARD_FEATURE_H_
#define EXPORT_APPDOWNLOADAWARD_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class AppDownloadAwardRequest : public SecureHttpRequest {
 public:
  AppDownloadAwardRequest();
  virtual ~AppDownloadAwardRequest();
  AppDownloadAwardRequest(const AppDownloadAwardRequest& other);
  AppDownloadAwardRequest& operator = (const AppDownloadAwardRequest& other);
};

class AppDownloadAwardResponse : public SecureHttpResponse {
 public:
  AppDownloadAwardResponse();
  virtual ~AppDownloadAwardResponse();
  AppDownloadAwardResponse(const AppDownloadAwardResponse& other);
  AppDownloadAwardResponse& operator = (const AppDownloadAwardResponse& other);
};

class AppDownloadAwardFeature : public SecureFeature {
 public:
  AppDownloadAwardFeature();
  virtual ~AppDownloadAwardFeature();
  
  AppDownloadAwardFeature(const AppDownloadAwardFeature& other);
  AppDownloadAwardFeature& operator = (const AppDownloadAwardFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_APPDOWNLOADAWARD_FEATURE_H_
