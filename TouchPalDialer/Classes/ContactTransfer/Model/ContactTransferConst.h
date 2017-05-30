//
//  ContactTransferConst.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/8.
//
//

#ifndef ContactTransferConst_h
#define ContactTransferConst_h

#define MIME_TYPE_DISPLAY_NAME @"display_name"
#define MIME_TYPE_NICK_NAME @"nickname"
#define MIME_TYPE_EMAIL @"email"
#define MIME_TYPE_POSTAL @"postal"
#define MIME_TYPE_ADDRESS @"postal"
#define MIME_TYPE_URL @"website"
#define MIME_TYPE_NOTE @"note"
#define MIME_TYPE_PHOTO @"photo"
#define MIME_TYPE_NUMBER @"number"
#define MIME_TYPE_EVENT @"event"
#define MIME_TYPE_IM @"im"
#define MIME_TYPE_ORG @"org"
#define MIME_TYPE_GROUP @"group"

typedef NS_ENUM(NSInteger, ContactTransferItemType) {
    ITEM_UNKNOWN,
    ITEM_DISPLAY_NAME,
    ITEM_NICK_NAME,
    ITEM_EMAIL,
    ITEM_POSTAL,
    ITEM_ADDRESS,
    ITEM_URL,
    ITEM_NOTE,
    ITEM_PHOTO,
    ITEM_NUMBER,
    ITEM_EVENT,
    ITEM_IM,
    ITEM_ORG,
    ITEM_GROUP
};


// common keys
#define KEY_MIME_TYPE @"mimetype"
#define KEY_VALUE @"value"
#define KEY_TYPE @"type"
#define KEY_PRIMARY @"primary"
#define KEY_IS_PRIMARY @"isPrimary"
#define KEY_IS_IRIMARY @"isIrimary"

// comman types
#define COMMAN_TYPE_HOME @"home"
#define COMMAN_TYPE_WORK @"work"
#define COMMAN_TYPE_OTHER @"other"

// email
#define KEY_EMAIL @"value"
#define EMAIL_IS_PRIMARY @"primary"
#define EMAIL_TYPE_HOME @"home"
#define EMAIL_TYPE_WORK @"work"
#define EMAIL_TYPE_OTHER @"other"

// note
#define KEY_NOTE @"note"

// nickname
#define KEY_NICK_NAME @"nickname"

// name
#define NAME_DISPLAY @"displayName"
#define NAME_FIRST @"firstName"
#define NAME_LAST @"lastName"
#define NAME_MIDDLE @"middleName"
#define NAME_PREFIX @"prefix"
#define NAME_SUFFIX @"suffix"
#define NAME_FIRST_PHONETIC @"firstNamePhonetic"
#define NAME_LAST_PHONETIC @"lastNamePhonetic"
#define NAME_MIDDLE_PHONETIC @"middleNamePhonetic"

// org
#define KEY_ORG @"organization"
#define ORG_JOB_TITLE @"jobTitle"
#define ORG_DEPARTMENT @"department"

// email

// address
#define KEY_ADDRESS @"value"

#define ADDRESS_TYPE_HOME @"home"
#define ADDRESS_TYPE_WORK @"work"
#define ADDRESS_TYPE_OTHER @"other"

#define ADDRESS_STREET @"street"
#define ADDRESS_CITY @"city"
#define ADDRESS_STATE @"state"
#define ADDRESS_ZIP @"zip"
#define ADDRESS_COUNTRY @"country"
#define ADDRESS_COUNTRY_CODE @"countryCode"

// url
#define KEY_URL @"value"
#define URL_TYPE_HOME @"home"
#define URL_TYPE_WORK @"work"
#define URL_TYPE_OTHER @"other"
#define URL_TYPE_HOME_PAGE @"homepage"

// date or event
#define KEY_EVENT @"value"
#define KEY_DATE @"value"
#define EVENT_TYPE_BIRTHDAY @"birthday"
#define EVENT_TYPE_ANNIVERSARY @"anniversary"
#define EVENT_TYPE_OTHER @"other"

// im
#define KEY_IM @"value"
#define IM_PROTOCOL @"protocol"
#define IM_PROTOCOL_MSN @"MSN"
#define IM_PROTOCOL_QQ @"QQ"
#define IM_PROTOCOL_ICQ @"ICQ"
#define IM_PROTOCOL_AIM @"AIM"
#define IM_PROTOCOL_GOOGLE_TALK @"GoogleTalk"
#define IM_PROTOCOL_SKYPE @"Skype"
#define IM_PROTOCOL_NETMEETING @"NetMeeting"
#define IM_PROTOCOL_YAHOO @"Yahoo"
#define IM_PROTOCOL_JABBER @"Jabber"
#define IM_PROTOCOL_FACEBOOK @"Facebook"

// group
#define KEY_GROUP @"group"
#define ACCOUNT_NAME @"account_name"
#define ACCOUNT_TYPE @"account_typ"

// photo
#define PHOTO_ID @"id"
#define PHOTO_CONTENT @"photo_content"
#define PHOTO_VERSION @"photo_version"
#define HAS_PHOTO @"has_photo"


// number
#define KEY_NUMBER @"value"
#define KEY_NUMBER_IS_PRIMARY @"isIrimary"

#define NUMBER_TYPE_HOME @"home"
#define NUMBER_TYPE_MOBILE @"mobile"
#define NUMBER_TYPE_WORK @"work"
#define NUMBER_TYPE_MAIN @"main"
#define NUMBER_TYPE_OTHER @"other"

#define NUMBER_TYPE_FAX_WORK @"workFax"
#define NUMBER_TYPE_FAX_HOME @"homeFax"
#define NUMBER_TYPE_FAX_OTHER @"otherFax"

#define NUMBER_TYPE_PAGER @"pager"
#define NUMBER_TYPE_CALLBACK @"callback"
#define NUMBER_TYPE_CAR @"car"
#define NUMBER_TYPE_COMPANY_MAIN @"companyMain"
#define NUMBER_TYPE_ISDN @"isdn"
#define NUMBER_TYPE_RADIO @"radio"
#define NUMBER_TYPE_TELEX @"telex"
#define NUMBER_TYPE_TTY_TTD @"ttyTtd"
#define NUMBER_TYPE_WORK_MOBILE @"workMobile"
#define NUMBER_TYPE_WORK_PAGER @"workPager"
#define NUMBER_TYPE_ASSISTANT @"assistant"
#define NUMBER_TYPE_MMS @"mms"
#define NUMBER_TYPE_IPHONE @"iphone"

#define HEADER_UUID @"uuid"
#define HEADER_STATUS @"status"
#define NAME_CONTENT @"content"
#define NAME_COUNT @"count"
#define HTTP_STATUS @"http_status"

#define CONTACT_TRANSFER_API @"/contacts/shift"
#define CONTACT_TRANSFER_URL @"http://poll-dialer.cootekservice.com/contacts/shift"
#define ENCODE_UTF8 @"utf-8"


// ---private use ---
#define PRIVATE_STATUS_SELF_SUCCESS (100)
#define PRIVATE_STATUS_NO_NETWORK (101)
#define PRIVATE_STATUS_CAMERA_DENIED (102)
#define PRIVATE_STATUS_INSERTING (103)
#define PRIVATE_STATUS_TIMEOUT (104)

// clinet status
#define STATUS_GENERATE_QRCODE_FAILED (801)
#define STATUS_MODIFY_WHEN_QUERY_ERROR (802)
#define STATUS_NO_CONTACTS_ERROR (803)
#define STATUS_SELF_FINISHED (804)
#define STATUS_OPPOSITE_FINISHED (805)
#define STATUS_INSERT_SUCCESS (806)
#define STATUS_INSERT_FAILED_INTERRUPT (807)
#define STATUS_INSERT_FAILED_SECURITY (808)
#define STATUS_INSERT_FAILED_UNKNOWN (809)
#define STATUS_HTTP_REQUEST_ENTITY_TOO_LARGE (413)

//server status
#define STATUS_SEND_CONNECTION (901)
#define STATUS_SEND_SENDING (902)
#define STATUS_SEND_INTERRUPT (903)
#define STATUS_SEND_FINISHED (904)
#define STATUS_RECEIVE_CONNECTION (905)
#define STATUS_RECEIVE_RECEIVING (906)
#define STATUS_RECEIVE_INTERRUPT (907)

// server error
#define STATUS_NO_UUID_ERROR (908)
#define STATUS_NO_STATUS_ERROR (909)
#define STATUS_NO_CONTENT_ERROR (910)
#define STATUS_CONTENT_FORMAT_ERROR (911)
#define STATUS_NO_SEND_CONNECTION_ERROR (912)
#define STATUS_NO_RECEIVE_CONNECTION_ERROR (913)

//
#define HTTP_METHOD_GET @"Get"
#define HTTP_METHOD_POST @"Post"

//
#define NAME_RECORD_SYSTEM @"system"
#define NAME_RECORD_PRIVATE @"private"


#define QR_REFRESH_BUTTON_WIDH (60)
#define QR_WINDOW_WIDTH (178)
#define QR_IMAGE_WIDTH (134)
#define SEND_CIRCLE_DIAMETER (188)
#define SEND_STATUS_CIRCLE_DIAMETER (160)

#define TIMEOUT (10)
#define CONNECTION_TIMEOUT_SEC (TIMEOUT * 30)
#define PERSIST_TIMEOUT_SEC (TIMEOUT * 30)


typedef NS_ENUM(NSInteger, ContactTransferRecordType) {
    RECORD_TYPE_UNKNOWN,
    RECORD_TYPE_SYSTM,
    RECORD_TYPE_PRIVATE
};

typedef NS_ENUM(NSInteger, ContactTransferDirection) {
    DIRECTION_UNKNOWN,
    DIRECTION_SEND,
    DIRECTION_RECEIVE
};

#endif /* ContactTransferConst_h */
