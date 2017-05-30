/* 
 * voip_use_invitecode_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_VOIPINVITECODE_FEATURE_H_
#define EXPORT_VOIPINVITECODE_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class VoipInvitecodeRequest : public SecureHttpRequest {
 public:
  VoipInvitecodeRequest();
  virtual ~VoipInvitecodeRequest();
  VoipInvitecodeRequest(const VoipInvitecodeRequest& other);
  VoipInvitecodeRequest& operator = (const VoipInvitecodeRequest& other);
};

class VoipInvitecodeResponse : public SecureHttpResponse {
 public:
  VoipInvitecodeResponse();
  virtual ~VoipInvitecodeResponse();
  VoipInvitecodeResponse(const VoipInvitecodeResponse& other);
  VoipInvitecodeResponse& operator = (const VoipInvitecodeResponse& other);
};

class VoipInvitecodeFeature : public SecureFeature {
 public:
  VoipInvitecodeFeature();
  virtual ~VoipInvitecodeFeature();
  
  VoipInvitecodeFeature(const VoipInvitecodeFeature& other);
  VoipInvitecodeFeature& operator = (const VoipInvitecodeFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_VOIPINVITECODE_FEATURE_H_
