//
//  consts.h
//  TouchPalDialer
//
//  Created by zhang Owen on 8/4/11.
//  Copyright 2011 Cootek. All rights reserved.
//

/*CONTACT*/
#define CONTACT_HEADER_BAR_TAG      123445

// font
#define CELL_FONT_xXLARGE			28
#define CELL_FONT_XLARGE			24
#define CELL_FONT_LARGER            20
#define CELL_FONT_XTITLE            19
#define CELL_FONT_LARGE				16
#define CELL_FONT_TITILE            16
#define CELL_FONT_INPUT				16
#define CELL_FONT_MEDIUM            15
#define CELL_FONT_SMALL				13
#define CELL_FONT_XSMALL			12

#define FONT_SIZE_00                34
#define FONT_SIZE_0                 30
#define FONT_SIZE_0_KEY             28
#define FONT_SIZE_1_KEY             26
#define FONT_SIZE_0_5               24
#define FONT_SIZE_1                 22
#define FONT_SIZE_1_5               20
#define FONT_SIZE_2                 19
#define FONT_SIZE_2_5               18
#define FONT_SIZE_3                 17
#define FONT_SIZE_3_5               16
#define FONT_SIZE_4                 15
#define FONT_SIZE_4_5               14
#define FONT_SIZE_5                 13
#define FONT_SIZE_5_5               12
#define FONT_SIZE_6                 11
#define FONT_SIZE_7                 10


#define VOIP_LINE_HEIGHT            60
#define VOIP_CELL_HEIGHT            72

#define FONT_SETTINGS_TITLE         16
#define FONT_SETTINGS_DESCRIPTION   14

#define FONT_HEADER_TITLE           20
#define FONT_HEADER_TITLE_NEW       18
#define FONT_HEADER_TAB_TITLE       16

#define COLOR_IN_256(x) ((x)/255.0)

#define REQUEST_SUCCESS               200
#define REQUEST_SUCCESS_MAX           299

#define SEARCH_INPUT_MAX_LENGTH       100

#define CELL_HEIGHT                   56


#define IOS7 ([[UIDevice currentDevice].systemVersion intValue] >= 7 && [[UIDevice currentDevice].systemVersion intValue] < 8)
#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 && [[UIDevice currentDevice].systemVersion intValue] < 9)
#define IOS9 ([[UIDevice currentDevice].systemVersion intValue] >= 9 && [[UIDevice currentDevice].systemVersion intValue] < 10)
#define BOTTOM_PADDING                ([[UIDevice currentDevice].systemVersion intValue] < 8 ? 8 : 10)
#define TOP_PADDING                   ([[UIDevice currentDevice].systemVersion intValue] < 8 ? 9 : 12)
#define LABEL_DIFF (IOS8 ? -4 : 0)


#define CONTENT_BEGIN_Y ([[UIDevice currentDevice].systemVersion intValue] >= 7 ? 65:45)

#define INPUT_BAR_HEIGHT (266)