/*
 * secure_message.h
 *
 *  Created on: 2014/6/19
 *      Author: ThomasYe
 */

#ifndef SECURE_MESSAGE_H_
#define SECURE_MESSAGE_H_

#include "message_base.h"

class SecureResponseMessage : public MessageBase {
public:
  SecureResponseMessage() { result_code = 0; }
  virtual ~SecureResponseMessage() {}

  TPNUMERIC result_code;
};

#endif /* SECURE_MESSAGE_H_ */
