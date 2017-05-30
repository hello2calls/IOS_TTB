// Copyright(c) 2013 CooTek
// All rights reserved
//
// author: Thomas Ye (Thomas.Ye@CooTek.cn)

#ifndef EXPORT_ERROR_CODE_H_
#define EXPORT_ERROR_CODE_H_

#define NO_ERROR (0)
#define NETWORK_ERROR (1)
#define ARGUMENT_ERROR (1000)
#define TOKEN_MISSED (-1)
#define TOKEN_INVALID (1001)
#define UPDATE_TOKEN (1002)
#define RETRY_LATER (1004)
#define NEED_LOGOUT (1005)
#define PERMISSION_DENY (1006)
#define ACCOUNT_INVALID (2000)
#define ACCOUNT_EXIST (2001)
#define VALIDATE_CODE_ERROR (5000)
#define PASSWORD_ERROR (6000)

#define SECURE_ERROR_BEGIN (4000)
#define SECURE_NO_SECRET (4001)
#define SECURE_SIGN_INVALID (4002)
#define SECURE_TOKEN_INVALID (4003)
#define SECURE_TOKEN_UNLOGIN (4004)
#define SECURE_ERROR_END (4099)


#endif // EXPORT_ERROR_CODE_H_

