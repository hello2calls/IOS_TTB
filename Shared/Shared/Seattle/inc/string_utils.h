// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef STRING_UTILS_H_
#define STRING_UTILS_H_

#include "define.h"

#define MAX_CONVERT_STRING_SIZE         128

extern TPSTRING numeric_to_string(TPNUMERIC value);
extern TPNUMERIC string_to_numeric(const TPSTRING& str);
extern TPSTRING boolean_to_string(TPBOOLEAN value);
extern TPSTRING double_to_string(TPDOUBLE value);
extern TPSTRING ulonglong_to_string(TPULONGLONG num);
extern TPULONGLONG string_to_ulonglong(const TPSTRING& str);
extern TPDOUBLE string_to_double(const TPSTRING& str);
extern TPSTRING url_encode(const TPSTRING& url);

#endif // STRING_UTILS_H_
