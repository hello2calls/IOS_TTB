/* 
 * package_info_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_PACKAGEINFO_FEATURE_H_
#define EXPORT_PACKAGEINFO_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class PackageInfoRequest : public TPHttpRequest {
 public:
  PackageInfoRequest();
  virtual ~PackageInfoRequest();
  PackageInfoRequest(const PackageInfoRequest& other);
  PackageInfoRequest& operator = (const PackageInfoRequest& other);
  virtual void marshal_by();
};

class PackageInfoResponse : public TPHttpResponse {
 public:
  PackageInfoResponse();
  virtual ~PackageInfoResponse();
  PackageInfoResponse(const PackageInfoResponse& other);
  PackageInfoResponse& operator = (const PackageInfoResponse& other);
};

class PackageInfoFeature : public TPFeature {
 public:
  PackageInfoFeature();
  virtual ~PackageInfoFeature();
  PackageInfoFeature(const PackageInfoFeature& other);
  PackageInfoFeature& operator = (const PackageInfoFeature& other);
  virtual bool require_token();
};

#endif // EXPORT_PACKAGEINFO_FEATURE_H_
