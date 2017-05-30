// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef EXPORT_VOIP_HTTP_DATA_H_
#define EXPORT_VOIP_HTTP_DATA_H_

#include "http_data.h"
#include "isetting.h"
#include "log.h"
#include "feature_runner.h"

class VoipHttpRequest : public HttpRequest {
 public:
  VoipHttpRequest(TPSTRING host, TPNUMERIC port, TPSTRING api, HttpMethod method)
      : HttpRequest(host, port, api, method) {
    // doing nothing.
  }
  virtual ~VoipHttpRequest() {}

  virtual MarshallerType get_marshaller_type() {
    return get_method() == kGet ? kUrlMarshaller : kJsonMarshaller;
  }

  virtual const TPSTRING get_cookie() {
    ISetting* setting = FeatureRunner::get_inst().get_setting();
    TPSTRING key(KEY_VOIP_COOKIE);
    return setting->getString(key);
  }
};

class VoipHttpResponse : public HttpResponse {
 public:
  VoipHttpResponse()
      : HttpResponse() {}
  virtual ~VoipHttpResponse() {}

  virtual MarshallerType get_marshaller_type() {
    return kJsonMarshaller;
  }
};

#endif // EXPORT_TP_HTTP_DATA_H_
