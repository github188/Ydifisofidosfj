//
//  AccountInfo.m
//  P2PCamCEO
//
//  Created by fourones on 15/11/18.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "AccountInfo.h"

@implementation AccountInfo
+(void)SignIn:(NSInteger)id withIsRemember:(BOOL)isRemember{
    NSUserDefaults *store=[NSUserDefaults standardUserDefaults];
    [store setInteger:id forKey:@"account.id"];
    [store setBool:YES forKey:@"account.logined"];
    [store setBool:isRemember forKey:@"account.remember"];
}
+(NSInteger)getUserId{
    NSUserDefaults *store=[NSUserDefaults standardUserDefaults];
    return [store integerForKey:@"account.id"];
}
+(BOOL)isLogined{
    NSUserDefaults *store=[NSUserDefaults standardUserDefaults];
    return [store boolForKey:@"account.logined"];
}
+(BOOL)isRemember{
    NSUserDefaults *store=[NSUserDefaults standardUserDefaults];
    return [store boolForKey:@"account.remember"];
}
@end
