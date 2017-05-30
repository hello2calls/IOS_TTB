/* 
 * has_join_wechat_public_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_HASJOINWECHATPUBLIC_FEATURE_H_
#define EXPORT_HASJOINWECHATPUBLIC_FEATURE_H_

#include "secure_feature.h"
#include "secure_http_data.h"
#include "tp_message_generated.h"

class HasJoinWechatPublicRequest : public SecureHttpRequest {
 public:
  HasJoinWechatPublicRequest();
  virtual ~HasJoinWechatPublicRequest();
  HasJoinWechatPublicRequest(const HasJoinWechatPublicRequest& other);
  HasJoinWechatPublicRequest& operator = (const HasJoinWechatPublicRequest& other);
};

class HasJoinWechatPublicResponse : public SecureHttpResponse {
 public:
  HasJoinWechatPublicResponse();
  virtual ~HasJoinWechatPublicResponse();
  HasJoinWechatPublicResponse(const HasJoinWechatPublicResponse& other);
  HasJoinWechatPublicResponse& operator = (const HasJoinWechatPublicResponse& other);
};

class HasJoinWechatPublicFeature : public SecureFeature {
 public:
  HasJoinWechatPublicFeature();
  virtual ~HasJoinWechatPublicFeature();
  
  HasJoinWechatPublicFeature(const HasJoinWechatPublicFeature& other);
  HasJoinWechatPublicFeature& operator = (const HasJoinWechatPublicFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_HASJOINWECHATPUBLIC_FEATURE_H_
