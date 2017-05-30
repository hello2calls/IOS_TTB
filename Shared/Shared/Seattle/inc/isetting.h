// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef INTERFACE_ISETTING_H_
#define INTERFACE_ISETTING_H_

#include "define.h"
#include "SeattleDefs.h"

class ISetting {
 public:
  ISetting() {}
  virtual ~ISetting() {}

  virtual void setString(const TPSTRING& key, const TPSTRING& value) = 0;
  virtual const TPSTRING getString(const TPSTRING& key) = 0;
};

#endif // INTERFACE_ISETTING_H_
