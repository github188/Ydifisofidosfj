//
//  AccountInfo.h
//  P2PCamCEO
//
//  Created by fourones on 15/11/18.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountInfo : NSObject
+(void)SignIn:(NSInteger)id withIsRemember:(BOOL)isRemember;
+(NSInteger)getUserId;
+(BOOL)isLogined;
+(BOOL)isRemember;
@end