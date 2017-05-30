// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef INTERFACE_INET_DATA_H_
#define INTERFACE_INET_DATA_H_

#include "define.h"
#include "message_base.h"
#include "marshaller_manager.h"

class IRequest {
 public:
  IRequest();
  virtual ~IRequest();

  virtual MarshallerType get_marshaller_type() = 0;
  virtual void marshal_by();
  inline MessageBase* get_data() {
    return data_;
  }

  inline const TPSTRING& get_message_string() {
    return message_string_;
  }
  
  inline void set_message_string(const TPSTRING& msg) {
    message_string_ = msg;
  }

 protected:
  MessageBase* data_;
  TPSTRING message_string_;
};

class IResponse {
 public:
  IResponse();
  virtual ~IResponse();

  inline void set_valid(TPBOOLEAN valid) {
    valid_ = valid;
  }
  
  inline TPBOOLEAN is_valid() {
    return valid_;
  }
  
  inline MessageBase* get_data() {
    return data_;
  }

  inline const TPSTRING& get_message_string() {
    return message_string_;
  }

  inline void set_message_string(const TPSTRING& msg) {
    message_string_ = msg;
  }

  virtual MarshallerType get_marshaller_type() = 0;
  virtual void unmarshal_by();
  
 protected:
  MessageBase* data_;
  TPSTRING message_string_;
 private:
  TPBOOLEAN valid_;
};

#endif // INTERFACE_INET_DATA_H_
