/* 
 * account_info_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_ACCOUNTINFO_FEATURE_H_
#define EXPORT_ACCOUNTINFO_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class AccountInfoRequest : public SecureHttpRequest {
 public:
  AccountInfoRequest();
  virtual ~AccountInfoRequest();
  AccountInfoRequest(const AccountInfoRequest& other);
  AccountInfoRequest& operator = (const AccountInfoRequest& other);
};

class AccountInfoResponse : public SecureHttpResponse {
 public:
  AccountInfoResponse();
  virtual ~AccountInfoResponse();
  AccountInfoResponse(const AccountInfoResponse& other);
  AccountInfoResponse& operator = (const AccountInfoResponse& other);
};

class AccountInfoFeature : public SecureFeature {
 public:
  AccountInfoFeature();
  virtual ~AccountInfoFeature();
  virtual TPNUMERIC get_max_retry_time();
  AccountInfoFeature(const AccountInfoFeature& other);
  AccountInfoFeature& operator = (const AccountInfoFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_ACCOUNTINFO_FEATURE_H_
