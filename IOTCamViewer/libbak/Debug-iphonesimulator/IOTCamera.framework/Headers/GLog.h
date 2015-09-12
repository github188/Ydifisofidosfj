//
//  GLog.h
//  
//
//  Created by Gavin Chang on 2014/5/25.
//  Copyright (c) 2014年 WarRoom. All rights reserved.
//

#ifndef _TUTK_GLog_h
#define _TUTK_GLog_h

#ifdef DEBUG

	#define GLog(cond,printf_exp) ((cond)?(NSLog printf_exp),1:0)
	#define GLogREL(cond,printf_exp) ((cond)?(NSLog printf_exp),1:0)

#else

	#define GLog(cond,printf_exp)
	#define GLogREL(cond,printf_exp) ((cond)?(NSLog printf_exp),1:0)

#endif

#endif
