// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef EXPORT_TP_HTTP_DATA_H_
#define EXPORT_TP_HTTP_DATA_H_

#include "http_data.h"
#include "isetting.h"
#include "feature_runner.h"

class TPHttpRequest : public HttpRequest {
 public:
  TPHttpRequest(TPSTRING host, TPNUMERIC port, TPSTRING api, HttpMethod method)
      : HttpRequest(host, port, api, method) {
    // doing nothing.
  }
  virtual ~TPHttpRequest() {}

  virtual MarshallerType get_marshaller_type() {
    return get_method() == kGet ? kUrlMarshaller : kJsonMarshaller;
  }

  virtual const TPSTRING get_cookie() {
    ISetting* setting = FeatureRunner::get_inst().get_setting();
    TPSTRING key(KEY_TP_COOKIE);
    return setting->getString(key);
  }
};

class TPHttpResponse : public HttpResponse {
 public:
  TPHttpResponse()
      : HttpResponse() {}
  virtual ~TPHttpResponse() {}

  virtual MarshallerType get_marshaller_type() {
    return kJsonMarshaller;
  }
};

#endif // EXPORT_TP_HTTP_DATA_H_
