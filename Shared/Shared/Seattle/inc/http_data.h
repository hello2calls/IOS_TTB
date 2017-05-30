// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef EXPORT_HTTP_DATA_H_
#define EXPORT_HTTP_DATA_H_

#include "define.h"
#include "inet_data.h"

enum HttpMethod {
  kGet,
  kPost,
};

class HttpRequest : public IRequest {
 public:
  HttpRequest(TPSTRING host, TPNUMERIC port, TPSTRING api, HttpMethod method)
      : IRequest(),
        host_(host),
        port_(port),
        api_(api),
        method_(method) {}
  virtual ~HttpRequest() {}

  virtual const TPSTRING get_cookie() = 0;

  inline const TPSTRING& get_host() {
    return host_;
  }
  
  inline const TPNUMERIC get_port() {
    return port_;
  }

  inline const TPSTRING& get_api() {
    return api_;
  }

  virtual const HttpMethod get_method() {
    return method_;
  }

  virtual TPBOOLEAN allow_zip() {
    return true;
  }

 protected:
  TPSTRING host_;
  TPNUMERIC port_;
  TPSTRING api_;
  HttpMethod method_;
};

class HttpResponse : public IResponse {
 public:
  HttpResponse()
      : IResponse() {}
  virtual ~HttpResponse() {}

  inline TPNUMERIC get_status_code() const {
    return status_code_;
  }

  inline void set_status_code(TPNUMERIC status) {
    status_code_ = status;
  }

  inline const TPSTRING& get_cookie() {
    return cookie_;
  }

  inline void set_cookie(const TPSTRING& cookie) {
    cookie_ = cookie;
  }

 private:
  TPSTRING cookie_;
  TPNUMERIC status_code_;
};

#endif // EXPORT_HTTP_DATA_H_
