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
//亮度调节////////////////////////////////////////////////////////////
/*IOTYPE_HICHIP_GETBRIGHT_REQ=0x602
 */
typedef struct
{
    unsigned int channel; // Camera Index
    unsigned char reserved[4];
} SMsgAVIoctrlGetBrightReq;
/*IOTYPE_HICHIP_GETBRIGHT_RESP=0x603
 IOTYPE_HICHIP_SETBRIGHT_REQ=0x604
 */
typedef struct
{
    unsigned int channel; // Camera Index
    unsigned char bright; // refer to ENUM_BRIGHT_LEVEL
    unsigned char reserved[3];
} SMsgAVIoctrlSetBrightReq, SMgAVIoctrlGetBrightResp;
/* AVIOCTRL BRIGHT Type */
typedef enum
{
    AVIOCTRL_BRIGHT_MAX            = 0x01,
    AVIOCTRL_BRIGHT_HIGH           = 0x02,
    AVIOCTRL_BRIGHT_MIDDLE         = 0x03,
    AVIOCTRL_BRIGHT_LOW            = 0x04,
    AVIOCTRL_BRIGHT_MIN            = 0x05,
}ENUM_BRIGHT_LEVEL;
/*IOTYPE_HICHIP_SETBRIGHT_RESP=0x605
 */
typedef struct
{
    unsigned int result; // 0: success; otherwise: failed.
    unsigned char reserved[4];
} SMsgAVIoctrSeltBrightResp;

//对比度调节////////////////////////////////////////////////////////////
/*IOTYPE_HICHIP_GETCONTRAST_REQ=0x606
 */
typedef struct
{
    unsigned int channel; // Camera Index
    unsigned char reserved[4];
} SMsgAVIoctrlGetContrastReq;
/*IOTYPE_HICHIP_GETCONTRAST_RESP=0x607
 IOTYPE_HICHIP_SETCONTRAST_REQ=0x608
 */
typedef struct
{
    unsigned int channel; // Camera Index
    unsigned char contrast; // refer to ENUM_CONTRAST_LEVEL
    unsigned char reserved[3];
} SMsgAVIoctrlSetContrastReq, SMgAVIoctrlGetContrastResp;
/* AVIOCTRL CONTRAST Type */
typedef enum
{
    AVIOCTRL_CONTRAST_MAX            = 0x01,
    AVIOCTRL_CONTRAST_HIGH           = 0x02,
    AVIOCTRL_CONTRAST_MIDDLE         = 0x03,
    AVIOCTRL_CONTRAST_LOW            = 0x04,
    AVIOCTRL_CONTRAST_MIN            = 0x05,
}ENUM_CONTRAST_LEVEL;
/*IOTYPE_HICHIP_SETCONTRAST_RESP=0x609
 */
typedef struct
{
    unsigned int result; // 0: success; otherwise: failed.
    unsigned char reserved[4];
} SMsgAVIoctrSeltContrastResp;

typedef enum {
    //mail设置
    IOTYPE_USEREX_IPCAM_GET_SMTP_REQ            =0x4005,
    IOTYPE_USEREX_IPCAM_GET_SMTP_RESP           =0x4006,
    IOTYPE_USEREX_IPCAM_SET_SMTP_REQ            =0x4007,
    IOTYPE_USEREX_IPCAM_SET_SMTP_RESP           =0x4008,
    //亮度调节
    IOTYPE_HICHIP_GETBRIGHT_REQ                 =0x602,
    IOTYPE_HICHIP_GETBRIGHT_RESP                =0x603,
    IOTYPE_HICHIP_SETBRIGHT_REQ                 =0x604,
    IOTYPE_HICHIP_SETBRIGHT_RESP                =0x605,
    //对比度调节
    IOTYPE_HICHIP_GETCONTRAST_REQ               =0x606,
    IOTYPE_HICHIP_GETCONTRAST_RESP              =0x607,
    IOTYPE_HICHIP_SETCONTRAST_REQ               =0x608,
    IOTYPE_HICHIP_SETCONTRAST_RESP              =0x609,
    //录像设置
    IOTYPE_USER_IPCAM_GET_REC_REQ		        = 0x2211,
    IOTYPE_USER_IPCAM_GET_REC_RESP		        = 0x2212,
    IOTYPE_USER_IPCAM_SET_REC_REQ		        = 0x2213,
    IOTYPE_USER_IPCAM_SET_REC_RESP		        = 0x2214,
    //抓拍
    IOTYPE_USER_IPCAM_GET_SNAP_REQ              = 0x2215,
    IOTYPE_USER_IPCAM_GET_SNAP_RESP             = 0x2216,
    IOTYPE_USER_IPCAM_SET_SNAP_REQ              = 0x2217,
    IOTYPE_USER_IPCAM_SET_SNAP_RESP             = 0x2218,
    //图片预览
    IOTYPE_USEREX_IPCAM_GET_PREVIEW_REQ			=0x5001,
    IOTYPE_USEREX_IPCAM_GET_PREVIEW_RESP		=0x5002,
    //预置位
    IOTYPE_USER_IPCAM_SETPRESET_REQ				= 0x440,
    IOTYPE_USER_IPCAM_SETPRESET_RESP			= 0x441,
    IOTYPE_USER_IPCAM_GETPRESET_REQ				= 0x442,
    IOTYPE_USER_IPCAM_GETPRESET_RESP			= 0x443,

    //红外开关
    IOTYPE_USEREX_IPCAM_GET_LED_REQ             =0x400E,
    IOTYPE_USEREX_IPCAM_GET_LED_RESP            =0x400F,
    IOTYPE_USEREX_IPCAM_SET_LED_REQ             =0x4010,
    IOTYPE_USEREX_IPCAM_SET_LED_RESP            = 0x4011,
    //(图片参数#37)复位
    IOTYPE_USER_IPCAM_SET_IMAGE_PARAM_REQ		=0x8000,
    IOTYPE_USER_IPCAM_SET_IMAGE_PARAM_RESP		=0x8001,
    IOTYPE_USER_IPCAM_GET_IMAGE_PARAM_REQ		=0x8002,
    IOTYPE_USER_IPCAM_GET_IMAGE_PARAM_RESP		=0x8003,
    
    //重启设备
    IOTYPE_USER_IPCAM_SETREBOOT_REQ				= 0x8004,
    IOTYPE_USER_IPCAM_SETREBOOT_RESP			= 0x8005,
    
    //FTP
    IOTYPE_USER_IPCAM_SET_FTP_REQ				=0x055A,
    IOTYPE_USER_IPCAM_SET_FTP_RESP				= 0x055B,
    IOTYPE_USER_IPCAM_GET_FTP_REQ				= 0x055C,
    IOTYPE_USER_IPCAM_GET_FTP_RESP				= 0x055D,

    //alarm
    IOTYPE_USER_IPCAM_GETGUARD_REQ				= 0x420,
    IOTYPE_USER_IPCAM_GETGUARD_RESP             = 0x421,
    IOTYPE_USER_IPCAM_SETGUARD_REQ				= 0x422,
    IOTYPE_USER_IPCAM_SETGUARD_RESP             = 0x423,
    
    //录像扩展设置 ①录像参数设置：

    //录像扩展设置 ②录像、抓拍计划设置：
    IOTYPE_USER_IPCAM_GET_SCHEDULE_REQ		  = 0x2219,
    IOTYPE_USER_IPCAM_GET_SCHEDULE_RESP		  = 0x221A,
    IOTYPE_USER_IPCAM_SET_SCHEDULE_REQ		  = 0x221B,
    IOTYPE_USER_IPCAM_SET_SCHEDULE_RESP		  = 0x221C,
    

    IOTYPE_USER_IPCAM_GET_EnParam_REQ           = 0x804,
    IOTYPE_USER_IPCAM_GET_EnParam_RESP = 0x805,
    IOTYPE_USER_IPCAM_SETSOUNDDETECT_REQ		= 0x03B2,
    IOTYPE_USER_IPCAM_SETSOUNDDETECT_RESP		= 0x03B3,
    IOTYPE_USER_IPCAM_GETSOUNDDETECT_REQ		= 0x03B4,
    IOTYPE_USER_IPCAM_GETSOUNDDETECT_RESP		= 0x03B5

}ENUM_AVIOCTRL_MSGTYPEOwnExt;

//录像设置
/* IOTYPE_USER_IPCAM_GET_REC_REQ		        = 0x2211,   */
typedef struct
{
    unsigned char reserved[8];
}SMsgAVIoctrlGetRecReq;

/* IOTYPE_USER_IPCAM_GET_REC_RESP		        = 0x2212,   */
/* IOTYPE_USER_IPCAM_SET_REC_REQ		        = 0x2213,   */
typedef struct
{
    unsigned int  u32RecChn;    /* 11, 12, 13*/
    unsigned int  u32PlanRecEnable; /* 0:disable, 1:enable */
    unsigned int  u32PlanRecLen; //定时录像文件时长
    unsigned int  u32AlarmRecEnable; /* 0:disable, 1:enable */
    unsigned int  u32AlarmRecLen; //报警录像文件时长,预报警录像+报警录像,5+10=15秒.
    unsigned char reserved[8];
} SMsgAVIoctrlGetRecResp, SMsgAVIoctrlSetRecReq;

/* IOTYPE_USER_IPCAM_SET_REC_RESP		        = 0x2214,   */
typedef struct
{
    unsigned int  result;	// 0: success; otherwise: failed.
    unsigned char reserved[8];
}SMsgAVIoctrlSetRecResp;

/* IOTYPE_USER_IPCAM_GET_SNAP_REQ		        = 0x2215,   */
typedef struct
{
    unsigned char reserved[8];
}SMsgAVIoctrlGetSnapReq;

/* IOTYPE_USER_IPCAM_GET_SNAP_RESP		        = 0x2216,   */
/* IOTYPE_USER_IPCAM_SET_SNAP_REQ		        = 0x2217,   */
typedef struct
{
    unsigned int  u32SnapEnable;  /* 0:disable, 1:enable */
    unsigned int  u32SnapChn;      /* 11, 12, 13*/
    unsigned int  u32SnapInterval; /* 5s ~ 24*60*60s  */
    unsigned int  u32SnapCount; /* 1-3 */
    unsigned char reserved[8];
} SMsgAVIoctrlGetSnapResp, SMsgAVIoctrlSetSnapReq;

/* IOTYPE_USER_IPCAM_SET_SNAP_RESP		        = 0x2218,   */
typedef struct
{
    unsigned int  result;	// 0: success; otherwise: failed.
    unsigned char reserved[8];
}SMsgAVIoctrlSetSnapResp;
//图片预览
typedef struct
{
    unsigned int 	resolution; /*0: QQVGA 1:720P*/
    unsigned char reserved[4];
}SMsgAVIoctrlGetPreReq;

typedef struct
{
    unsigned int size; /*each real package size, max 1000 bytes*/
    unsigned char buf[1000];	/*picture content*/
}PicInfo;
typedef struct
{
    unsigned int TotalSize;	/*total picture size */
    unsigned int  endflag;	 /*0 :(begin to send ) 1: end*/
    unsigned int count;  /*package number ,start from 0  */
    PicInfo picinfo;
}SMsgAVIoctrlGetPreResp;
//说明: 图片预览客户端接收数据,类似录像列表，endflag=0，开始分隔图片（1000 bytes）一包发送, endflag=1,发送最后一包数据，大小见size, 720P （ >100kbytes）图片太大接收时间较长。
//预置位
/* IOTYPE_USER_IPCAM_SETPRESET_REQ				= 0x440
 */
/* IOTYPE_USER_IPCAM_GETPRESET_RESP				= 0x443*/
 
 typedef struct
 {
	unsigned int channel;	// AvServer Index
	unsigned int nPresetIdx;	//0~6
 } SMsgAVIoctrlSetPresetReq,SMsgAVIoctrlGetPresetResp;
 
 /* IOTYPE_USER_IPCAM_SETPRESET_RESP				= 0x441
 */
typedef struct
{
    int result;	// 0: success; otherwise: failed.
    unsigned char reserved[4];
    
} SMsgAVIoctrlSetPresetResp;

/* IOTYPE_USER_IPCAM_GETPRESET_REQ				= 0x442
 */
typedef struct
{
    unsigned int channel;	// AvServer Index
    unsigned int nPresetIdx;	//0~6
} SMsgAVIoctrlGetPresetReq;


//IOTYPE_USER_IPCAM_GET_SOUND_VOLUME_REQ = 0x224C,

typedef struct

{
    
    unsigned char reserved[8];
    
}SMsgAVIoctrlGetSoundReq;

//IOTYPE_USER_IPCAM_SET_SOUND_VOLUME_RESP = 0x224F,

typedef struct

{
    
    unsigned int result; // 0: success; otherwise: failed.
    
    unsigned char reserved[4];
    
}SMsgAVIoctrlSetSoundResp;

//IOTYPE_USER_IPCAM_GET_SOUND_VOLUME_RESP = 0x224D,

//IOTYPE_USER_IPCAM_SET_SOUND_VOLUME_REQ = 0x224E,

typedef struct

{
    
    unsigned int SoundIn;// 1-100
    
    unsigned int SoundOut;// 1-100
    
    unsigned char reserved[8];
    
}SMsgAVIoctrlGetSoundResp,SMsgAVIoctrlSetSoundReq;

typedef struct{
    unsigned int channel;
    unsigned char reserved[4];
}SMsgAVIoctrlGetEnParamReq;
typedef struct {
    unsigned int channel;
    unsigned int tempreture;
    unsigned int humidity;
    unsigned char reserved[4];
}SMsgAVIoctrlGetEnParamResp;



typedef struct
{
    unsigned int channel; 	// Camera Index
    unsigned char reserved[4];
}SMsgAVIoctrlGetSoundDetectReq, SMsgAVIoctrlGetDectectDurationReq;

typedef struct
{
    unsigned int channel; 		// Camera Index
    int sensitivity; 	// 0(Disabled) ~ 100(MAX)
}SMsgAVIoctrlSetSoundDetectReq, SMsgAVIoctrlGetSoundDetectResp;

typedef struct
{
    int result;	// 0: success; otherwise: failed.
    unsigned char reserved[4];
}SMsgAVIoctrlSetSoundDetectResp, SMsgAVIoctrlSetDectectDurationResp;


//LED light
//#define IOTYPE_USEREX_IPCAM_SET_LED_REQ 0x4010
//Data: SMsgAVIoctrlExSetLEDReq

typedef struct
{
    unsigned int 	sSwitch;		/*0:auto 1:open  2:close*/
    unsigned char reserved[4];
} SMsgAVIoctrlExGetLEDResp, SMsgAVIoctrlExSetLEDReq;
//#define IOTYPE_USEREX_IPCAM_SET_LED_RESP 0x4011
//Data: SMsgAVIoctrlExSetLEDResp
typedef struct
{
    int result;	// 0: success; otherwise: failed.
    unsigned char reserved[4];
}SMsgAVIoctrlExSetLEDResp;


//#define IOTYPE_USEREX_IPCAM_GET_LED_REQ 0x400E
//Data: SMsgAVIoctrlExGetLEDReq
typedef struct
{
    unsigned char reserved[4];
}SMsgAVIoctrlExGetLEDReq;


//(图片参数#37)复位
/*
 IOTYPE_USER_IPCAM_SET_IMAGE_PARAM_REQ
 IOTYPE_USER_IPCAM_GET_IMAGE_PARAM_RESP
 */
typedef struct
{
    unsigned int channel;		//Camera Index
    unsigned int brightness;	/*value: 1-100*/
    unsigned int saturation;   /*value: 1-100*/
    unsigned int contrast;	/*value: 1-100*/
    unsigned int todefault;		/*value : if set !0 ,image to default value*/
    unsigned char reserved[16];
}SMsgAVIoctrlSetImageParamReq,SMsgAVIoctrlGetImageParamResp;
/*IOTYPE_USER_IPCAM_GET_IMAGE_PARAM_REQ*/
typedef struct
{
    unsigned int channel;   // Camera Index
    unsigned char reserved[8];
}SMsgAVIoctrlGetImageParamReq;

/*IOTYPE_USER_IPCAM_SET_IMAGE_PARAM_RESP*/
typedef struct
{
    unsigned int  result;	// 0: success; otherwise: failed.
    unsigned char reserved[8];
}SMsgAVIoctrlSetImageParamResp;

//重启

/* IOTYPE_USER_IPCAM_SETREBOOT_REQ  */
typedef struct
{
    unsigned int  result;	// 0: success; otherwise: failed.
    unsigned char reserved[8];
}SMsgAVIoctrlSetRebootResp;

/*  IOTYPE_USER_IPCAM_SETREBOOT_RESP */
typedef struct
{
    unsigned char reserved[8];
}SMsgAVIoctrlSetRebootReq;


//FTP

typedef struct
{
    unsigned int channel;       // Camera Index
    unsigned char ftpServer[68] ; // 10.1.1.1
    int ftpPort;                   // 21
    unsigned char userName[20];
    unsigned char password[20];
    unsigned char path[256];
    int  passiveMode;// 0 - off, 1 - on
}SMsgAVIoctrlSetFtpReq, SMsgAVIoctrlGetFtpResp;

typedef struct
{
    unsigned int channel; 		// Camera Index
    int result; //0: ok ; 1: failed
    unsigned char reserved[4];
}SMsgAVIoctrlSetFtpResp;

typedef struct
{
    unsigned int channel; 		// Camera Index
    unsigned char reserved[4];
}SMsgAVIoctrlGetFtpReq;


//报警

/* IOTYPE_USER_IPCAM_GETGUARD_REQ				= 0x420
 */
typedef struct
{
    unsigned int channel;       // AvServer Index
    unsigned char reserved[4];
} SMsgAVIoctrlGetGuardReqEn;

/* IOTYPE_USER_IPCAM_GETGUARD_RESP				= 0x421
 * IOTYPE_USER_IPCAM_SETGUARD_REQ				= 0x422
 */
typedef struct
{
    unsigned int channel;       // AvServer Index
    unsigned char alarm_motion_armed;        // 移动侦测开关	ON=1, OFF=0
    unsigned char alarm_motion_sensitivity; // 1(MIN) ~ 100(MAX)   参考TUTK的SMsgAVIoctrlSetMotionDetectReq的sensitivity 值定义做。
    unsigned char alarm_preset;  /*报警联动预置位 0：关闭，1～4：选择联动预值位*/
    unsigned char alarm_mail;   /*报警时邮件通知 0：禁止；1：允许                   */
    unsigned int   alarm_ftp; /*ftp 报警图片上传 0：禁止；1：允许*/
} SMsgAVIoctrlGetGuardRespEn, SMsgAVIoctrlSetGuardReqEn;

/* IOTYPE_USER_IPCAM_SETGUARD_RESP				= 0x423
 */
typedef struct
{
    int result;	// 回傳值	0: success; otherwise: failed.
    unsigned char reserved[4];
    
} SMsgAVIoctrlSetGuardRespEn;

//录像扩展设置 ①录像参数设置 上面已有

//②录像、抓拍计划设置
/* IOTYPE_USER_IPCAM_GET_SCHEDULE_REQ			= 0x2219,   */
typedef enum
{
    AVIOTC_SCHEDULETYPE_ALARM		= 0x00,
    AVIOTC_SCHEDULETYPE_PLAN		= 0x01,
    AVIOTC_SCHEDULETYPE_SNAP		= 0x02,
    AVIOTC_SCHEDULETYPE_BUTT
}ENUM_SCHEDULE_TYPE;

typedef struct
{
    unsigned int  u32Type; //refer to ENUM_SCHEDULE_TYPE
    unsigned char reserved[8];
}SMsgAVIoctrlGetScheduleReq;

/* IOTYPE_USER_IPCAM_GET_SCHEDULE_RESP		= 0x221A,   */
/* IOTYPE_USER_IPCAM_SET_SCHEDULE_REQ			= 0x221B,   */
typedef struct
{
    unsigned int  u32ScheduleType;		//refer to ENUM_SCHEDULE_TYPE
    char          sDayData[7][48+1];	//P:yes, N:no
    unsigned char reserved1[1];
    unsigned char reserved2[8];
} SMsgAVIoctrlGetScheduleResp, SMsgAVIoctrlSetScheduleReq;


/* IOTYPE_USER_IPCAM_SET_SCHEDULE_RESP		= 0x221C,   */
typedef struct
{
    unsigned int  result;	// 0: success; otherwise: failed.
    unsigned char reserved[8];
}SMsgAVIoctrlSetScheduleResp;


#endif
