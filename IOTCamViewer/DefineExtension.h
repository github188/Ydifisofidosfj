//
//  DefineExtension.h
//  P2PCamCEO
//
//  Created by fourones on 15/3/19.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#ifndef P2PCamCEO_DefineExtension_h
#define P2PCamCEO_DefineExtension_h


/* IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ_EXT   = 0x471
 * IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP_EXT  = 0x472
 * IOTYPE_USER_IPCAM_SET_TIMEZONE_REQ_EXT   = 0x473
 * IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP_EXT  = 0x474
 */
typedef struct
{
    int cbSize;							// the following package size in bytes, should be sizeof(SMsgAVIoctrlTimeZone)
    int nIsSupportTimeZone;
    int nGMTDiff;						// the difference between GMT in hours
    char szTimeZoneString[256];			// the timezone description string in multi-bytes char format
    long local_utc_time;                // the number of seconds passed
    // since the UNIX epoch (January 1, 1970 UTC)
    int dst_on;                         // summer time, 0:off 1:on
}SMsgAVIoctrlTimeZoneExt;

typedef enum
{
IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ_EXT      =  0x471,
IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP_EXT     =  0x472,
IOTYPE_USER_IPCAM_SET_TIMEZONE_REQ_EXT      =  0x473,
IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP_EXT     =  0x474,
}ENUM_AVIOCTRL_MSGTYPE_Ext;

#endif
