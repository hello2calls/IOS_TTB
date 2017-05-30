// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef IMARSHALLER_H_
#define IMARSHALLER_H_

#include "ichannel.h"

class MessageBase;

class IMarshaller {
 public: 
  IMarshaller () {};
  virtual ~IMarshaller() {};

  // convert a message to a TPSTRING.
  virtual TPBOOLEAN marshal(const MessageBase& message, TPSTRING& result) const = 0;
  // convert a TPString to a message.
  virtual TPBOOLEAN unmarshal(const TPSTRING& str, MessageBase& message) const = 0;
};

#endif // IMARSHALLER_H_
