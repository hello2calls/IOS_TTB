// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef FEATURE_H_
#define FEATURE_H_

#include "define.h"
#include "ichannel.h"
#include "inet_data.h"

enum FeatureStatus {
  kFeatureInitialized,
  kFeatureExecuting,
  kFeatureDone, //success
  kFeatureFailed, //permanent failure. No need to retry
  kFeatureFailedMaybeRetryLater, // usually get this status for HTTP 408 or 5xx error. In the future, the seattle queue should handle this.
  kFeatureCancelled,  //not used yet
  kFeatureNeedRetry,  //need retry immediately. In the future, the feature.execute logic should handle this.
  kFeatureNeedRetryLater,  //need retry 5 minutes later. In the future, the seattle queue should handle this.
  kFeatureInternalFailed,
};

#define DEFAULT_MAX_FEATURE_RETRY_TIME (2)

class Feature {
 public:
  explicit Feature(TPNUMERIC feature_id);
  virtual ~Feature();

  inline const TPNUMERIC get_feature_id() const {
    return feature_id_;
  }
  
  inline const FeatureStatus get_status() const {
    return status_;
  }
  
  inline const TPNUMERIC get_error_code() const {
    return error_code_;
  }
  
  inline IRequest* get_request() {
    return request_;
  }
  
  inline IResponse* get_response() {
    return response_;
  }
  
  void execute();
  void reset();
  void cancel();

  virtual bool should_skip_if_no_wifi();

 protected:
  virtual ChannelType get_channel_type() = 0;
  virtual TPNUMERIC get_max_retry_time();

  virtual void prepare();
  virtual void validate();
  virtual void marshal();
  virtual void send();
  virtual void unmarshal();
  virtual void process();

  // do reset feature.
  virtual void on_reset();
  // do cancel feature.
  virtual void on_cancel();

  inline void set_status(FeatureStatus status) {
    status_ = status;
  }
  
  inline void set_error_code(TPNUMERIC error_code) {
    error_code_ = error_code;
  }

  IRequest* request_;
  IResponse* response_;

 private:
  TPNUMERIC feature_id_;
  TPNUMERIC error_code_;
  FeatureStatus status_;
  TPNUMERIC retried_count_;
};

#endif // EXPORT_FEATURE_H_ 
