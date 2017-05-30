/* 
 * redeem_exchange_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_REDEEMEXCHANGE_FEATURE_H_
#define EXPORT_REDEEMEXCHANGE_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class RedeemExchangeRequest : public SecureHttpRequest {
 public:
  RedeemExchangeRequest();
  virtual ~RedeemExchangeRequest();
  RedeemExchangeRequest(const RedeemExchangeRequest& other);
  RedeemExchangeRequest& operator = (const RedeemExchangeRequest& other);
};

class RedeemExchangeResponse : public SecureHttpResponse {
 public:
  RedeemExchangeResponse();
  virtual ~RedeemExchangeResponse();
  RedeemExchangeResponse(const RedeemExchangeResponse& other);
  RedeemExchangeResponse& operator = (const RedeemExchangeResponse& other);
};

class RedeemExchangeFeature : public SecureFeature {
 public:
  RedeemExchangeFeature();
  virtual ~RedeemExchangeFeature();
  virtual TPNUMERIC get_max_retry_time();
  RedeemExchangeFeature(const RedeemExchangeFeature& other);
  RedeemExchangeFeature& operator = (const RedeemExchangeFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_REDEEMEXCHANGE_FEATURE_H_
