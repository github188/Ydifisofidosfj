//
//  GLogZone.h
//  
//
//  Created by Gavin Chang on 2014/5/25.
//  Copyright (c) 2014年 WarRoom. All rights reserved.
//

#ifndef _TUTK_GLog_Zone_h
#define _TUTK_GLog_Zone_h

extern unsigned long g_dwGLogZoneSeed;


#define tAll_MSK				-1
#define tUI_MSK					(1)				//trace UI flow
#define tCtrl_MSK				(1<< 1)			//trace Control
#define tMemory_MSK				(1<< 2)			//trace Memory load
#define tPushNotify_MSK			(1<< 3)			//trace TPNS
#define tAudioDecode_MSK		(1<< 4)			//trace audio decode
#define tReStartShow_MSK			(1<< 5)			//


#define tAll					(1)
#define tUI						(g_dwGLogZoneSeed & tUI_MSK)
#define tCtrl					(g_dwGLogZoneSeed & tCtrl_MSK)
#define tMemory					(g_dwGLogZoneSeed & tMemory_MSK)
#define tPushNotify				(g_dwGLogZoneSeed & tPushNotify_MSK)
#define tAudioDecode			(g_dwGLogZoneSeed & tAudioDecode_MSK)
#define tReStartShow			(g_dwGLogZoneSeed & tReStartShow_MSK)


#endif