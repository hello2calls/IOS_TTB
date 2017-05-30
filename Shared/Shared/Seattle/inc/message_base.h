// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef MESSAGE_BASE_H_
#define MESSAGE_BASE_H_

#include "define.h"
#include "string_utils.h"

class MessageBase {
 public:
  MessageBase() {}
  virtual ~MessageBase() {}
  virtual const TPSTRING get_type() const {
    return "MessageBase";
  }
};

#endif // MESSAGE_BASE_H_
