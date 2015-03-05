//
//  UIDevice+Device.m
//
//  Created by Darktt on 13/7/4.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIDevice+Device.h"

@implementation UIDevice (Device)

- (NSString *)deviceModel
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return @"iPhone";
    }
    
    return @"iPad";
}

- (NSString *)currentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    
    return languages[0];
}

#pragma mark - Override Property Method

- (BOOL)isIPadDevice
{
    if ([[self deviceModel] isEqualToString:@"iPad"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isIPhoneDevice
{
    if ([[self deviceModel] isEqualToString:@"iPhone"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isJailBreaked
{
    return !system("ls");
}

@end
