// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef EXPORT_VOIP_FEATURE_H_
#define EXPORT_VOIP_FEATURE_H_

#include "feature.h"

#define VOIP_SERVICE "VOIP_SERVICE"
#define WS_PORT (80)
#define WS_SPORT (443)

#define STATIC_SERVICE "STATIC_SERVICE"
#define DIALER_PORT (80)

class VoipFeature : public Feature {
 public:
  VoipFeature();
  virtual ~VoipFeature();

 protected:
  bool validate_cookie(TPSTRING &str); 
  virtual ChannelType get_channel_type();
  virtual bool require_token();
  
  virtual void validate();
  virtual void process();
  virtual void process_error_code(TPNUMERIC error_code);

};

#endif // EXPORT_VOIP_FEATURE_H_
