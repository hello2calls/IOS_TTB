#ifndef EXPORT_PACKAGEINFO_FEATURE_H_
#define EXPORT_PACKAGEINFO_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class CallerIdPkgInfoRequest : public TPHttpRequest {
 public:
	CallerIdPkgInfoRequest();
  virtual ~CallerIdPkgInfoRequest();
  CallerIdPkgInfoRequest(const CallerIdPkgInfoRequest& other);
  CallerIdPkgInfoRequest& operator = (const CallerIdPkgInfoRequest& other);
  virtual void marshal_by();
};

class CallerIdPkgInfoResponse : public TPHttpResponse {
 public:
	CallerIdPkgInfoResponse();
  virtual ~CallerIdPkgInfoResponse();
  CallerIdPkgInfoResponse(const CallerIdPkgInfoResponse& other);
  CallerIdPkgInfoResponse& operator = (const CallerIdPkgInfoResponse& other);
};

class CallerIdPkgInfoFeature : public TPFeature {
 public:
	CallerIdPkgInfoFeature();
  virtual ~CallerIdPkgInfoFeature();
  CallerIdPkgInfoFeature(const CallerIdPkgInfoFeature& other);
  CallerIdPkgInfoFeature& operator = (const CallerIdPkgInfoFeature& other);
  virtual bool require_token();
};

#endif // EXPORT_PACKAGEINFO_FEATURE_H_
