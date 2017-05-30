// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef EXPORT_TP_FEATURE_H_
#define EXPORT_TP_FEATURE_H_

#include "feature.h"

#define CONCALL_SERVICE "CALLCALL_SERVICE"

#define SEARCH_SERVICE "SEARCH"

#define DYNAMIC_SERVICE "DYNAMIC_SERVICE"
#define OPT_DYNAMIC_SERVICE "OPT_DYNAMIC_SERVICE"
#define WS_PORT (80)
#define WS_SPORT (443)
#define CS_PORT (7080)

#define STATIC_SERVICE "STATIC_SERVICE"
#define DIALER_PORT (80)

class TPFeature : public Feature {
 public:
  TPFeature();
  virtual ~TPFeature();

 protected:
  virtual ChannelType get_channel_type();
  virtual bool require_token();
  bool validate_cookie(TPSTRING &str); 
  virtual void validate();
  virtual void process();
  virtual void process_error_code(TPNUMERIC error_code);

};

#endif // EXPORT_TP_FEATURE_H_
