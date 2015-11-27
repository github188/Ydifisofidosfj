//
//  AccountInfo.m
//  P2PCamCEO
//
//  Created by fourones on 15/11/18.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import "AccountInfo.h"

@implementation AccountInfo
+(void)SignIn:(NSInteger)id withUserName:(NSString *)userName withPassword:(NSString *)password withIsRemember:(BOOL)isRemember{
    NSUserDefaults *store=[NSUserDefaults standardUserDefaults];
    [store setInteger:id forKey:@"account.id"];
    [store setBool:YES forKey:@"account.logined"];
    [store setBool:isRemember forKey:@"account.remember"];
    [store setObject:userName forKey:@"account.username"];
    if(isRemember){
        [store setObject:password forKey:@"account.password"];
    }
    else{
        [store setObject:@"" forKey:@"account.password"];
    }
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
+(NSString *)getUserName{
    NSUserDefaults *store=[NSUserDefaults standardUserDefaults];
    return [store objectForKey:@"account.username"];
}
+(NSString *)getPassword{
    NSUserDefaults *store=[NSUserDefaults standardUserDefaults];
    return [store objectForKey:@"account.password"];
}
@end
