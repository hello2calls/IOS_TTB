// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef EXPORT_FEATURE_RUNNER_H_
#define EXPORT_FEATURE_RUNNER_H_

#include "ichannel.h"
#include "isetting.h"
#include "ievent_handler.h"
#include "marshaller_manager.h"
#include "feature.h"

class FeatureRunner {
 public:
  static void initialize(IChannelManager* channel_manager, ISetting* setting, IEventHandler* event_handler, TPSTRING data_path);
  static void deinitialize();
  static FeatureRunner& get_inst();
  static TPNUMERIC generate_feature_id();

  FeatureStatus execute_feature(Feature* feature);
  const IChannel* get_channel(ChannelType type);
  const IMarshaller* get_marshaller(MarshallerType type);
  inline IEventHandler* get_event_handler() {
    return event_handler_;
  }
  inline ISetting* get_setting() {
    return setting_;
  }
  
 private:
  static FeatureRunner* g_instance_;
  static TPNUMERIC g_feature_count_;

  FeatureRunner(IChannelManager* channel_manager, ISetting* setting, IEventHandler* event_handler);
  ~FeatureRunner();

  IChannelManager* channel_manager_;
  MarshallerManager marshaller_manager_;
  ISetting* setting_;
  IEventHandler* event_handler_;
};

#endif
