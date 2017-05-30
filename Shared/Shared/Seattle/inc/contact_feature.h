/* 
 * contact_feature.h 
 * 
 *  Created on: 
 *      Author: feature_generator.py by ElfeXu 
 */  

#ifndef EXPORT_CONTACT_FEATURE_H_
#define EXPORT_CONTACT_FEATURE_H_

#include "tp_feature.h"
#include "tp_http_data.h"
#include "tp_message_generated.h"

class ContactRequest : public TPHttpRequest {
 public:
  ContactRequest();
  virtual ~ContactRequest();
  ContactRequest(const ContactRequest& other);
  ContactRequest& operator = (const ContactRequest& other);
};

class ContactResponse : public TPHttpResponse {
 public:
  ContactResponse();
  virtual ~ContactResponse();
  ContactResponse(const ContactResponse& other);
  ContactResponse& operator = (const ContactResponse& other);
};

class ContactFeature : public TPFeature {
 public:
  ContactFeature();
  virtual ~ContactFeature();
  
  ContactFeature(const ContactFeature& other);
  ContactFeature& operator = (const ContactFeature& other);
  virtual ChannelType get_channel_type();
};

#endif // EXPORT_CONTACT_FEATURE_H_
