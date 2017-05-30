// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef COMMON_MESSAGE_H_
#define COMMON_MESSAGE_H_

//#include "message_base.h"
//
//// common message
//class Location : public MessageBase {
// public:
//  Location() : MessageBase() {}
//  ~Location() {}
//
//  TPDOUBLE latitude;
//  TPDOUBLE longitude;
//};
//
//class CallLogData : public MessageBase {
// public:
//  CallLogData()
//      : MessageBase(),
//        other_phone(),
//        type(),
//        date(0),
//        duration(0),
//        this_phone(),
//        network_mnc(),
//        sim_mnc(),
//        contact(FALSE),
//        roaming(FALSE),
//        ring_time(0),
//        ending_call(0),
//        loc() {}
//  virtual ~CallLogData() {}
//
//  // must have.
//  TPSTRING other_phone;
//  TPSTRING type; // "incoming" or "outgoing"
//  TPULONGLONG date; // seconds since 1970.1.1 00:00
//  TPULONGLONG duration;
//  // may have.
//  TPSTRING this_phone; // user's normalized phone number
//  TPSTRING network_mnc;
//  TPSTRING sim_mnc;
//  TPBOOLEAN contact; // whether the other_phone is contact
//  TPBOOLEAN roaming; // whether user is roaming
//  TPULONGLONG ring_time; // the ringing time
//  TPNUMERIC ending_call; // 1 for passive hang up, 2 for postive hang up
//  Location loc; // location
//};

#endif // COMMON_MESSAGE_H_
