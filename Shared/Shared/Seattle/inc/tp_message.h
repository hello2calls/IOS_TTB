/*
 * tp_response_message.h
 *
 *  Created on: 2013-1-22
 *      Author: ElfeXu
 */

#ifndef TP_MESSAGE_H_
#define TP_MESSAGE_H_

#include "message_base.h"

class TPResponseMessage : public MessageBase {
public:
  TPResponseMessage() { error_code = 0; }
  virtual ~TPResponseMessage() {}

  TPNUMERIC error_code;
};

#endif /* TP_MESSAGE_H_ */
