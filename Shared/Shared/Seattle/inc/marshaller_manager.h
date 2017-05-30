// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef MARSHALLER_MANAGER_H_
#define MARSHALLER_MANAGER_H_

#include "imarshaller.h"

enum MarshallerType {
  kUrlMarshaller,
  kJsonMarshaller,
  kXmlMarshaller,
};

const int kMarshallerCount = 3;

class MarshallerManager {
 public:
  MarshallerManager();
  ~MarshallerManager();

  const IMarshaller* get_marshaller(MarshallerType type);
  void destroy_marshaller(MarshallerType type);

 private:
  IMarshaller* create_marshaller(MarshallerType type);
  IMarshaller* marshallers_[kMarshallerCount];
};

#endif // MARSHALLER_MANAGER_H_
