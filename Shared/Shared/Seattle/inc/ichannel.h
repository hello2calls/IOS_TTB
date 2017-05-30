// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef INTERFACE_ICHANNEL_H_
#define INTERFACE_ICHANNEL_H_

#include "define.h"

enum NetworkType {
  kNetworkUnknown,
  kNetworkNotAvailable,
  kNetworkMobile,
  kNetworkWifi,
};

enum ChannelType {
  kHttpChannel,
  kHttpsChannel,
  kSecureZeroChannel,
  kSecureOneChannel,
  kSecureTwoChannel,
  kSecureThreeChannel,
  // add other channel type here.

  kChannelCount, // the count of channel type
};

class IRequest;
class IResponse;

enum RequestSendResult {
  kSuccess,
  kUnrecoverableFailure,
  kNeedRetry,
  kNeedRetryLater,
};

class IChannel {
 public:
  IChannel() {}
  virtual ~IChannel() {}
  
  virtual RequestSendResult send(IRequest* request, IResponse* response) const = 0;
};

class IChannelManager {
 public:
  IChannelManager() {}
  virtual ~IChannelManager() {}
  
  virtual const IChannel* get_channel(ChannelType type) = 0;
  virtual void destroy_channel(ChannelType type) = 0;
  virtual NetworkType get_network_type() = 0;
};

#endif // INTERFACE_ICHANNEL_H_
