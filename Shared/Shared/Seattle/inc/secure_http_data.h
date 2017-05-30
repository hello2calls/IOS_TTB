/*
 * tp_secure_http_data.h
 *
 *  Created on: 2014/6/18
 *      Author: ThomasYe
 */

#ifndef EXPORT_TP_SECURE_HTTP_DATA_H_
#define EXPORT_TP_SECURE_HTTP_DATA_H_

#include "tp_http_data.h"
#include "isetting.h"
#include "feature_runner.h"

class SecureHttpRequest : public HttpRequest {
 public:
  SecureHttpRequest(TPSTRING host, TPNUMERIC port, TPSTRING api, HttpMethod method, TPNUMERIC version)
      : HttpRequest(host, port, api, method), version_(version) {
    // doing nothing.
  }
  virtual ~SecureHttpRequest() {}

  virtual MarshallerType get_marshaller_type() {
    return get_method() == kGet ? kUrlMarshaller : kJsonMarshaller;
  }

  virtual const TPSTRING get_cookie() {
    ISetting* setting = FeatureRunner::get_inst().get_setting();
    TPSTRING key(KEY_TP_COOKIE);
    return setting->getString(key);
  }

  virtual const TPSTRING get_secret() {
    ISetting* setting = FeatureRunner::get_inst().get_setting();
    TPSTRING key(KEY_TP_SECRET);
    return setting->getString(key);
  }

  virtual const TPNUMERIC get_version() {
    return version_;
  }

 protected:
  TPNUMERIC version_;

};

class SecureHttpResponse : public HttpResponse {
 public:
  SecureHttpResponse()
      : HttpResponse() {}
  virtual ~SecureHttpResponse() {}

  virtual MarshallerType get_marshaller_type() {
    return kJsonMarshaller;
  }
};


#endif /* TP_SECURE_HTTP_DATA_H_ */
