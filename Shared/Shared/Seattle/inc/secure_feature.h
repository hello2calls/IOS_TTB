/*
 * tp_secure_feature.h
 *
 *  Created on: 2014/6/18
 *      Author: ThomasYe
 */

#ifndef EXPORT_SECURE_FEATURE_H_
#define EXPORT_SECURE_FEATURE_H_

#include "feature.h"

#define DYNAMIC_SERVICE "DYNAMIC_SERVICE"
#define OPT_DYNAMIC_SERVICE "OPT_DYNAMIC_SERVICE"
#define WS_PORT (80)
#define WS_SPORT (443)

#define STATIC_SERVICE "STATIC_SERVICE"
#define DIALER_PORT (80)

class SecureFeature : public Feature {
 public:
  SecureFeature();
  virtual ~SecureFeature();

 protected:
  virtual ChannelType get_channel_type();
  virtual bool require_token();
  virtual bool require_secret();
  bool validate_cookie(TPSTRING &str);
  virtual void validate();
  virtual void process();
  virtual void process_error_code(TPNUMERIC error_code);

};


#endif /* EXPORT_SECURE_FEATURE_H_ */
