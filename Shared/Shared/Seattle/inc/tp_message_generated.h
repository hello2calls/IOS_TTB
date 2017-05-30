/* 
 * tp_message_generated.h 
 * 
 *  Created on: 2016-09-19
 *      Author: message_header_generator.py by ElfeXu 
 */ 
 
#ifndef TP_MESSAGE_GENERATED_H_ 
#define TP_MESSAGE_GENERATED_H_ 
 
#include "tp_message.h"
#include "secure_message.h"
#include "define.h"

    
class NullableBooleanMessage : public MessageBase {
public:
  NullableBooleanMessage();
  virtual ~NullableBooleanMessage();
  NullableBooleanMessage(const NullableBooleanMessage&);
  NullableBooleanMessage& operator = (const NullableBooleanMessage&);
  
  virtual const TPSTRING get_type() const {
    return "NullableBooleanMessage";
  }
    
  TPBOOLEAN NONAME;  

};

    
class NullableDoubleMessage : public MessageBase {
public:
  NullableDoubleMessage();
  virtual ~NullableDoubleMessage();
  NullableDoubleMessage(const NullableDoubleMessage&);
  NullableDoubleMessage& operator = (const NullableDoubleMessage&);
  
  virtual const TPSTRING get_type() const {
    return "NullableDoubleMessage";
  }
    
  TPDOUBLE NONAME;  

};

    
class NullableNumberMessage : public MessageBase {
public:
  NullableNumberMessage();
  virtual ~NullableNumberMessage();
  NullableNumberMessage(const NullableNumberMessage&);
  NullableNumberMessage& operator = (const NullableNumberMessage&);
  
  virtual const TPSTRING get_type() const {
    return "NullableNumberMessage";
  }
    
  TPNUMERIC NONAME;  

};

    
class CellInfoMessage : public MessageBase {
public:
  CellInfoMessage();
  virtual ~CellInfoMessage();
  CellInfoMessage(const CellInfoMessage&);
  CellInfoMessage& operator = (const CellInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CellInfoMessage";
  }
    
  NullableNumberMessage* lac;  
  void create_lac(const NullableNumberMessage& item);
  void remove_lac();
        
  NullableNumberMessage* cid;  
  void create_cid(const NullableNumberMessage& item);
  void remove_cid();
        
  NullableNumberMessage* base_id;  
  void create_base_id(const NullableNumberMessage& item);
  void remove_base_id();
        
};

    
class ActivateRequestMessage : public MessageBase {
public:
  ActivateRequestMessage();
  virtual ~ActivateRequestMessage();
  ActivateRequestMessage(const ActivateRequestMessage&);
  ActivateRequestMessage& operator = (const ActivateRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ActivateRequestMessage";
  }
    
  TPSTRING app_name;  

  TPSTRING app_version;  

  TPSTRING activate_type;  

  TPSTRING os_name;  

  TPSTRING os_version;  

  TPSTRING device_info;  

  TPSTRING channel_code;  

  TPSTRING imei;  

  TPSTRING uuid;  

  TPSTRING simid;  

  TPSTRING locale;  

  TPSTRING mnc;  

  TPSTRING manufacturer;  

  TPSTRING api_level;  

  TPSTRING host_app_name;  

  TPSTRING host_app_version;  

  TPSTRING resolution;  

  TPSTRING dpi;  

  TPSTRING physical_size;  

  TPSTRING recommend_channel;  

  TPSTRING identifier;  

  TPBOOLEAN sys_app;  

  TPSTRING apple_token;  

  TPSTRING idfa;  

  TPSTRING idfv;  

  TPSTRING random_uuid;  

};

    
class ActivateResponseMessage : public TPResponseMessage {
public:
  ActivateResponseMessage();
  virtual ~ActivateResponseMessage();
  ActivateResponseMessage(const ActivateResponseMessage&);
  ActivateResponseMessage& operator = (const ActivateResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ActivateResponseMessage";
  }
    
};

    
class LocationMessage : public MessageBase {
public:
  LocationMessage();
  virtual ~LocationMessage();
  LocationMessage(const LocationMessage&);
  LocationMessage& operator = (const LocationMessage&);
  
  virtual const TPSTRING get_type() const {
    return "LocationMessage";
  }
    
  TPDOUBLE latitude;  

  TPDOUBLE longitude;  

};

    
class CallItemMessage : public MessageBase {
public:
  CallItemMessage();
  virtual ~CallItemMessage();
  CallItemMessage(const CallItemMessage&);
  CallItemMessage& operator = (const CallItemMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CallItemMessage";
  }
    
  TPSTRING this_phone;  

  TPSTRING other_phone;  

  TPSTRING type;  

  TPSTRING network_mnc;  

  TPSTRING sim_mnc;  

  TPBOOLEAN contact;  

  TPBOOLEAN roaming;  

  TPNUMERIC date;  

  TPNUMERIC duration;  

  TPNUMERIC ring_time;  

  TPNUMERIC ending_call;  

  LocationMessage* loc;  
  void create_loc(const LocationMessage& item);
  void remove_loc();
        
  CellInfoMessage* cell;  
  void create_cell(const CellInfoMessage& item);
  void remove_cell();
        
};

    
class CallLogRequestMessage : public MessageBase {
public:
  CallLogRequestMessage();
  virtual ~CallLogRequestMessage();
  CallLogRequestMessage(const CallLogRequestMessage&);
  CallLogRequestMessage& operator = (const CallLogRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CallLogRequestMessage";
  }
    
  VECTOR_T(CallItemMessage*) data;  
  void insert_data(const CallItemMessage& item);

};

    
class CallLogResponseMessage : public TPResponseMessage {
public:
  CallLogResponseMessage();
  virtual ~CallLogResponseMessage();
  CallLogResponseMessage(const CallLogResponseMessage&);
  CallLogResponseMessage& operator = (const CallLogResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CallLogResponseMessage";
  }
    
};

    
class SurveyRequestMessage : public MessageBase {
public:
  SurveyRequestMessage();
  virtual ~SurveyRequestMessage();
  SurveyRequestMessage(const SurveyRequestMessage&);
  SurveyRequestMessage& operator = (const SurveyRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SurveyRequestMessage";
  }
    
  TPSTRING phone;  

  TPBOOLEAN is_survey;  

  TPSTRING user_tag;  

  NullableBooleanMessage* system_correct;  
  void create_system_correct(const NullableBooleanMessage& item);
  void remove_system_correct();
        
  TPSTRING system_tag;  

  TPSTRING system_name;  

  TPSTRING custom_tag;  

  TPSTRING network_mnc;  

  CellInfoMessage* cell;  
  void create_cell(const CellInfoMessage& item);
  void remove_cell();
        
  NullableBooleanMessage* roaming;  
  void create_roaming(const NullableBooleanMessage& item);
  void remove_roaming();
        
  LocationMessage* loc;  
  void create_loc(const LocationMessage& item);
  void remove_loc();
        
  TPBOOLEAN incomming_mark;  

};

    
class SurveyResponseMessage : public TPResponseMessage {
public:
  SurveyResponseMessage();
  virtual ~SurveyResponseMessage();
  SurveyResponseMessage(const SurveyResponseMessage&);
  SurveyResponseMessage& operator = (const SurveyResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SurveyResponseMessage";
  }
    
};

    
class CancelSurveyRequestMessage : public MessageBase {
public:
  CancelSurveyRequestMessage();
  virtual ~CancelSurveyRequestMessage();
  CancelSurveyRequestMessage(const CancelSurveyRequestMessage&);
  CancelSurveyRequestMessage& operator = (const CancelSurveyRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CancelSurveyRequestMessage";
  }
    
  VECTOR_T(TPSTRING) phones;  

  TPSTRING network_mnc;  

  CellInfoMessage* cell;  
  void create_cell(const CellInfoMessage& item);
  void remove_cell();
        
  NullableBooleanMessage* roaming;  
  void create_roaming(const NullableBooleanMessage& item);
  void remove_roaming();
        
  LocationMessage* loc;  
  void create_loc(const LocationMessage& item);
  void remove_loc();
        
};

    
class CancelSurveyResponseMessage : public TPResponseMessage {
public:
  CancelSurveyResponseMessage();
  virtual ~CancelSurveyResponseMessage();
  CancelSurveyResponseMessage(const CancelSurveyResponseMessage&);
  CancelSurveyResponseMessage& operator = (const CancelSurveyResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CancelSurveyResponseMessage";
  }
    
};

    
class BlackItemMessage : public MessageBase {
public:
  BlackItemMessage();
  virtual ~BlackItemMessage();
  BlackItemMessage(const BlackItemMessage&);
  BlackItemMessage& operator = (const BlackItemMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BlackItemMessage";
  }
    
  TPSTRING phone;  

  TPBOOLEAN contact;  

};

    
class BlackListRequestMessage : public MessageBase {
public:
  BlackListRequestMessage();
  virtual ~BlackListRequestMessage();
  BlackListRequestMessage(const BlackListRequestMessage&);
  BlackListRequestMessage& operator = (const BlackListRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BlackListRequestMessage";
  }
    
  VECTOR_T(BlackItemMessage*) NONAME;  
  void insert_NONAME(const BlackItemMessage& item);

};

    
class BlackListResponseMessage : public TPResponseMessage {
public:
  BlackListResponseMessage();
  virtual ~BlackListResponseMessage();
  BlackListResponseMessage(const BlackListResponseMessage&);
  BlackListResponseMessage& operator = (const BlackListResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BlackListResponseMessage";
  }
    
};

    
class YellowpageInfoRequestMessage : public MessageBase {
public:
  YellowpageInfoRequestMessage();
  virtual ~YellowpageInfoRequestMessage();
  YellowpageInfoRequestMessage(const YellowpageInfoRequestMessage&);
  YellowpageInfoRequestMessage& operator = (const YellowpageInfoRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageInfoRequestMessage";
  }
    
  TPBOOLEAN survey;  

  TPBOOLEAN need_slots;  

  TPBOOLEAN need_promotion;  

  TPBOOLEAN need_advertisement;  

  NullableBooleanMessage* guess;  
  void create_guess(const NullableBooleanMessage& item);
  void remove_guess();
        
  VECTOR_T(TPSTRING) phone;  

  TPSTRING network_mnc;  

  CellInfoMessage* cell;  
  void create_cell(const CellInfoMessage& item);
  void remove_cell();
        
  NullableBooleanMessage* roaming;  
  void create_roaming(const NullableBooleanMessage& item);
  void remove_roaming();
        
  LocationMessage* loc;  
  void create_loc(const LocationMessage& item);
  void remove_loc();
        
};

    
class YellowpageInfo2RequestMessage : public MessageBase {
public:
  YellowpageInfo2RequestMessage();
  virtual ~YellowpageInfo2RequestMessage();
  YellowpageInfo2RequestMessage(const YellowpageInfo2RequestMessage&);
  YellowpageInfo2RequestMessage& operator = (const YellowpageInfo2RequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageInfo2RequestMessage";
  }
    
  TPSTRING network_mnc;  

  CellInfoMessage* cell;  
  void create_cell(const CellInfoMessage& item);
  void remove_cell();
        
  NullableBooleanMessage* roaming;  
  void create_roaming(const NullableBooleanMessage& item);
  void remove_roaming();
        
  TPSTRING this_phone;  

  TPSTRING other_phone;  

  TPSTRING type;  

  TPSTRING call_type;  

  TPSTRING sim_mnc;  

  TPBOOLEAN contact;  

  TPNUMERIC date;  

  TPNUMERIC duration;  

  TPNUMERIC ring_time;  

  TPNUMERIC ending_call;  

  LocationMessage* loc;  
  void create_loc(const LocationMessage& item);
  void remove_loc();
        
  TPBOOLEAN isprivate;  

};

    
class SurveyMessage : public MessageBase {
public:
  SurveyMessage();
  virtual ~SurveyMessage();
  SurveyMessage(const SurveyMessage&);
  SurveyMessage& operator = (const SurveyMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SurveyMessage";
  }
    
  TPSTRING system_tag;  

  TPSTRING system_name;  

};

    
class SlotsMessage : public MessageBase {
public:
  SlotsMessage();
  virtual ~SlotsMessage();
  SlotsMessage(const SlotsMessage&);
  SlotsMessage& operator = (const SlotsMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SlotsMessage";
  }
    
  TPSTRING type;  

  TPSTRING title;  

  TPSTRING sub_title;  

  TPSTRING phone;  

  LocationMessage* loc;  
  void create_loc(const LocationMessage& item);
  void remove_loc();
        
  TPSTRING content;  

  TPSTRING icon;  

  TPSTRING internal_link;  

  TPSTRING external_link;  

  TPSTRING package;  

  TPSTRING promote;  

  TPSTRING source_title;  

  TPSTRING edurl;  

};

    
class PromotionMessage : public MessageBase {
public:
  PromotionMessage();
  virtual ~PromotionMessage();
  PromotionMessage(const PromotionMessage&);
  PromotionMessage& operator = (const PromotionMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PromotionMessage";
  }
    
  TPSTRING _short;  

  TPSTRING _long;  

  TPNUMERIC count;  

  TPSTRING color;  

  TPSTRING image;  

  TPSTRING internal_link;  

  TPSTRING external_link;  

};

    
class AdvertisementsMessage : public MessageBase {
public:
  AdvertisementsMessage();
  virtual ~AdvertisementsMessage();
  AdvertisementsMessage(const AdvertisementsMessage&);
  AdvertisementsMessage& operator = (const AdvertisementsMessage&);
  
  virtual const TPSTRING get_type() const {
    return "AdvertisementsMessage";
  }
    
  TPSTRING type;  

  TPSTRING scenario;  

  TPSTRING title;  

  TPSTRING sub_title;  

  TPSTRING phone;  

  TPSTRING banner_image;  

  TPSTRING full_link;  

  TPSTRING external_link;  

  TPSTRING internal_link;  

  TPSTRING source;  

};

    
class VipInfoMessage : public MessageBase {
public:
  VipInfoMessage();
  virtual ~VipInfoMessage();
  VipInfoMessage(const VipInfoMessage&);
  VipInfoMessage& operator = (const VipInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VipInfoMessage";
  }
    
  TPSTRING url;  

  TPSTRING description;  

  TPSTRING logo;  

};

    
class CallerInfoMessage : public MessageBase {
public:
  CallerInfoMessage();
  virtual ~CallerInfoMessage();
  CallerInfoMessage(const CallerInfoMessage&);
  CallerInfoMessage& operator = (const CallerInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CallerInfoMessage";
  }
    
  TPSTRING phone;  

  TPSTRING area_code;  

  TPSTRING verify_type;  

  TPSTRING classify_type;  

  TPSTRING shop_name;  

  TPSTRING shop_info;  

  TPSTRING incoming_classify_type;  

  TPSTRING incoming_shop_name;  

  TPSTRING incoming_shop_info;  

  TPSTRING shop_logo;  

  TPNUMERIC mark_count;  

  TPNUMERIC version;  

  TPSTRING reference;  

  TPSTRING reference_logo;  

  TPSTRING coupon_source;  

  TPSTRING coupon_logo;  

  TPSTRING commercial;  

  TPSTRING external_link;  

  TPSTRING auth_type;  

  TPSTRING warning;  

  TPSTRING internal_shop_link;  

  SurveyMessage* survey;  
  void create_survey(const SurveyMessage& item);
  void remove_survey();
        
  VECTOR_T(SlotsMessage*) slots;  
  void insert_slots(const SlotsMessage& item);

  VECTOR_T(PromotionMessage*) promotion;  
  void insert_promotion(const PromotionMessage& item);

  VECTOR_T(AdvertisementsMessage*) advertisements;  
  void insert_advertisements(const AdvertisementsMessage& item);

};

    
class YellowpageInfoResponseMessage : public TPResponseMessage {
public:
  YellowpageInfoResponseMessage();
  virtual ~YellowpageInfoResponseMessage();
  YellowpageInfoResponseMessage(const YellowpageInfoResponseMessage&);
  YellowpageInfoResponseMessage& operator = (const YellowpageInfoResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageInfoResponseMessage";
  }
    
  VECTOR_T(CallerInfoMessage*) res;  
  void insert_res(const CallerInfoMessage& item);

};

    
class YellowpageInfo2ResponseMessage : public TPResponseMessage {
public:
  YellowpageInfo2ResponseMessage();
  virtual ~YellowpageInfo2ResponseMessage();
  YellowpageInfo2ResponseMessage(const YellowpageInfo2ResponseMessage&);
  YellowpageInfo2ResponseMessage& operator = (const YellowpageInfo2ResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageInfo2ResponseMessage";
  }
    
};

    
class LocationRequestMessage : public MessageBase {
public:
  LocationRequestMessage();
  virtual ~LocationRequestMessage();
  LocationRequestMessage(const LocationRequestMessage&);
  LocationRequestMessage& operator = (const LocationRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "LocationRequestMessage";
  }
    
  TPSTRING ip;  

  NullableDoubleMessage* latitude;  
  void create_latitude(const NullableDoubleMessage& item);
  void remove_latitude();
        
  NullableDoubleMessage* longitude;  
  void create_longitude(const NullableDoubleMessage& item);
  void remove_longitude();
        
  NullableNumberMessage* lac;  
  void create_lac(const NullableNumberMessage& item);
  void remove_lac();
        
  NullableNumberMessage* cid;  
  void create_cid(const NullableNumberMessage& item);
  void remove_cid();
        
  NullableNumberMessage* base_id;  
  void create_base_id(const NullableNumberMessage& item);
  void remove_base_id();
        
};

    
class LocationResponseMessage : public TPResponseMessage {
public:
  LocationResponseMessage();
  virtual ~LocationResponseMessage();
  LocationResponseMessage(const LocationResponseMessage&);
  LocationResponseMessage& operator = (const LocationResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "LocationResponseMessage";
  }
    
  TPSTRING country_code;  

  TPSTRING region;  

  TPSTRING city;  

  TPSTRING district;  

  TPSTRING address;  

  LocationMessage* loc;  
  void create_loc(const LocationMessage& item);
  void remove_loc();
        
  TPSTRING area_code;  

};

    
class PackageInfoRequestMessage : public MessageBase {
public:
  PackageInfoRequestMessage();
  virtual ~PackageInfoRequestMessage();
  PackageInfoRequestMessage(const PackageInfoRequestMessage&);
  PackageInfoRequestMessage& operator = (const PackageInfoRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PackageInfoRequestMessage";
  }
    
  TPSTRING platform;  

  TPSTRING app_name;  

  TPSTRING app_version;  

  TPSTRING locale;  

};

    
class PackageInfoMessage : public MessageBase {
public:
  PackageInfoMessage();
  virtual ~PackageInfoMessage();
  PackageInfoMessage(const PackageInfoMessage&);
  PackageInfoMessage& operator = (const PackageInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PackageInfoMessage";
  }
    
  TPSTRING id;  

  TPSTRING main_version;  

  TPSTRING main_url;  

  TPSTRING update_version;  

  TPSTRING update_url;  

};

    
class PackageInfoResponseMessage : public TPResponseMessage {
public:
  PackageInfoResponseMessage();
  virtual ~PackageInfoResponseMessage();
  PackageInfoResponseMessage(const PackageInfoResponseMessage&);
  PackageInfoResponseMessage& operator = (const PackageInfoResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PackageInfoResponseMessage";
  }
    
  VECTOR_T(PackageInfoMessage*) NONAME;  
  void insert_NONAME(const PackageInfoMessage& item);

};

    
class RecogResultMessage : public MessageBase {
public:
  RecogResultMessage();
  virtual ~RecogResultMessage();
  RecogResultMessage(const RecogResultMessage&);
  RecogResultMessage& operator = (const RecogResultMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RecogResultMessage";
  }
    
  TPSTRING content;  

  TPBOOLEAN pseudo;  

  TPSTRING sender;  

};

    
class SmsItemMessage : public MessageBase {
public:
  SmsItemMessage();
  virtual ~SmsItemMessage();
  SmsItemMessage(const SmsItemMessage&);
  SmsItemMessage& operator = (const SmsItemMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SmsItemMessage";
  }
    
  TPSTRING content;  

  TPSTRING service_center;  

  TPSTRING this_phone;  

  VECTOR_T(TPSTRING) other_phone;  

  TPNUMERIC date;  

  TPSTRING type;  

  TPBOOLEAN contact;  

  TPSTRING mode;  

  RecogResultMessage* recog_result;  
  void create_recog_result(const RecogResultMessage& item);
  void remove_recog_result();
        
};

    
class SmsRequestMessage : public MessageBase {
public:
  SmsRequestMessage();
  virtual ~SmsRequestMessage();
  SmsRequestMessage(const SmsRequestMessage&);
  SmsRequestMessage& operator = (const SmsRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SmsRequestMessage";
  }
    
  VECTOR_T(SmsItemMessage*) data;  
  void insert_data(const SmsItemMessage& item);

};

    
class SmsResponseMessage : public TPResponseMessage {
public:
  SmsResponseMessage();
  virtual ~SmsResponseMessage();
  SmsResponseMessage(const SmsResponseMessage&);
  SmsResponseMessage& operator = (const SmsResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SmsResponseMessage";
  }
    
};

    
class ContactItemMessage : public MessageBase {
public:
  ContactItemMessage();
  virtual ~ContactItemMessage();
  ContactItemMessage(const ContactItemMessage&);
  ContactItemMessage& operator = (const ContactItemMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ContactItemMessage";
  }
    
  TPSTRING name;  

  VECTOR_T(TPSTRING) phone;  

  TPSTRING birthday;  

  TPBOOLEAN isprivate;  

};

    
class ContactRequestMessage : public MessageBase {
public:
  ContactRequestMessage();
  virtual ~ContactRequestMessage();
  ContactRequestMessage(const ContactRequestMessage&);
  ContactRequestMessage& operator = (const ContactRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ContactRequestMessage";
  }
    
  VECTOR_T(ContactItemMessage*) NONAME;  
  void insert_NONAME(const ContactItemMessage& item);

};

    
class ContactResponseMessage : public TPResponseMessage {
public:
  ContactResponseMessage();
  virtual ~ContactResponseMessage();
  ContactResponseMessage(const ContactResponseMessage&);
  ContactResponseMessage& operator = (const ContactResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ContactResponseMessage";
  }
    
};

    
class SendVerificationRequestMessage : public MessageBase {
public:
  SendVerificationRequestMessage();
  virtual ~SendVerificationRequestMessage();
  SendVerificationRequestMessage(const SendVerificationRequestMessage&);
  SendVerificationRequestMessage& operator = (const SendVerificationRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SendVerificationRequestMessage";
  }
    
  TPSTRING account_name;  

  TPSTRING account_type;  

  TPSTRING type;  

};

    
class SendVerificationResponseMessage : public SecureResponseMessage {
public:
  SendVerificationResponseMessage();
  virtual ~SendVerificationResponseMessage();
  SendVerificationResponseMessage(const SendVerificationResponseMessage&);
  SendVerificationResponseMessage& operator = (const SendVerificationResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SendVerificationResponseMessage";
  }
    
  TPSTRING result;  

  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class RegisterRequestMessage : public MessageBase {
public:
  RegisterRequestMessage();
  virtual ~RegisterRequestMessage();
  RegisterRequestMessage(const RegisterRequestMessage&);
  RegisterRequestMessage& operator = (const RegisterRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RegisterRequestMessage";
  }
    
  TPSTRING account_name;  

  TPSTRING account_type;  

  TPSTRING verification;  

  TPSTRING password;  

};

    
class RegisterResponseMessage : public SecureResponseMessage {
public:
  RegisterResponseMessage();
  virtual ~RegisterResponseMessage();
  RegisterResponseMessage(const RegisterResponseMessage&);
  RegisterResponseMessage& operator = (const RegisterResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RegisterResponseMessage";
  }
    
  TPSTRING result;  

  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

  TPSTRING ticket;  

  TPSTRING access_token;  

};

    
class EncryptRegisterRequestMessage : public MessageBase {
public:
  EncryptRegisterRequestMessage();
  virtual ~EncryptRegisterRequestMessage();
  EncryptRegisterRequestMessage(const EncryptRegisterRequestMessage&);
  EncryptRegisterRequestMessage& operator = (const EncryptRegisterRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "EncryptRegisterRequestMessage";
  }
    
  TPSTRING account_name;  

  TPSTRING account_type;  

  TPSTRING verification;  

  TPSTRING password;  

};

    
class EncryptRegisterResponseMessage : public SecureResponseMessage {
public:
  EncryptRegisterResponseMessage();
  virtual ~EncryptRegisterResponseMessage();
  EncryptRegisterResponseMessage(const EncryptRegisterResponseMessage&);
  EncryptRegisterResponseMessage& operator = (const EncryptRegisterResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "EncryptRegisterResponseMessage";
  }
    
  TPSTRING result;  

  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

  TPSTRING ticket;  

  TPSTRING access_token;  

};

    
class LogoutRequestMessage : public MessageBase {
public:
  LogoutRequestMessage();
  virtual ~LogoutRequestMessage();
  LogoutRequestMessage(const LogoutRequestMessage&);
  LogoutRequestMessage& operator = (const LogoutRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "LogoutRequestMessage";
  }
    
};

    
class LogoutResponseMessage : public SecureResponseMessage {
public:
  LogoutResponseMessage();
  virtual ~LogoutResponseMessage();
  LogoutResponseMessage(const LogoutResponseMessage&);
  LogoutResponseMessage& operator = (const LogoutResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "LogoutResponseMessage";
  }
    
  TPSTRING err_msg;  

};

    
class BingCreateRequestMessage : public MessageBase {
public:
  BingCreateRequestMessage();
  virtual ~BingCreateRequestMessage();
  BingCreateRequestMessage(const BingCreateRequestMessage&);
  BingCreateRequestMessage& operator = (const BingCreateRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingCreateRequestMessage";
  }
    
};

    
class BingCreateResponseMessage : public SecureResponseMessage {
public:
  BingCreateResponseMessage();
  virtual ~BingCreateResponseMessage();
  BingCreateResponseMessage(const BingCreateResponseMessage&);
  BingCreateResponseMessage& operator = (const BingCreateResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingCreateResponseMessage";
  }
    
  TPSTRING result;  

  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class BingSendmsgRequestMessage : public MessageBase {
public:
  BingSendmsgRequestMessage();
  virtual ~BingSendmsgRequestMessage();
  BingSendmsgRequestMessage(const BingSendmsgRequestMessage&);
  BingSendmsgRequestMessage& operator = (const BingSendmsgRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingSendmsgRequestMessage";
  }
    
  TPSTRING msg_id;  

  TPSTRING sender_id;  

  TPSTRING text;  

  TPSTRING image_url;  

  TPNUMERIC timestamp;  

  TPSTRING sender_nick;  

  TPSTRING group_id;  

};

    
class BingSendmsgResponseMessage : public SecureResponseMessage {
public:
  BingSendmsgResponseMessage();
  virtual ~BingSendmsgResponseMessage();
  BingSendmsgResponseMessage(const BingSendmsgResponseMessage&);
  BingSendmsgResponseMessage& operator = (const BingSendmsgResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingSendmsgResponseMessage";
  }
    
  TPSTRING result;  

  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class BingProfileRequestMessage : public MessageBase {
public:
  BingProfileRequestMessage();
  virtual ~BingProfileRequestMessage();
  BingProfileRequestMessage(const BingProfileRequestMessage&);
  BingProfileRequestMessage& operator = (const BingProfileRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingProfileRequestMessage";
  }
    
};

    
class BingProfileMessage : public MessageBase {
public:
  BingProfileMessage();
  virtual ~BingProfileMessage();
  BingProfileMessage(const BingProfileMessage&);
  BingProfileMessage& operator = (const BingProfileMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingProfileMessage";
  }
    
  TPSTRING user_id;  

  TPSTRING nick_name;  

  TPSTRING description;  

  TPNUMERIC registered_time;  

  TPSTRING link;  

  TPSTRING image;  

};

    
class BingProfileResponseMessage : public SecureResponseMessage {
public:
  BingProfileResponseMessage();
  virtual ~BingProfileResponseMessage();
  BingProfileResponseMessage(const BingProfileResponseMessage&);
  BingProfileResponseMessage& operator = (const BingProfileResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingProfileResponseMessage";
  }
    
  BingProfileMessage* result;  
  void create_result(const BingProfileMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class BingReceivemsgRequestMessage : public MessageBase {
public:
  BingReceivemsgRequestMessage();
  virtual ~BingReceivemsgRequestMessage();
  BingReceivemsgRequestMessage(const BingReceivemsgRequestMessage&);
  BingReceivemsgRequestMessage& operator = (const BingReceivemsgRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingReceivemsgRequestMessage";
  }
    
};

    
class BingReceivemsgMessage : public MessageBase {
public:
  BingReceivemsgMessage();
  virtual ~BingReceivemsgMessage();
  BingReceivemsgMessage(const BingReceivemsgMessage&);
  BingReceivemsgMessage& operator = (const BingReceivemsgMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingReceivemsgMessage";
  }
    
  TPSTRING msg_id;  

  TPSTRING receiver_id;  

  TPSTRING text;  

  TPSTRING image_url;  

  TPNUMERIC timestamp;  

  TPSTRING group_id;  

  TPSTRING thumbnail_url;  

};

    
class BingReceivemsgResponseMessage : public SecureResponseMessage {
public:
  BingReceivemsgResponseMessage();
  virtual ~BingReceivemsgResponseMessage();
  BingReceivemsgResponseMessage(const BingReceivemsgResponseMessage&);
  BingReceivemsgResponseMessage& operator = (const BingReceivemsgResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingReceivemsgResponseMessage";
  }
    
  VECTOR_T(BingReceivemsgMessage*) result;  
  void insert_result(const BingReceivemsgMessage& item);

  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class BingAckmsgRequestMessage : public MessageBase {
public:
  BingAckmsgRequestMessage();
  virtual ~BingAckmsgRequestMessage();
  BingAckmsgRequestMessage(const BingAckmsgRequestMessage&);
  BingAckmsgRequestMessage& operator = (const BingAckmsgRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingAckmsgRequestMessage";
  }
    
  VECTOR_T(TPSTRING) msg_id_list;  

};

    
class BingAckmsgResponseMessage : public SecureResponseMessage {
public:
  BingAckmsgResponseMessage();
  virtual ~BingAckmsgResponseMessage();
  BingAckmsgResponseMessage(const BingAckmsgResponseMessage&);
  BingAckmsgResponseMessage& operator = (const BingAckmsgResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "BingAckmsgResponseMessage";
  }
    
  TPSTRING result;  

  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class MapClientIDRequestMessage : public MessageBase {
public:
  MapClientIDRequestMessage();
  virtual ~MapClientIDRequestMessage();
  MapClientIDRequestMessage(const MapClientIDRequestMessage&);
  MapClientIDRequestMessage& operator = (const MapClientIDRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "MapClientIDRequestMessage";
  }
    
  TPSTRING clientid;  

};

    
class MapClientIDResponseMessage : public TPResponseMessage {
public:
  MapClientIDResponseMessage();
  virtual ~MapClientIDResponseMessage();
  MapClientIDResponseMessage(const MapClientIDResponseMessage&);
  MapClientIDResponseMessage& operator = (const MapClientIDResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "MapClientIDResponseMessage";
  }
    
};

    
class ADRewardRequestMessage : public MessageBase {
public:
  ADRewardRequestMessage();
  virtual ~ADRewardRequestMessage();
  ADRewardRequestMessage(const ADRewardRequestMessage&);
  ADRewardRequestMessage& operator = (const ADRewardRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ADRewardRequestMessage";
  }
    
  TPSTRING ad;  

};

    
class ADRewardMessage : public MessageBase {
public:
  ADRewardMessage();
  virtual ~ADRewardMessage();
  ADRewardMessage(const ADRewardMessage&);
  ADRewardMessage& operator = (const ADRewardMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ADRewardMessage";
  }
    
  TPNUMERIC res_code;  

};

    
class ADRewardResponseMessage : public SecureResponseMessage {
public:
  ADRewardResponseMessage();
  virtual ~ADRewardResponseMessage();
  ADRewardResponseMessage(const ADRewardResponseMessage&);
  ADRewardResponseMessage& operator = (const ADRewardResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ADRewardResponseMessage";
  }
    
  ADRewardMessage* result;  
  void create_result(const ADRewardMessage& item);
  void remove_result();
        
};

    
class VoipC2CAccountRequestMessage : public MessageBase {
public:
  VoipC2CAccountRequestMessage();
  virtual ~VoipC2CAccountRequestMessage();
  VoipC2CAccountRequestMessage(const VoipC2CAccountRequestMessage&);
  VoipC2CAccountRequestMessage& operator = (const VoipC2CAccountRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipC2CAccountRequestMessage";
  }
    
  TPSTRING _channel_code;  

  TPNUMERIC _new_account;  

};

    
class VoipC2CAccountMessage : public MessageBase {
public:
  VoipC2CAccountMessage();
  virtual ~VoipC2CAccountMessage();
  VoipC2CAccountMessage(const VoipC2CAccountMessage&);
  VoipC2CAccountMessage& operator = (const VoipC2CAccountMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipC2CAccountMessage";
  }
    
  TPNUMERIC balance;  

  TPNUMERIC bonus_today;  

  TPNUMERIC deadline;  

  TPNUMERIC new_account;  

  TPNUMERIC share_time;  

  TPSTRING account_name;  

  TPSTRING user_type;  

  TPSTRING invitation_code;  

  TPSTRING invitation_received;  

  TPNUMERIC invitation_used;  

  TPSTRING qualification;  

  TPNUMERIC queue;  

  TPNUMERIC temporary_time;  

  TPNUMERIC register_time;  

};

    
class VoipC2CAccountResponseMessage : public SecureResponseMessage {
public:
  VoipC2CAccountResponseMessage();
  virtual ~VoipC2CAccountResponseMessage();
  VoipC2CAccountResponseMessage(const VoipC2CAccountResponseMessage&);
  VoipC2CAccountResponseMessage& operator = (const VoipC2CAccountResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipC2CAccountResponseMessage";
  }
    
  VoipC2CAccountMessage* result;  
  void create_result(const VoipC2CAccountMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class VoiGroupMessage : public MessageBase {
public:
  VoiGroupMessage();
  virtual ~VoiGroupMessage();
  VoiGroupMessage(const VoiGroupMessage&);
  VoiGroupMessage& operator = (const VoiGroupMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoiGroupMessage";
  }
    
  TPSTRING registrar;  

};

    
class RegisterGroupRequestMessage : public MessageBase {
public:
  RegisterGroupRequestMessage();
  virtual ~RegisterGroupRequestMessage();
  RegisterGroupRequestMessage(const RegisterGroupRequestMessage&);
  RegisterGroupRequestMessage& operator = (const RegisterGroupRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RegisterGroupRequestMessage";
  }
    
};

    
class RegisterGroupResponseMessage : public SecureResponseMessage {
public:
  RegisterGroupResponseMessage();
  virtual ~RegisterGroupResponseMessage();
  RegisterGroupResponseMessage(const RegisterGroupResponseMessage&);
  RegisterGroupResponseMessage& operator = (const RegisterGroupResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RegisterGroupResponseMessage";
  }
    
  VoiGroupMessage* result;  
  void create_result(const VoiGroupMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class VoipC2CRewardMessage : public MessageBase {
public:
  VoipC2CRewardMessage();
  virtual ~VoipC2CRewardMessage();
  VoipC2CRewardMessage(const VoipC2CRewardMessage&);
  VoipC2CRewardMessage& operator = (const VoipC2CRewardMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipC2CRewardMessage";
  }
    
  TPSTRING reward_type;  

  TPNUMERIC reward;  

};

    
class VoipRewardRequestMessage : public MessageBase {
public:
  VoipRewardRequestMessage();
  virtual ~VoipRewardRequestMessage();
  VoipRewardRequestMessage(const VoipRewardRequestMessage&);
  VoipRewardRequestMessage& operator = (const VoipRewardRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipRewardRequestMessage";
  }
    
};

    
class VoipRewardResponseMessage : public SecureResponseMessage {
public:
  VoipRewardResponseMessage();
  virtual ~VoipRewardResponseMessage();
  VoipRewardResponseMessage(const VoipRewardResponseMessage&);
  VoipRewardResponseMessage& operator = (const VoipRewardResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipRewardResponseMessage";
  }
    
  VoipC2CRewardMessage* result;  
  void create_result(const VoipC2CRewardMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class VoipInviteRewardMessage : public MessageBase {
public:
  VoipInviteRewardMessage();
  virtual ~VoipInviteRewardMessage();
  VoipInviteRewardMessage(const VoipInviteRewardMessage&);
  VoipInviteRewardMessage& operator = (const VoipInviteRewardMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipInviteRewardMessage";
  }
    
  TPNUMERIC reward;  

  TPSTRING msg;  

};

    
class VoipInvitecodeRequestMessage : public MessageBase {
public:
  VoipInvitecodeRequestMessage();
  virtual ~VoipInvitecodeRequestMessage();
  VoipInvitecodeRequestMessage(const VoipInvitecodeRequestMessage&);
  VoipInvitecodeRequestMessage& operator = (const VoipInvitecodeRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipInvitecodeRequestMessage";
  }
    
  TPSTRING invitation_code;  

};

    
class VoipInvitecodeResponseMessage : public SecureResponseMessage {
public:
  VoipInvitecodeResponseMessage();
  virtual ~VoipInvitecodeResponseMessage();
  VoipInvitecodeResponseMessage(const VoipInvitecodeResponseMessage&);
  VoipInvitecodeResponseMessage& operator = (const VoipInvitecodeResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipInvitecodeResponseMessage";
  }
    
  VoipInviteRewardMessage* result;  
  void create_result(const VoipInviteRewardMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class VoipCallRewardMessage : public MessageBase {
public:
  VoipCallRewardMessage();
  virtual ~VoipCallRewardMessage();
  VoipCallRewardMessage(const VoipCallRewardMessage&);
  VoipCallRewardMessage& operator = (const VoipCallRewardMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipCallRewardMessage";
  }
    
  TPNUMERIC reward;  

  TPSTRING comment;  

};

    
class VoipCallRewardRequestMessage : public MessageBase {
public:
  VoipCallRewardRequestMessage();
  virtual ~VoipCallRewardRequestMessage();
  VoipCallRewardRequestMessage(const VoipCallRewardRequestMessage&);
  VoipCallRewardRequestMessage& operator = (const VoipCallRewardRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipCallRewardRequestMessage";
  }
    
  TPSTRING call_id;  

  TPNUMERIC billsec;  

};

    
class VoipCallRewardResponseMessage : public SecureResponseMessage {
public:
  VoipCallRewardResponseMessage();
  virtual ~VoipCallRewardResponseMessage();
  VoipCallRewardResponseMessage(const VoipCallRewardResponseMessage&);
  VoipCallRewardResponseMessage& operator = (const VoipCallRewardResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipCallRewardResponseMessage";
  }
    
  VoipCallRewardMessage* result;  
  void create_result(const VoipCallRewardMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class C2CHistoryRequestMessage : public MessageBase {
public:
  C2CHistoryRequestMessage();
  virtual ~C2CHistoryRequestMessage();
  C2CHistoryRequestMessage(const C2CHistoryRequestMessage&);
  C2CHistoryRequestMessage& operator = (const C2CHistoryRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "C2CHistoryRequestMessage";
  }
    
  TPNUMERIC start_time;  

  TPNUMERIC max_number;  

  TPNUMERIC bonus_type;  

};

    
class C2CHistoryInfoMessage : public MessageBase {
public:
  C2CHistoryInfoMessage();
  virtual ~C2CHistoryInfoMessage();
  C2CHistoryInfoMessage(const C2CHistoryInfoMessage&);
  C2CHistoryInfoMessage& operator = (const C2CHistoryInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "C2CHistoryInfoMessage";
  }
    
  TPSTRING event_name;  

  TPNUMERIC bonus;  

  TPNUMERIC bonus_type;  

  TPNUMERIC datetime;  

  TPBOOLEAN pop;  

  TPSTRING msg;  

};

    
class C2CHistoryMessage : public MessageBase {
public:
  C2CHistoryMessage();
  virtual ~C2CHistoryMessage();
  C2CHistoryMessage(const C2CHistoryMessage&);
  C2CHistoryMessage& operator = (const C2CHistoryMessage&);
  
  virtual const TPSTRING get_type() const {
    return "C2CHistoryMessage";
  }
    
  VECTOR_T(C2CHistoryInfoMessage*) history;  
  void insert_history(const C2CHistoryInfoMessage& item);

};

    
class C2CHistoryResponseMessage : public SecureResponseMessage {
public:
  C2CHistoryResponseMessage();
  virtual ~C2CHistoryResponseMessage();
  C2CHistoryResponseMessage(const C2CHistoryResponseMessage&);
  C2CHistoryResponseMessage& operator = (const C2CHistoryResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "C2CHistoryResponseMessage";
  }
    
  C2CHistoryMessage* result;  
  void create_result(const C2CHistoryMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class VoipUserExistMessage : public MessageBase {
public:
  VoipUserExistMessage();
  virtual ~VoipUserExistMessage();
  VoipUserExistMessage(const VoipUserExistMessage&);
  VoipUserExistMessage& operator = (const VoipUserExistMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipUserExistMessage";
  }
    
  VECTOR_T(TPBOOLEAN) status;  

  TPNUMERIC sleep;  

};

    
class VoipUserExistRequestMessage : public MessageBase {
public:
  VoipUserExistRequestMessage();
  virtual ~VoipUserExistRequestMessage();
  VoipUserExistRequestMessage(const VoipUserExistRequestMessage&);
  VoipUserExistRequestMessage& operator = (const VoipUserExistRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipUserExistRequestMessage";
  }
    
  VECTOR_T(TPSTRING) user_account_list;  

};

    
class VoipUserExistResponseMessage : public SecureResponseMessage {
public:
  VoipUserExistResponseMessage();
  virtual ~VoipUserExistResponseMessage();
  VoipUserExistResponseMessage(const VoipUserExistResponseMessage&);
  VoipUserExistResponseMessage& operator = (const VoipUserExistResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipUserExistResponseMessage";
  }
    
  VoipUserExistMessage* result;  
  void create_result(const VoipUserExistMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class VoipFeedbackRequestMessage : public MessageBase {
public:
  VoipFeedbackRequestMessage();
  virtual ~VoipFeedbackRequestMessage();
  VoipFeedbackRequestMessage(const VoipFeedbackRequestMessage&);
  VoipFeedbackRequestMessage& operator = (const VoipFeedbackRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipFeedbackRequestMessage";
  }
    
  TPNUMERIC reason;  

  TPSTRING caller;  

  TPSTRING callee;  

  TPNUMERIC start_time;  

  TPSTRING net_type;  

  TPNUMERIC call_type;  

  TPSTRING phone_type;  

  TPSTRING os_name;  

  TPNUMERIC app_version;  

  TPNUMERIC duration;  

  TPSTRING carrieroperator;  

  TPSTRING channel_code;  

};

    
class VoipFeedbackResponseMessage : public SecureResponseMessage {
public:
  VoipFeedbackResponseMessage();
  virtual ~VoipFeedbackResponseMessage();
  VoipFeedbackResponseMessage(const VoipFeedbackResponseMessage&);
  VoipFeedbackResponseMessage& operator = (const VoipFeedbackResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipFeedbackResponseMessage";
  }
    
};

    
class HangupInviteRequestMessage : public MessageBase {
public:
  HangupInviteRequestMessage();
  virtual ~HangupInviteRequestMessage();
  HangupInviteRequestMessage(const HangupInviteRequestMessage&);
  HangupInviteRequestMessage& operator = (const HangupInviteRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "HangupInviteRequestMessage";
  }
    
  TPNUMERIC close_time;  

  TPSTRING target_phone;  

  TPSTRING target_name;  

  TPNUMERIC duration;  

  TPNUMERIC current_timestamp;  

  TPNUMERIC is_general_contact;  

};

    
class HangupInviteContentInfoMessage : public MessageBase {
public:
  HangupInviteContentInfoMessage();
  virtual ~HangupInviteContentInfoMessage();
  HangupInviteContentInfoMessage(const HangupInviteContentInfoMessage&);
  HangupInviteContentInfoMessage& operator = (const HangupInviteContentInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "HangupInviteContentInfoMessage";
  }
    
  TPSTRING ios_invite_icon;  

  TPSTRING ios_invite_icon_font;  

  TPSTRING android_invite_icon;  

  TPNUMERIC android_invite_icon_font;  

  TPNUMERIC share_type;  

  TPSTRING invite_title_text;  

  TPSTRING invite_title_content;  

  TPSTRING invite_first_title;  

  TPSTRING invite_second_title;  

  TPSTRING invite_left_button_text;  

  TPSTRING invite_right_button_text;  

  TPSTRING share_header_title;  

  TPSTRING share_title;  

  TPSTRING share_message;  

  TPSTRING share_url;  

  TPSTRING share_img_url;  

  VECTOR_T(TPSTRING) share_list;  

  TPSTRING share_target_phone;  

};

    
class HangupInviteInfoMessage : public MessageBase {
public:
  HangupInviteInfoMessage();
  virtual ~HangupInviteInfoMessage();
  HangupInviteInfoMessage(const HangupInviteInfoMessage&);
  HangupInviteInfoMessage& operator = (const HangupInviteInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "HangupInviteInfoMessage";
  }
    
  TPNUMERIC next_update_time;  

  HangupInviteContentInfoMessage* invite_content;  
  void create_invite_content(const HangupInviteContentInfoMessage& item);
  void remove_invite_content();
        
};

    
class HangupInviteResponseMessage : public SecureResponseMessage {
public:
  HangupInviteResponseMessage();
  virtual ~HangupInviteResponseMessage();
  HangupInviteResponseMessage(const HangupInviteResponseMessage&);
  HangupInviteResponseMessage& operator = (const HangupInviteResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "HangupInviteResponseMessage";
  }
    
  HangupInviteInfoMessage* result;  
  void create_result(const HangupInviteInfoMessage& item);
  void remove_result();
        
};

    
class VoipCalllogUploadRequestMessage : public MessageBase {
public:
  VoipCalllogUploadRequestMessage();
  virtual ~VoipCalllogUploadRequestMessage();
  VoipCalllogUploadRequestMessage(const VoipCalllogUploadRequestMessage&);
  VoipCalllogUploadRequestMessage& operator = (const VoipCalllogUploadRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipCalllogUploadRequestMessage";
  }
    
  TPSTRING version;  

  TPSTRING caller;  

  TPSTRING callee;  

  TPSTRING log;  

};

    
class VoipCalllogUploadMessage : public MessageBase {
public:
  VoipCalllogUploadMessage();
  virtual ~VoipCalllogUploadMessage();
  VoipCalllogUploadMessage(const VoipCalllogUploadMessage&);
  VoipCalllogUploadMessage& operator = (const VoipCalllogUploadMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipCalllogUploadMessage";
  }
    
};

    
class VoipCalllogUploadResponseMessage : public SecureResponseMessage {
public:
  VoipCalllogUploadResponseMessage();
  virtual ~VoipCalllogUploadResponseMessage();
  VoipCalllogUploadResponseMessage(const VoipCalllogUploadResponseMessage&);
  VoipCalllogUploadResponseMessage& operator = (const VoipCalllogUploadResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipCalllogUploadResponseMessage";
  }
    
  VoipCalllogUploadMessage* result;  
  void create_result(const VoipCalllogUploadMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class VoipCallStatUploadRequestMessage : public MessageBase {
public:
  VoipCallStatUploadRequestMessage();
  virtual ~VoipCallStatUploadRequestMessage();
  VoipCallStatUploadRequestMessage(const VoipCallStatUploadRequestMessage&);
  VoipCallStatUploadRequestMessage& operator = (const VoipCallStatUploadRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipCallStatUploadRequestMessage";
  }
    
  TPSTRING content;  

};

    
class VoipCallStatUploadMessage : public MessageBase {
public:
  VoipCallStatUploadMessage();
  virtual ~VoipCallStatUploadMessage();
  VoipCallStatUploadMessage(const VoipCallStatUploadMessage&);
  VoipCallStatUploadMessage& operator = (const VoipCallStatUploadMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipCallStatUploadMessage";
  }
    
};

    
class VoipCallStatUploadResponseMessage : public SecureResponseMessage {
public:
  VoipCallStatUploadResponseMessage();
  virtual ~VoipCallStatUploadResponseMessage();
  VoipCallStatUploadResponseMessage(const VoipCallStatUploadResponseMessage&);
  VoipCallStatUploadResponseMessage& operator = (const VoipCallStatUploadResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipCallStatUploadResponseMessage";
  }
    
  VoipCallStatUploadMessage* result;  
  void create_result(const VoipCallStatUploadMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class SmsSyncRequestMessage : public MessageBase {
public:
  SmsSyncRequestMessage();
  virtual ~SmsSyncRequestMessage();
  SmsSyncRequestMessage(const SmsSyncRequestMessage&);
  SmsSyncRequestMessage& operator = (const SmsSyncRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SmsSyncRequestMessage";
  }
    
  TPSTRING sms;  

};

    
class SmsSyncResponseMessage : public TPResponseMessage {
public:
  SmsSyncResponseMessage();
  virtual ~SmsSyncResponseMessage();
  SmsSyncResponseMessage(const SmsSyncResponseMessage&);
  SmsSyncResponseMessage& operator = (const SmsSyncResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SmsSyncResponseMessage";
  }
    
  VECTOR_T(TPNUMERIC) actions;  

  TPSTRING sms;  

  TPSTRING todo_key;  

  TPSTRING todo_title;  

  TPSTRING todo_content;  

  TPSTRING todo_iconPath;  

  TPSTRING todo_clickUrl;  

  TPSTRING todo_indicatorText;  

  TPSTRING notification_url;  

  TPSTRING notification_msg;  

  TPSTRING personal;  

  TPNUMERIC notify_time;  

  TPSTRING message_new;  

};

    
class YellowpageSearchRequestMessage : public MessageBase {
public:
  YellowpageSearchRequestMessage();
  virtual ~YellowpageSearchRequestMessage();
  YellowpageSearchRequestMessage(const YellowpageSearchRequestMessage&);
  YellowpageSearchRequestMessage& operator = (const YellowpageSearchRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageSearchRequestMessage";
  }
    
  TPSTRING input;  

  TPDOUBLE latitude;  

  TPDOUBLE longitude;  

  TPSTRING city;  

  TPNUMERIC count;  

  TPSTRING ref;  

  TPNUMERIC lac;  

  TPNUMERIC cid;  

  TPSTRING captcha_id;  

  TPSTRING captcha;  

  TPSTRING client_version;  

  TPSTRING zip_version;  

  TPSTRING api_level;  

};

    
class YellowpageSearchCouponInfoMessage : public MessageBase {
public:
  YellowpageSearchCouponInfoMessage();
  virtual ~YellowpageSearchCouponInfoMessage();
  YellowpageSearchCouponInfoMessage(const YellowpageSearchCouponInfoMessage&);
  YellowpageSearchCouponInfoMessage& operator = (const YellowpageSearchCouponInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageSearchCouponInfoMessage";
  }
    
  TPSTRING source;  

  TPSTRING info;  

  TPSTRING pic;  

  TPSTRING title;  

  TPSTRING external_link;  

  TPSTRING coupon_link;  

};

    
class YellowpageSearchHitInfoMessage : public MessageBase {
public:
  YellowpageSearchHitInfoMessage();
  virtual ~YellowpageSearchHitInfoMessage();
  YellowpageSearchHitInfoMessage(const YellowpageSearchHitInfoMessage&);
  YellowpageSearchHitInfoMessage& operator = (const YellowpageSearchHitInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageSearchHitInfoMessage";
  }
    
  TPSTRING field;  

  TPNUMERIC begin;  

  TPNUMERIC end;  

  TPNUMERIC index;  

};

    
class YellowpageSearchDeliveryInfoMessage : public MessageBase {
public:
  YellowpageSearchDeliveryInfoMessage();
  virtual ~YellowpageSearchDeliveryInfoMessage();
  YellowpageSearchDeliveryInfoMessage(const YellowpageSearchDeliveryInfoMessage&);
  YellowpageSearchDeliveryInfoMessage& operator = (const YellowpageSearchDeliveryInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageSearchDeliveryInfoMessage";
  }
    
  TPNUMERIC delivery_charges;  

  TPNUMERIC delivery_starting_point;  

  TPNUMERIC free_delivery_charges;  

};

    
class YellowpageSearchExternalShopInfoMessage : public MessageBase {
public:
  YellowpageSearchExternalShopInfoMessage();
  virtual ~YellowpageSearchExternalShopInfoMessage();
  YellowpageSearchExternalShopInfoMessage(const YellowpageSearchExternalShopInfoMessage&);
  YellowpageSearchExternalShopInfoMessage& operator = (const YellowpageSearchExternalShopInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageSearchExternalShopInfoMessage";
  }
    
  TPSTRING source;  

  TPSTRING source_id;  

  TPSTRING external_link;  

  YellowpageSearchDeliveryInfoMessage* delivery;  
  void create_delivery(const YellowpageSearchDeliveryInfoMessage& item);
  void remove_delivery();
        
  TPDOUBLE score;  

  TPNUMERIC avg_price;  

  VECTOR_T(TPSTRING) categories;  

  VECTOR_T(TPSTRING) regions;  

  TPNUMERIC service_grade;  

  TPNUMERIC product_grade;  

  TPNUMERIC decoration_grade;  

};

    
class YellowpageSearchShopInfoMessage : public MessageBase {
public:
  YellowpageSearchShopInfoMessage();
  virtual ~YellowpageSearchShopInfoMessage();
  YellowpageSearchShopInfoMessage(const YellowpageSearchShopInfoMessage&);
  YellowpageSearchShopInfoMessage& operator = (const YellowpageSearchShopInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageSearchShopInfoMessage";
  }
    
  TPSTRING id;  

  TPSTRING name;  

  TPSTRING _short;  

  VECTOR_T(TPSTRING) phones;  

  TPNUMERIC branches_count;  

  TPSTRING address;  

  TPNUMERIC distance;  

  VECTOR_T(YellowpageSearchCouponInfoMessage*) coupon;  
  void insert_coupon(const YellowpageSearchCouponInfoMessage& item);

  VECTOR_T(YellowpageSearchCouponInfoMessage*) coupons;  
  void insert_coupons(const YellowpageSearchCouponInfoMessage& item);

  TPBOOLEAN has_coupon;  

  VECTOR_T(YellowpageSearchHitInfoMessage*) hit_info;  
  void insert_hit_info(const YellowpageSearchHitInfoMessage& item);

  YellowpageSearchExternalShopInfoMessage* external_info;  
  void create_external_info(const YellowpageSearchExternalShopInfoMessage& item);
  void remove_external_info();
        
  TPSTRING shop_logo;  

  TPSTRING website;  

  TPSTRING link;  

  TPSTRING external_link;  

};

    
class YellowpageSearchServiceInfoMessage : public MessageBase {
public:
  YellowpageSearchServiceInfoMessage();
  virtual ~YellowpageSearchServiceInfoMessage();
  YellowpageSearchServiceInfoMessage(const YellowpageSearchServiceInfoMessage&);
  YellowpageSearchServiceInfoMessage& operator = (const YellowpageSearchServiceInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageSearchServiceInfoMessage";
  }
    
  TPSTRING id;  

  TPSTRING title;  

  TPSTRING sub_title;  

  TPSTRING icon;  

  TPSTRING link;  

  TPSTRING external_link;  

};

    
class YellowpageSearchResponseMessage : public TPResponseMessage {
public:
  YellowpageSearchResponseMessage();
  virtual ~YellowpageSearchResponseMessage();
  YellowpageSearchResponseMessage(const YellowpageSearchResponseMessage&);
  YellowpageSearchResponseMessage& operator = (const YellowpageSearchResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageSearchResponseMessage";
  }
    
  TPSTRING ref;  

  VECTOR_T(YellowpageSearchShopInfoMessage*) res;  
  void insert_res(const YellowpageSearchShopInfoMessage& item);

  VECTOR_T(YellowpageSearchServiceInfoMessage*) services;  
  void insert_services(const YellowpageSearchServiceInfoMessage& item);

  LocationMessage* loc;  
  void create_loc(const LocationMessage& item);
  void remove_loc();
        
  TPSTRING area_code;  

};

    
class YellowpageCaptchaRequestMessage : public MessageBase {
public:
  YellowpageCaptchaRequestMessage();
  virtual ~YellowpageCaptchaRequestMessage();
  YellowpageCaptchaRequestMessage(const YellowpageCaptchaRequestMessage&);
  YellowpageCaptchaRequestMessage& operator = (const YellowpageCaptchaRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageCaptchaRequestMessage";
  }
    
};

    
class YellowpageCaptchaMessage : public MessageBase {
public:
  YellowpageCaptchaMessage();
  virtual ~YellowpageCaptchaMessage();
  YellowpageCaptchaMessage(const YellowpageCaptchaMessage&);
  YellowpageCaptchaMessage& operator = (const YellowpageCaptchaMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageCaptchaMessage";
  }
    
  TPSTRING captcha_id;  

  TPSTRING captcha_url;  

};

    
class YellowpageCaptchaResponseMessage : public TPResponseMessage {
public:
  YellowpageCaptchaResponseMessage();
  virtual ~YellowpageCaptchaResponseMessage();
  YellowpageCaptchaResponseMessage(const YellowpageCaptchaResponseMessage&);
  YellowpageCaptchaResponseMessage& operator = (const YellowpageCaptchaResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "YellowpageCaptchaResponseMessage";
  }
    
  TPSTRING error_msg;  

  YellowpageCaptchaMessage* result;  
  void create_result(const YellowpageCaptchaMessage& item);
  void remove_result();
        
};

    
class TaskBonusRequestMessage : public MessageBase {
public:
  TaskBonusRequestMessage();
  virtual ~TaskBonusRequestMessage();
  TaskBonusRequestMessage(const TaskBonusRequestMessage&);
  TaskBonusRequestMessage& operator = (const TaskBonusRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "TaskBonusRequestMessage";
  }
    
  TPNUMERIC _event_id;  

  TPNUMERIC _type;  

};

    
class TaskBonusMessage : public MessageBase {
public:
  TaskBonusMessage();
  virtual ~TaskBonusMessage();
  TaskBonusMessage(const TaskBonusMessage&);
  TaskBonusMessage& operator = (const TaskBonusMessage&);
  
  virtual const TPSTRING get_type() const {
    return "TaskBonusMessage";
  }
    
  TPNUMERIC bonus;  

  TPBOOLEAN qualification;  

  TPBOOLEAN finish;  

  TPBOOLEAN today_finish;  

  TPNUMERIC timestamp;  

};

    
class TaskBonusResponseMessage : public SecureResponseMessage {
public:
  TaskBonusResponseMessage();
  virtual ~TaskBonusResponseMessage();
  TaskBonusResponseMessage(const TaskBonusResponseMessage&);
  TaskBonusResponseMessage& operator = (const TaskBonusResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "TaskBonusResponseMessage";
  }
    
  TaskBonusMessage* result;  
  void create_result(const TaskBonusMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class ExchangeTrafficRequestMessage : public MessageBase {
public:
  ExchangeTrafficRequestMessage();
  virtual ~ExchangeTrafficRequestMessage();
  ExchangeTrafficRequestMessage(const ExchangeTrafficRequestMessage&);
  ExchangeTrafficRequestMessage& operator = (const ExchangeTrafficRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ExchangeTrafficRequestMessage";
  }
    
  TPSTRING nick_name;  

  TPNUMERIC flow;  

};

    
class ExchangeTrafficMessage : public MessageBase {
public:
  ExchangeTrafficMessage();
  virtual ~ExchangeTrafficMessage();
  ExchangeTrafficMessage(const ExchangeTrafficMessage&);
  ExchangeTrafficMessage& operator = (const ExchangeTrafficMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ExchangeTrafficMessage";
  }
    
  TPNUMERIC exchange;  

};

    
class ExchangeTrafficResponseMessage : public SecureResponseMessage {
public:
  ExchangeTrafficResponseMessage();
  virtual ~ExchangeTrafficResponseMessage();
  ExchangeTrafficResponseMessage(const ExchangeTrafficResponseMessage&);
  ExchangeTrafficResponseMessage& operator = (const ExchangeTrafficResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ExchangeTrafficResponseMessage";
  }
    
  ExchangeTrafficMessage* result;  
  void create_result(const ExchangeTrafficMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class TrafficNewMessage : public MessageBase {
public:
  TrafficNewMessage();
  virtual ~TrafficNewMessage();
  TrafficNewMessage(const TrafficNewMessage&);
  TrafficNewMessage& operator = (const TrafficNewMessage&);
  
  virtual const TPSTRING get_type() const {
    return "TrafficNewMessage";
  }
    
  TPNUMERIC traffic_new;  

};

    
class TrafficNewRequestMessage : public MessageBase {
public:
  TrafficNewRequestMessage();
  virtual ~TrafficNewRequestMessage();
  TrafficNewRequestMessage(const TrafficNewRequestMessage&);
  TrafficNewRequestMessage& operator = (const TrafficNewRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "TrafficNewRequestMessage";
  }
    
};

    
class TrafficNewResponseMessage : public SecureResponseMessage {
public:
  TrafficNewResponseMessage();
  virtual ~TrafficNewResponseMessage();
  TrafficNewResponseMessage(const TrafficNewResponseMessage&);
  TrafficNewResponseMessage& operator = (const TrafficNewResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "TrafficNewResponseMessage";
  }
    
  TrafficNewMessage* result;  
  void create_result(const TrafficNewMessage& item);
  void remove_result();
        
};

    
class GetProfileRequestMessage : public MessageBase {
public:
  GetProfileRequestMessage();
  virtual ~GetProfileRequestMessage();
  GetProfileRequestMessage(const GetProfileRequestMessage&);
  GetProfileRequestMessage& operator = (const GetProfileRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "GetProfileRequestMessage";
  }
    
};

    
class GetProfileMessage : public MessageBase {
public:
  GetProfileMessage();
  virtual ~GetProfileMessage();
  GetProfileMessage(const GetProfileMessage&);
  GetProfileMessage& operator = (const GetProfileMessage&);
  
  virtual const TPSTRING get_type() const {
    return "GetProfileMessage";
  }
    
  TPNUMERIC success;  

  TPSTRING photo_uri;  

  TPNUMERIC photo_type;  

  TPNUMERIC gender;  

};

    
class GetProfileResponseMessage : public SecureResponseMessage {
public:
  GetProfileResponseMessage();
  virtual ~GetProfileResponseMessage();
  GetProfileResponseMessage(const GetProfileResponseMessage&);
  GetProfileResponseMessage& operator = (const GetProfileResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "GetProfileResponseMessage";
  }
    
  GetProfileMessage* result;  
  void create_result(const GetProfileMessage& item);
  void remove_result();
        
};

    
class SetProfileRequestMessage : public MessageBase {
public:
  SetProfileRequestMessage();
  virtual ~SetProfileRequestMessage();
  SetProfileRequestMessage(const SetProfileRequestMessage&);
  SetProfileRequestMessage& operator = (const SetProfileRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SetProfileRequestMessage";
  }
    
  TPSTRING photo_uri;  

  TPNUMERIC photo_type;  

  TPNUMERIC gender;  

};

    
class SetProfileMessage : public MessageBase {
public:
  SetProfileMessage();
  virtual ~SetProfileMessage();
  SetProfileMessage(const SetProfileMessage&);
  SetProfileMessage& operator = (const SetProfileMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SetProfileMessage";
  }
    
  TPNUMERIC success;  

  TPSTRING photo_uri;  

  TPNUMERIC photo_type;  

  TPNUMERIC gender;  

};

    
class SetProfileResponseMessage : public SecureResponseMessage {
public:
  SetProfileResponseMessage();
  virtual ~SetProfileResponseMessage();
  SetProfileResponseMessage(const SetProfileResponseMessage&);
  SetProfileResponseMessage& operator = (const SetProfileResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SetProfileResponseMessage";
  }
    
  SetProfileMessage* result;  
  void create_result(const SetProfileMessage& item);
  void remove_result();
        
};

    
class ParticipateVoipOverseaRequestMessage : public MessageBase {
public:
  ParticipateVoipOverseaRequestMessage();
  virtual ~ParticipateVoipOverseaRequestMessage();
  ParticipateVoipOverseaRequestMessage(const ParticipateVoipOverseaRequestMessage&);
  ParticipateVoipOverseaRequestMessage& operator = (const ParticipateVoipOverseaRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ParticipateVoipOverseaRequestMessage";
  }
    
  TPSTRING phone;  

};

    
class ParticipateVoipOverseaResponseMessage : public SecureResponseMessage {
public:
  ParticipateVoipOverseaResponseMessage();
  virtual ~ParticipateVoipOverseaResponseMessage();
  ParticipateVoipOverseaResponseMessage(const ParticipateVoipOverseaResponseMessage&);
  ParticipateVoipOverseaResponseMessage& operator = (const ParticipateVoipOverseaResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ParticipateVoipOverseaResponseMessage";
  }
    
  TPBOOLEAN answer;  

};

    
class IfParticipateVoipOverseaRequestMessage : public MessageBase {
public:
  IfParticipateVoipOverseaRequestMessage();
  virtual ~IfParticipateVoipOverseaRequestMessage();
  IfParticipateVoipOverseaRequestMessage(const IfParticipateVoipOverseaRequestMessage&);
  IfParticipateVoipOverseaRequestMessage& operator = (const IfParticipateVoipOverseaRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "IfParticipateVoipOverseaRequestMessage";
  }
    
  TPSTRING phone;  

};

    
class IfParticipateVoipOverseaResponseMessage : public SecureResponseMessage {
public:
  IfParticipateVoipOverseaResponseMessage();
  virtual ~IfParticipateVoipOverseaResponseMessage();
  IfParticipateVoipOverseaResponseMessage(const IfParticipateVoipOverseaResponseMessage&);
  IfParticipateVoipOverseaResponseMessage& operator = (const IfParticipateVoipOverseaResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "IfParticipateVoipOverseaResponseMessage";
  }
    
  TPBOOLEAN answer;  

};

    
class AdMessage : public MessageBase {
public:
  AdMessage();
  virtual ~AdMessage();
  AdMessage(const AdMessage&);
  AdMessage& operator = (const AdMessage&);
  
  virtual const TPSTRING get_type() const {
    return "AdMessage";
  }
    
  TPSTRING ad_id;  

  TPSTRING title;  

  TPSTRING desc;  

  TPSTRING brand;  

  TPSTRING curl;  

  TPSTRING surl;  

  TPSTRING edurl;  

  TPSTRING material;  

  TPBOOLEAN da;  

  TPSTRING src;  

  TPSTRING at;  

  TPNUMERIC w;  

  TPNUMERIC h;  

  TPSTRING turl;  

  TPSTRING ttype;  

  TPSTRING tstep;  

  TPSTRING rdesc;  

  TPSTRING checkcode;  

  TPNUMERIC dtime;  

  TPNUMERIC etime;  

  TPBOOLEAN ec;  

  TPSTRING reserved;  

  TPSTRING clk_url;  

  VECTOR_T(TPSTRING) clk_monitor_url;  

  VECTOR_T(TPSTRING) ed_monitor_url;  

  VECTOR_T(TPSTRING) transform_monitor_url;  

};

    
class AdPackageMessage : public MessageBase {
public:
  AdPackageMessage();
  virtual ~AdPackageMessage();
  AdPackageMessage(const AdPackageMessage&);
  AdPackageMessage& operator = (const AdPackageMessage&);
  
  virtual const TPSTRING get_type() const {
    return "AdPackageMessage";
  }
    
  TPNUMERIC w;  

  TPNUMERIC h;  

  TPNUMERIC adn;  

  VECTOR_T(AdMessage*) ads;  
  void insert_ads(const AdMessage& item);

  TPSTRING tu;  

  TPSTRING s;  

  TPBOOLEAN idws;  

  TPNUMERIC wtime;  

};

    
class CommercialAdRequestMessage : public MessageBase {
public:
  CommercialAdRequestMessage();
  virtual ~CommercialAdRequestMessage();
  CommercialAdRequestMessage(const CommercialAdRequestMessage&);
  CommercialAdRequestMessage& operator = (const CommercialAdRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CommercialAdRequestMessage";
  }
    
  TPSTRING ch;  

  TPSTRING v;  

  TPNUMERIC prt;  

  TPSTRING at;  

  TPSTRING tu;  

  TPNUMERIC adn;  

  TPSTRING adclass;  

  TPSTRING nt;  

  TPSTRING rt;  

  TPNUMERIC w;  

  TPNUMERIC h;  

  TPSTRING city;  

  TPSTRING addr;  

  TPDOUBLE longtitude;  

  TPDOUBLE latitude;  

  TPSTRING other_phone;  

  TPSTRING call_type;  

  TPSTRING vt;  

  TPNUMERIC ito;  

  TPNUMERIC et;  

  TPBOOLEAN open_free_call;  

  TPSTRING contactname;  

};

    
class CommercialAdResponseMessage : public TPResponseMessage {
public:
  CommercialAdResponseMessage();
  virtual ~CommercialAdResponseMessage();
  CommercialAdResponseMessage(const CommercialAdResponseMessage&);
  CommercialAdResponseMessage& operator = (const CommercialAdResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CommercialAdResponseMessage";
  }
    
  VECTOR_T(AdPackageMessage*) ad;  
  void insert_ad(const AdPackageMessage& item);

};

    
class CommercialWebRequestMessage : public MessageBase {
public:
  CommercialWebRequestMessage();
  virtual ~CommercialWebRequestMessage();
  CommercialWebRequestMessage(const CommercialWebRequestMessage&);
  CommercialWebRequestMessage& operator = (const CommercialWebRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CommercialWebRequestMessage";
  }
    
  TPSTRING ch;  

  TPSTRING v;  

  TPNUMERIC prt;  

  TPSTRING at;  

  TPSTRING tu;  

  TPNUMERIC adn;  

  TPSTRING adclass;  

  TPSTRING nt;  

  TPSTRING rt;  

  TPNUMERIC w;  

  TPNUMERIC h;  

  TPSTRING city;  

  TPSTRING addr;  

  TPDOUBLE longtitude;  

  TPDOUBLE latitude;  

  TPSTRING other_phone;  

  TPSTRING call_type;  

  TPSTRING vt;  

  TPNUMERIC ito;  

  TPNUMERIC et;  

  TPBOOLEAN open_free_call;  

  TPSTRING contactname;  

  TPSTRING ck;  

  TPNUMERIC pf;  

};

    
class CommercialWebResourceMessage : public MessageBase {
public:
  CommercialWebResourceMessage();
  virtual ~CommercialWebResourceMessage();
  CommercialWebResourceMessage(const CommercialWebResourceMessage&);
  CommercialWebResourceMessage& operator = (const CommercialWebResourceMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CommercialWebResourceMessage";
  }
    
  TPSTRING dest;  

  TPSTRING src;  

  TPNUMERIC ver;  

};

    
class CommercialConfigMessage : public MessageBase {
public:
  CommercialConfigMessage();
  virtual ~CommercialConfigMessage();
  CommercialConfigMessage(const CommercialConfigMessage&);
  CommercialConfigMessage& operator = (const CommercialConfigMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CommercialConfigMessage";
  }
    
  TPBOOLEAN idws;  

  TPNUMERIC wtime;  

  TPNUMERIC etime;  

};

    
class CommercialWebResponseMessage : public TPResponseMessage {
public:
  CommercialWebResponseMessage();
  virtual ~CommercialWebResponseMessage();
  CommercialWebResponseMessage(const CommercialWebResponseMessage&);
  CommercialWebResponseMessage& operator = (const CommercialWebResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CommercialWebResponseMessage";
  }
    
  TPSTRING page;  

  VECTOR_T(CommercialWebResourceMessage*) resource;  
  void insert_resource(const CommercialWebResourceMessage& item);

  CommercialConfigMessage* conf;  
  void create_conf(const CommercialConfigMessage& item);
  void remove_conf();
        
};

    
class CommercialStatRequestMessage : public MessageBase {
public:
  CommercialStatRequestMessage();
  virtual ~CommercialStatRequestMessage();
  CommercialStatRequestMessage(const CommercialStatRequestMessage&);
  CommercialStatRequestMessage& operator = (const CommercialStatRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CommercialStatRequestMessage";
  }
    
  TPNUMERIC type;  

  TPSTRING tu;  

  TPSTRING st;  

  TPSTRING ch;  

  TPSTRING v;  

  TPSTRING nt;  

  TPSTRING pst;  

  TPNUMERIC product;  

};

    
class CommercialStatResponseMessage : public TPResponseMessage {
public:
  CommercialStatResponseMessage();
  virtual ~CommercialStatResponseMessage();
  CommercialStatResponseMessage(const CommercialStatResponseMessage&);
  CommercialStatResponseMessage& operator = (const CommercialStatResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "CommercialStatResponseMessage";
  }
    
  TPSTRING message;  

  TPBOOLEAN success;  

};

    
class AccountMessage : public MessageBase {
public:
  AccountMessage();
  virtual ~AccountMessage();
  AccountMessage(const AccountMessage&);
  AccountMessage& operator = (const AccountMessage&);
  
  virtual const TPSTRING get_type() const {
    return "AccountMessage";
  }
    
  TPNUMERIC saved;  

  TPNUMERIC coins;  

  TPNUMERIC bytes;  

  TPNUMERIC minutes;  

  TPNUMERIC cards;  

  TPNUMERIC server_time;  

  TPNUMERIC vip_expired;  

  TPBOOLEAN is_card_user;  

  TPDOUBLE bytes_f;  

};

    
class AccountInfoRequestMessage : public MessageBase {
public:
  AccountInfoRequestMessage();
  virtual ~AccountInfoRequestMessage();
  AccountInfoRequestMessage(const AccountInfoRequestMessage&);
  AccountInfoRequestMessage& operator = (const AccountInfoRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "AccountInfoRequestMessage";
  }
    
};

    
class AccountInfoResponseMessage : public SecureResponseMessage {
public:
  AccountInfoResponseMessage();
  virtual ~AccountInfoResponseMessage();
  AccountInfoResponseMessage(const AccountInfoResponseMessage&);
  AccountInfoResponseMessage& operator = (const AccountInfoResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "AccountInfoResponseMessage";
  }
    
  AccountMessage* result;  
  void create_result(const AccountMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class RedeemExchangeRequestMessage : public MessageBase {
public:
  RedeemExchangeRequestMessage();
  virtual ~RedeemExchangeRequestMessage();
  RedeemExchangeRequestMessage(const RedeemExchangeRequestMessage&);
  RedeemExchangeRequestMessage& operator = (const RedeemExchangeRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RedeemExchangeRequestMessage";
  }
    
  TPSTRING redeem_code;  

};

    
class RedeemExchangeResultMessage : public MessageBase {
public:
  RedeemExchangeResultMessage();
  virtual ~RedeemExchangeResultMessage();
  RedeemExchangeResultMessage(const RedeemExchangeResultMessage&);
  RedeemExchangeResultMessage& operator = (const RedeemExchangeResultMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RedeemExchangeResultMessage";
  }
    
  TPSTRING title;  

};

    
class RedeemExchangeResponseMessage : public SecureResponseMessage {
public:
  RedeemExchangeResponseMessage();
  virtual ~RedeemExchangeResponseMessage();
  RedeemExchangeResponseMessage(const RedeemExchangeResponseMessage&);
  RedeemExchangeResponseMessage& operator = (const RedeemExchangeResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RedeemExchangeResponseMessage";
  }
    
  RedeemExchangeResultMessage* result;  
  void create_result(const RedeemExchangeResultMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class ShareQueryRequestMessage : public MessageBase {
public:
  ShareQueryRequestMessage();
  virtual ~ShareQueryRequestMessage();
  ShareQueryRequestMessage(const ShareQueryRequestMessage&);
  ShareQueryRequestMessage& operator = (const ShareQueryRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ShareQueryRequestMessage";
  }
    
  TPSTRING params;  

};

    
class ShareMessage : public MessageBase {
public:
  ShareMessage();
  virtual ~ShareMessage();
  ShareMessage(const ShareMessage&);
  ShareMessage& operator = (const ShareMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ShareMessage";
  }
    
  TPSTRING instant_bonus_type;  

  TPSTRING instant_bonus_quantity;  

  TPSTRING share_bonus_quantity;  

  TPSTRING share_bonus_hint;  

  TPSTRING share_bonus_content;  

  TPNUMERIC next_update_time;  

  TPSTRING share_message;  

  TPSTRING share_title;  

  TPSTRING share_image_url;  

  TPSTRING share_url;  

  TPSTRING share_button_title;  

  TPSTRING box_share_title;  

  VECTOR_T(TPSTRING) box_share_list;  

  TPSTRING ui_version;  

  TPSTRING package_id;  

};

    
class ShareQueryResponseMessage : public SecureResponseMessage {
public:
  ShareQueryResponseMessage();
  virtual ~ShareQueryResponseMessage();
  ShareQueryResponseMessage(const ShareQueryResponseMessage&);
  ShareQueryResponseMessage& operator = (const ShareQueryResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ShareQueryResponseMessage";
  }
    
  ShareMessage* result;  
  void create_result(const ShareMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class AppDownloadAwardRequestMessage : public MessageBase {
public:
  AppDownloadAwardRequestMessage();
  virtual ~AppDownloadAwardRequestMessage();
  AppDownloadAwardRequestMessage(const AppDownloadAwardRequestMessage&);
  AppDownloadAwardRequestMessage& operator = (const AppDownloadAwardRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "AppDownloadAwardRequestMessage";
  }
    
  TPSTRING app_id;  

  TPSTRING phone;  

};

    
class AppDownloadMessage : public MessageBase {
public:
  AppDownloadMessage();
  virtual ~AppDownloadMessage();
  AppDownloadMessage(const AppDownloadMessage&);
  AppDownloadMessage& operator = (const AppDownloadMessage&);
  
  virtual const TPSTRING get_type() const {
    return "AppDownloadMessage";
  }
    
  TPNUMERIC status;  

};

    
class AppDownloadAwardResponseMessage : public SecureResponseMessage {
public:
  AppDownloadAwardResponseMessage();
  virtual ~AppDownloadAwardResponseMessage();
  AppDownloadAwardResponseMessage(const AppDownloadAwardResponseMessage&);
  AppDownloadAwardResponseMessage& operator = (const AppDownloadAwardResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "AppDownloadAwardResponseMessage";
  }
    
  AppDownloadMessage* result;  
  void create_result(const AppDownloadMessage& item);
  void remove_result();
        
};

    
class HasJoinWechatPublicRequestMessage : public MessageBase {
public:
  HasJoinWechatPublicRequestMessage();
  virtual ~HasJoinWechatPublicRequestMessage();
  HasJoinWechatPublicRequestMessage(const HasJoinWechatPublicRequestMessage&);
  HasJoinWechatPublicRequestMessage& operator = (const HasJoinWechatPublicRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "HasJoinWechatPublicRequestMessage";
  }
    
  TPSTRING phone;  

};

    
class HasJoinWechatPublicMessage : public MessageBase {
public:
  HasJoinWechatPublicMessage();
  virtual ~HasJoinWechatPublicMessage();
  HasJoinWechatPublicMessage(const HasJoinWechatPublicMessage&);
  HasJoinWechatPublicMessage& operator = (const HasJoinWechatPublicMessage&);
  
  virtual const TPSTRING get_type() const {
    return "HasJoinWechatPublicMessage";
  }
    
  TPNUMERIC status;  

  TPBOOLEAN join;  

};

    
class HasJoinWechatPublicResponseMessage : public SecureResponseMessage {
public:
  HasJoinWechatPublicResponseMessage();
  virtual ~HasJoinWechatPublicResponseMessage();
  HasJoinWechatPublicResponseMessage(const HasJoinWechatPublicResponseMessage&);
  HasJoinWechatPublicResponseMessage& operator = (const HasJoinWechatPublicResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "HasJoinWechatPublicResponseMessage";
  }
    
  HasJoinWechatPublicMessage* result;  
  void create_result(const HasJoinWechatPublicMessage& item);
  void remove_result();
        
};

    
class GetRemoteDualsimInfoRequestMessage : public MessageBase {
public:
  GetRemoteDualsimInfoRequestMessage();
  virtual ~GetRemoteDualsimInfoRequestMessage();
  GetRemoteDualsimInfoRequestMessage(const GetRemoteDualsimInfoRequestMessage&);
  GetRemoteDualsimInfoRequestMessage& operator = (const GetRemoteDualsimInfoRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "GetRemoteDualsimInfoRequestMessage";
  }
    
  TPSTRING manufacture;  

  TPSTRING model;  

  TPSTRING host;  

  TPSTRING sdk_int;  

  TPNUMERIC version;  

};

    
class GetRemoteDualsimInfoMessage : public MessageBase {
public:
  GetRemoteDualsimInfoMessage();
  virtual ~GetRemoteDualsimInfoMessage();
  GetRemoteDualsimInfoMessage(const GetRemoteDualsimInfoMessage&);
  GetRemoteDualsimInfoMessage& operator = (const GetRemoteDualsimInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "GetRemoteDualsimInfoMessage";
  }
    
  TPSTRING dsi;  

  TPNUMERIC dex;  

  TPBOOLEAN matched;  

  TPBOOLEAN device_exist;  

};

    
class GetRemoteDualsimInfoResponseMessage : public SecureResponseMessage {
public:
  GetRemoteDualsimInfoResponseMessage();
  virtual ~GetRemoteDualsimInfoResponseMessage();
  GetRemoteDualsimInfoResponseMessage(const GetRemoteDualsimInfoResponseMessage&);
  GetRemoteDualsimInfoResponseMessage& operator = (const GetRemoteDualsimInfoResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "GetRemoteDualsimInfoResponseMessage";
  }
    
  GetRemoteDualsimInfoMessage* result;  
  void create_result(const GetRemoteDualsimInfoMessage& item);
  void remove_result();
        
};

    
class UploadDualsimInfoRequestMessage : public MessageBase {
public:
  UploadDualsimInfoRequestMessage();
  virtual ~UploadDualsimInfoRequestMessage();
  UploadDualsimInfoRequestMessage(const UploadDualsimInfoRequestMessage&);
  UploadDualsimInfoRequestMessage& operator = (const UploadDualsimInfoRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "UploadDualsimInfoRequestMessage";
  }
    
  TPSTRING manufacture;  

  TPSTRING model;  

  TPSTRING host;  

  TPSTRING sdk_int;  

  TPSTRING dsi;  

  TPNUMERIC version;  

};

    
class UploadDualsimInfoResponseMessage : public SecureResponseMessage {
public:
  UploadDualsimInfoResponseMessage();
  virtual ~UploadDualsimInfoResponseMessage();
  UploadDualsimInfoResponseMessage(const UploadDualsimInfoResponseMessage&);
  UploadDualsimInfoResponseMessage& operator = (const UploadDualsimInfoResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "UploadDualsimInfoResponseMessage";
  }
    
  TPSTRING error_msg;  

};

    
class UploadDeviceInfoRequestMessage : public MessageBase {
public:
  UploadDeviceInfoRequestMessage();
  virtual ~UploadDeviceInfoRequestMessage();
  UploadDeviceInfoRequestMessage(const UploadDeviceInfoRequestMessage&);
  UploadDeviceInfoRequestMessage& operator = (const UploadDeviceInfoRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "UploadDeviceInfoRequestMessage";
  }
    
  TPSTRING manufacture;  

  TPSTRING model;  

  TPSTRING host;  

  TPSTRING sdk_int;  

  TPSTRING legacy_label;  

  TPSTRING details;  

};

    
class UploadDeviceInfoResponseMessage : public SecureResponseMessage {
public:
  UploadDeviceInfoResponseMessage();
  virtual ~UploadDeviceInfoResponseMessage();
  UploadDeviceInfoResponseMessage(const UploadDeviceInfoResponseMessage&);
  UploadDeviceInfoResponseMessage& operator = (const UploadDeviceInfoResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "UploadDeviceInfoResponseMessage";
  }
    
  TPSTRING error_msg;  

};

    
class JudgeDualSimInfoManualRequestMessage : public MessageBase {
public:
  JudgeDualSimInfoManualRequestMessage();
  virtual ~JudgeDualSimInfoManualRequestMessage();
  JudgeDualSimInfoManualRequestMessage(const JudgeDualSimInfoManualRequestMessage&);
  JudgeDualSimInfoManualRequestMessage& operator = (const JudgeDualSimInfoManualRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "JudgeDualSimInfoManualRequestMessage";
  }
    
  TPSTRING manufacture;  

  TPSTRING model;  

  TPSTRING host;  

  TPSTRING sdk_int;  

  TPNUMERIC version;  

};

    
class JudgeDualSimInfoManualMessage : public MessageBase {
public:
  JudgeDualSimInfoManualMessage();
  virtual ~JudgeDualSimInfoManualMessage();
  JudgeDualSimInfoManualMessage(const JudgeDualSimInfoManualMessage&);
  JudgeDualSimInfoManualMessage& operator = (const JudgeDualSimInfoManualMessage&);
  
  virtual const TPSTRING get_type() const {
    return "JudgeDualSimInfoManualMessage";
  }
    
  TPNUMERIC manual_version;  

};

    
class JudgeDualSimInfoManualResponseMessage : public SecureResponseMessage {
public:
  JudgeDualSimInfoManualResponseMessage();
  virtual ~JudgeDualSimInfoManualResponseMessage();
  JudgeDualSimInfoManualResponseMessage(const JudgeDualSimInfoManualResponseMessage&);
  JudgeDualSimInfoManualResponseMessage& operator = (const JudgeDualSimInfoManualResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "JudgeDualSimInfoManualResponseMessage";
  }
    
  JudgeDualSimInfoManualMessage* result;  
  void create_result(const JudgeDualSimInfoManualMessage& item);
  void remove_result();
        
};

    
class GetControlServerDataRequestMessage : public MessageBase {
public:
  GetControlServerDataRequestMessage();
  virtual ~GetControlServerDataRequestMessage();
  GetControlServerDataRequestMessage(const GetControlServerDataRequestMessage&);
  GetControlServerDataRequestMessage& operator = (const GetControlServerDataRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "GetControlServerDataRequestMessage";
  }
    
  TPNUMERIC tu;  

  VECTOR_T(TPNUMERIC) support_ad_platform_id;  

  TPSTRING ip;  

  TPNUMERIC time;  

  TPNUMERIC product;  

  TPNUMERIC debug;  

  TPSTRING nt;  

  TPSTRING vt;  

  TPNUMERIC os;  

  TPNUMERIC ftu;  

};

    
class GetControlServerDataMessage : public MessageBase {
public:
  GetControlServerDataMessage();
  virtual ~GetControlServerDataMessage();
  GetControlServerDataMessage(const GetControlServerDataMessage&);
  GetControlServerDataMessage& operator = (const GetControlServerDataMessage&);
  
  virtual const TPSTRING get_type() const {
    return "GetControlServerDataMessage";
  }
    
  TPSTRING placement_id;  

  TPNUMERIC ad_platform_id;  

  TPSTRING style;  

};

    
class GetControlServerDataResponseMessage : public TPResponseMessage {
public:
  GetControlServerDataResponseMessage();
  virtual ~GetControlServerDataResponseMessage();
  GetControlServerDataResponseMessage(const GetControlServerDataResponseMessage&);
  GetControlServerDataResponseMessage& operator = (const GetControlServerDataResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "GetControlServerDataResponseMessage";
  }
    
  VECTOR_T(TPNUMERIC) ad_platform_id;  

  VECTOR_T(GetControlServerDataMessage*) data_id;  
  void insert_data_id(const GetControlServerDataMessage& item);

  VECTOR_T(TPNUMERIC) enable_platform_list;  

  TPNUMERIC tu;  

  TPNUMERIC expid;  

  TPSTRING s;  

};

    
class PushTalkRegisterRequestMessage : public MessageBase {
public:
  PushTalkRegisterRequestMessage();
  virtual ~PushTalkRegisterRequestMessage();
  PushTalkRegisterRequestMessage(const PushTalkRegisterRequestMessage&);
  PushTalkRegisterRequestMessage& operator = (const PushTalkRegisterRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkRegisterRequestMessage";
  }
    
};

    
class PushTalkRegisterResponseMessage : public SecureResponseMessage {
public:
  PushTalkRegisterResponseMessage();
  virtual ~PushTalkRegisterResponseMessage();
  PushTalkRegisterResponseMessage(const PushTalkRegisterResponseMessage&);
  PushTalkRegisterResponseMessage& operator = (const PushTalkRegisterResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkRegisterResponseMessage";
  }
    
};

    
class PushTalkUserExistMessage : public MessageBase {
public:
  PushTalkUserExistMessage();
  virtual ~PushTalkUserExistMessage();
  PushTalkUserExistMessage(const PushTalkUserExistMessage&);
  PushTalkUserExistMessage& operator = (const PushTalkUserExistMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUserExistMessage";
  }
    
  VECTOR_T(TPSTRING) status;  

  TPNUMERIC sleep;  

};

    
class PushTalkUserExistRequestMessage : public MessageBase {
public:
  PushTalkUserExistRequestMessage();
  virtual ~PushTalkUserExistRequestMessage();
  PushTalkUserExistRequestMessage(const PushTalkUserExistRequestMessage&);
  PushTalkUserExistRequestMessage& operator = (const PushTalkUserExistRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUserExistRequestMessage";
  }
    
  VECTOR_T(TPSTRING) user_account_list;  

};

    
class PushTalkUserExistResponseMessage : public SecureResponseMessage {
public:
  PushTalkUserExistResponseMessage();
  virtual ~PushTalkUserExistResponseMessage();
  PushTalkUserExistResponseMessage(const PushTalkUserExistResponseMessage&);
  PushTalkUserExistResponseMessage& operator = (const PushTalkUserExistResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUserExistResponseMessage";
  }
    
  PushTalkUserExistMessage* result;  
  void create_result(const PushTalkUserExistMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class RegisterAndesRequestMessage : public MessageBase {
public:
  RegisterAndesRequestMessage();
  virtual ~RegisterAndesRequestMessage();
  RegisterAndesRequestMessage(const RegisterAndesRequestMessage&);
  RegisterAndesRequestMessage& operator = (const RegisterAndesRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RegisterAndesRequestMessage";
  }
    
  TPSTRING account_name;  

  TPSTRING account_type;  

  TPSTRING verification;  

  TPSTRING password;  

};

    
class PushTalkLoginMessage : public MessageBase {
public:
  PushTalkLoginMessage();
  virtual ~PushTalkLoginMessage();
  PushTalkLoginMessage(const PushTalkLoginMessage&);
  PushTalkLoginMessage& operator = (const PushTalkLoginMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkLoginMessage";
  }
    
  TPSTRING secret;  

  TPSTRING userid;  

};

    
class RegisterAndesResponseMessage : public SecureResponseMessage {
public:
  RegisterAndesResponseMessage();
  virtual ~RegisterAndesResponseMessage();
  RegisterAndesResponseMessage(const RegisterAndesResponseMessage&);
  RegisterAndesResponseMessage& operator = (const RegisterAndesResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "RegisterAndesResponseMessage";
  }
    
  PushTalkLoginMessage* result;  
  void create_result(const PushTalkLoginMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

  TPSTRING ticket;  

  TPSTRING access_token;  

};

    
class EncryptRegisterAndesRequestMessage : public MessageBase {
public:
  EncryptRegisterAndesRequestMessage();
  virtual ~EncryptRegisterAndesRequestMessage();
  EncryptRegisterAndesRequestMessage(const EncryptRegisterAndesRequestMessage&);
  EncryptRegisterAndesRequestMessage& operator = (const EncryptRegisterAndesRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "EncryptRegisterAndesRequestMessage";
  }
    
  TPSTRING account_name;  

  TPSTRING account_type;  

  TPSTRING verification;  

  TPSTRING password;  

};

    
class EncryptRegisterAndesResponseMessage : public SecureResponseMessage {
public:
  EncryptRegisterAndesResponseMessage();
  virtual ~EncryptRegisterAndesResponseMessage();
  EncryptRegisterAndesResponseMessage(const EncryptRegisterAndesResponseMessage&);
  EncryptRegisterAndesResponseMessage& operator = (const EncryptRegisterAndesResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "EncryptRegisterAndesResponseMessage";
  }
    
  PushTalkLoginMessage* result;  
  void create_result(const PushTalkLoginMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

  TPSTRING ticket;  

  TPSTRING access_token;  

};

    
class PushTalkUserInfoRequestMessage : public MessageBase {
public:
  PushTalkUserInfoRequestMessage();
  virtual ~PushTalkUserInfoRequestMessage();
  PushTalkUserInfoRequestMessage(const PushTalkUserInfoRequestMessage&);
  PushTalkUserInfoRequestMessage& operator = (const PushTalkUserInfoRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUserInfoRequestMessage";
  }
    
  TPSTRING name;  

  TPSTRING gender;  

  TPSTRING head_image_url;  

};

    
class PushTalkUserInfoResponseMessage : public SecureResponseMessage {
public:
  PushTalkUserInfoResponseMessage();
  virtual ~PushTalkUserInfoResponseMessage();
  PushTalkUserInfoResponseMessage(const PushTalkUserInfoResponseMessage&);
  PushTalkUserInfoResponseMessage& operator = (const PushTalkUserInfoResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUserInfoResponseMessage";
  }
    
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class PushTalkSearchMessage : public MessageBase {
public:
  PushTalkSearchMessage();
  virtual ~PushTalkSearchMessage();
  PushTalkSearchMessage(const PushTalkSearchMessage&);
  PushTalkSearchMessage& operator = (const PushTalkSearchMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkSearchMessage";
  }
    
  TPSTRING user_id;  

  TPSTRING name;  

  TPSTRING phone;  

  TPSTRING head_image_url;  

  TPSTRING gender;  

};

    
class PushTalkSearchRequestMessage : public MessageBase {
public:
  PushTalkSearchRequestMessage();
  virtual ~PushTalkSearchRequestMessage();
  PushTalkSearchRequestMessage(const PushTalkSearchRequestMessage&);
  PushTalkSearchRequestMessage& operator = (const PushTalkSearchRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkSearchRequestMessage";
  }
    
  TPSTRING content;  

  TPSTRING type;  

};

    
class PushTalkSearchResponseMessage : public SecureResponseMessage {
public:
  PushTalkSearchResponseMessage();
  virtual ~PushTalkSearchResponseMessage();
  PushTalkSearchResponseMessage(const PushTalkSearchResponseMessage&);
  PushTalkSearchResponseMessage& operator = (const PushTalkSearchResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkSearchResponseMessage";
  }
    
  VECTOR_T(PushTalkSearchMessage*) result;  
  void insert_result(const PushTalkSearchMessage& item);

  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class PushTalkUploadBiBiStatRequestMessage : public MessageBase {
public:
  PushTalkUploadBiBiStatRequestMessage();
  virtual ~PushTalkUploadBiBiStatRequestMessage();
  PushTalkUploadBiBiStatRequestMessage(const PushTalkUploadBiBiStatRequestMessage&);
  PushTalkUploadBiBiStatRequestMessage& operator = (const PushTalkUploadBiBiStatRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUploadBiBiStatRequestMessage";
  }
    
  TPSTRING content;  

};

    
class PushTalkUploadBiBiStatMessage : public MessageBase {
public:
  PushTalkUploadBiBiStatMessage();
  virtual ~PushTalkUploadBiBiStatMessage();
  PushTalkUploadBiBiStatMessage(const PushTalkUploadBiBiStatMessage&);
  PushTalkUploadBiBiStatMessage& operator = (const PushTalkUploadBiBiStatMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUploadBiBiStatMessage";
  }
    
};

    
class PushTalkUploadBiBiStatResponseMessage : public SecureResponseMessage {
public:
  PushTalkUploadBiBiStatResponseMessage();
  virtual ~PushTalkUploadBiBiStatResponseMessage();
  PushTalkUploadBiBiStatResponseMessage(const PushTalkUploadBiBiStatResponseMessage&);
  PushTalkUploadBiBiStatResponseMessage& operator = (const PushTalkUploadBiBiStatResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUploadBiBiStatResponseMessage";
  }
    
  PushTalkUploadBiBiStatMessage* result;  
  void create_result(const PushTalkUploadBiBiStatMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class PushTalkUserInfoMessage : public MessageBase {
public:
  PushTalkUserInfoMessage();
  virtual ~PushTalkUserInfoMessage();
  PushTalkUserInfoMessage(const PushTalkUserInfoMessage&);
  PushTalkUserInfoMessage& operator = (const PushTalkUserInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUserInfoMessage";
  }
    
  TPSTRING user_id;  

  TPSTRING name;  

  TPSTRING phone;  

  TPSTRING head_image_url;  

  TPSTRING gender;  

};

    
class PushTalkUserInfoExistMessage : public MessageBase {
public:
  PushTalkUserInfoExistMessage();
  virtual ~PushTalkUserInfoExistMessage();
  PushTalkUserInfoExistMessage(const PushTalkUserInfoExistMessage&);
  PushTalkUserInfoExistMessage& operator = (const PushTalkUserInfoExistMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUserInfoExistMessage";
  }
    
  VECTOR_T(PushTalkUserInfoMessage*) status;  
  void insert_status(const PushTalkUserInfoMessage& item);

};

    
class PushTalkUserInfoExistRequestMessage : public MessageBase {
public:
  PushTalkUserInfoExistRequestMessage();
  virtual ~PushTalkUserInfoExistRequestMessage();
  PushTalkUserInfoExistRequestMessage(const PushTalkUserInfoExistRequestMessage&);
  PushTalkUserInfoExistRequestMessage& operator = (const PushTalkUserInfoExistRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUserInfoExistRequestMessage";
  }
    
  VECTOR_T(TPSTRING) user_account_list;  

};

    
class PushTalkUserInfoExistResponseMessage : public SecureResponseMessage {
public:
  PushTalkUserInfoExistResponseMessage();
  virtual ~PushTalkUserInfoExistResponseMessage();
  PushTalkUserInfoExistResponseMessage(const PushTalkUserInfoExistResponseMessage&);
  PushTalkUserInfoExistResponseMessage& operator = (const PushTalkUserInfoExistResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "PushTalkUserInfoExistResponseMessage";
  }
    
  PushTalkUserInfoExistMessage* result;  
  void create_result(const PushTalkUserInfoExistMessage& item);
  void remove_result();
        
  TPNUMERIC req_id;  

  TPSTRING sign;  

  TPSTRING err_msg;  

};

    
class VoipDealStrategyRequestMessage : public MessageBase {
public:
  VoipDealStrategyRequestMessage();
  virtual ~VoipDealStrategyRequestMessage();
  VoipDealStrategyRequestMessage(const VoipDealStrategyRequestMessage&);
  VoipDealStrategyRequestMessage& operator = (const VoipDealStrategyRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipDealStrategyRequestMessage";
  }
    
  TPSTRING caller;  

  TPSTRING callee;  

  TPSTRING version;  

  TPSTRING channel_code;  

};

    
class VoipDealStrategyResponseMessage : public SecureResponseMessage {
public:
  VoipDealStrategyResponseMessage();
  virtual ~VoipDealStrategyResponseMessage();
  VoipDealStrategyResponseMessage(const VoipDealStrategyResponseMessage&);
  VoipDealStrategyResponseMessage& operator = (const VoipDealStrategyResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "VoipDealStrategyResponseMessage";
  }
    
  TPNUMERIC deal_strategy_code;  

};

    
class SpecialTaskRewardRequestMessage : public MessageBase {
public:
  SpecialTaskRewardRequestMessage();
  virtual ~SpecialTaskRewardRequestMessage();
  SpecialTaskRewardRequestMessage(const SpecialTaskRewardRequestMessage&);
  SpecialTaskRewardRequestMessage& operator = (const SpecialTaskRewardRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SpecialTaskRewardRequestMessage";
  }
    
  TPNUMERIC task_id;  

};

    
class SpecialTaskRewardResultMessage : public MessageBase {
public:
  SpecialTaskRewardResultMessage();
  virtual ~SpecialTaskRewardResultMessage();
  SpecialTaskRewardResultMessage(const SpecialTaskRewardResultMessage&);
  SpecialTaskRewardResultMessage& operator = (const SpecialTaskRewardResultMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SpecialTaskRewardResultMessage";
  }
    
  TPNUMERIC bonus_type;  

  TPNUMERIC bonus_size;  

  TPNUMERIC occurrence;  

};

    
class SpecialTaskRewardResponseMessage : public SecureResponseMessage {
public:
  SpecialTaskRewardResponseMessage();
  virtual ~SpecialTaskRewardResponseMessage();
  SpecialTaskRewardResponseMessage(const SpecialTaskRewardResponseMessage&);
  SpecialTaskRewardResponseMessage& operator = (const SpecialTaskRewardResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "SpecialTaskRewardResponseMessage";
  }
    
  SpecialTaskRewardResultMessage* result;  
  void create_result(const SpecialTaskRewardResultMessage& item);
  void remove_result();
        
};

    
class ActivityAfterCallRequestMessage : public MessageBase {
public:
  ActivityAfterCallRequestMessage();
  virtual ~ActivityAfterCallRequestMessage();
  ActivityAfterCallRequestMessage(const ActivityAfterCallRequestMessage&);
  ActivityAfterCallRequestMessage& operator = (const ActivityAfterCallRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ActivityAfterCallRequestMessage";
  }
    
  TPNUMERIC close_time;  

  TPSTRING target_phone;  

  TPSTRING target_name;  

  TPNUMERIC duration;  

  TPNUMERIC current_timestamp;  

  TPNUMERIC is_general_contact;  

};

    
class ActivityAfterCallContentMessage : public MessageBase {
public:
  ActivityAfterCallContentMessage();
  virtual ~ActivityAfterCallContentMessage();
  ActivityAfterCallContentMessage(const ActivityAfterCallContentMessage&);
  ActivityAfterCallContentMessage& operator = (const ActivityAfterCallContentMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ActivityAfterCallContentMessage";
  }
    
  TPSTRING title_text;  

  TPSTRING title_content;  

  TPSTRING message;  

  TPBOOLEAN close;  

  TPSTRING left_button_text;  

  TPSTRING right_button_text;  

  TPSTRING left_button_action;  

  TPSTRING right_button_action;  

  TPSTRING left_button_type;  

  TPSTRING right_button_type;  

  TPSTRING extra;  

};

    
class ActivityAfterCallInfoMessage : public MessageBase {
public:
  ActivityAfterCallInfoMessage();
  virtual ~ActivityAfterCallInfoMessage();
  ActivityAfterCallInfoMessage(const ActivityAfterCallInfoMessage&);
  ActivityAfterCallInfoMessage& operator = (const ActivityAfterCallInfoMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ActivityAfterCallInfoMessage";
  }
    
  TPNUMERIC next_update_time;  

  ActivityAfterCallContentMessage* content;  
  void create_content(const ActivityAfterCallContentMessage& item);
  void remove_content();
        
};

    
class ActivityAfterCallResponseMessage : public SecureResponseMessage {
public:
  ActivityAfterCallResponseMessage();
  virtual ~ActivityAfterCallResponseMessage();
  ActivityAfterCallResponseMessage(const ActivityAfterCallResponseMessage&);
  ActivityAfterCallResponseMessage& operator = (const ActivityAfterCallResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "ActivityAfterCallResponseMessage";
  }
    
  ActivityAfterCallInfoMessage* result;  
  void create_result(const ActivityAfterCallInfoMessage& item);
  void remove_result();
        
};

    
class EarnCenterEventRequestMessage : public MessageBase {
public:
  EarnCenterEventRequestMessage();
  virtual ~EarnCenterEventRequestMessage();
  EarnCenterEventRequestMessage(const EarnCenterEventRequestMessage&);
  EarnCenterEventRequestMessage& operator = (const EarnCenterEventRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "EarnCenterEventRequestMessage";
  }
    
  TPSTRING ad_id;  

};

    
class EarnCenterEventResponseMessage : public SecureResponseMessage {
public:
  EarnCenterEventResponseMessage();
  virtual ~EarnCenterEventResponseMessage();
  EarnCenterEventResponseMessage(const EarnCenterEventResponseMessage&);
  EarnCenterEventResponseMessage& operator = (const EarnCenterEventResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "EarnCenterEventResponseMessage";
  }
    
};

    
class UploadOfficialPushInfoRequestMessage : public MessageBase {
public:
  UploadOfficialPushInfoRequestMessage();
  virtual ~UploadOfficialPushInfoRequestMessage();
  UploadOfficialPushInfoRequestMessage(const UploadOfficialPushInfoRequestMessage&);
  UploadOfficialPushInfoRequestMessage& operator = (const UploadOfficialPushInfoRequestMessage&);
  
  virtual const TPSTRING get_type() const {
    return "UploadOfficialPushInfoRequestMessage";
  }
    
  TPSTRING manufacture;  

  TPSTRING device_token;  

};

    
class UploadOfficialPushInfoResponseMessage : public SecureResponseMessage {
public:
  UploadOfficialPushInfoResponseMessage();
  virtual ~UploadOfficialPushInfoResponseMessage();
  UploadOfficialPushInfoResponseMessage(const UploadOfficialPushInfoResponseMessage&);
  UploadOfficialPushInfoResponseMessage& operator = (const UploadOfficialPushInfoResponseMessage&);
  
  virtual const TPSTRING get_type() const {
    return "UploadOfficialPushInfoResponseMessage";
  }
    
};
 
#endif /* TP_MESSAGE_GENERATED_H_ */
