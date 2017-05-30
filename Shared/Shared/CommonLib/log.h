//
//  log.h
//  TouchPalDialer
//
//  Created by zhang Owen on 8/4/11.
//  Refactored by Chen Lu on 9/7/12.
//  Copyright 2011 Cootek. All rights reserved.
//

#ifndef COMMON_LIB_LOG_H_
#define COMMON_LIB_LOG_H_

#define COLLECT_APP_LOG NO
#if defined(DEBUG) || COLLECT_APP_LOG
#define cootek_log(...) NSLog(__VA_ARGS__)
#define cootek_log_function NSLog(@"%s", __PRETTY_FUNCTION__)
#else
#define cootek_log(...)
#define cootek_log_function
#endif

#endif