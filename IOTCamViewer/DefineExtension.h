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

//mail设置////////////////////////////////////////////////////////
typedef struct {
    unsigned int channel; 		// Camera Index
    unsigned char reserved[4];
} SMsgAVIoctrlExGetSmtpReq;

typedef struct {
    unsigned int channel;       // Camera Index
    char sender[64];        /*邮件的发送者                                      */
    char receiver1[64];   /*邮件的接收者                                    */
    char server[64];          /*邮件服务器地址                                    */
    unsigned int port;  /*邮件服务端口                                      */
    unsigned int mail_tls;			/*是否使用  tls  传输协议, 0：不；1：TLS；2：STARTLS*/
    char user[32];     /*邮件服务器登录用户                                */
    char pwd[32];      /*邮件服务器登录密码                                */
} SMsgAVIoctrlExSetSmtpReq, SMsgAVIoctrlExGetSmtpResp;

typedef struct
{
    int result; //0: ok ; 1: failed
    unsigned char reserved[4];
} SMsgAVIoctrlExSetSmtpResp;

typedef enum {
    //mail设置
    IOTYPE_USEREX_IPCAM_GET_SMTP_REQ            =0x4005,
    IOTYPE_USEREX_IPCAM_GET_SMTP_RESP           =0x4006,
    IOTYPE_USEREX_IPCAM_SET_SMTP_REQ            =0x4007,
    IOTYPE_USEREX_IPCAM_SET_SMTP_RESP           =0x4008,
}ENUM_AVIOCTRL_MSGTYPEOwnExt;

#endif
