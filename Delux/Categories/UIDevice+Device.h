//
//  UIDevice+Device.h
//
//  Created by Darktt on 13/7/4.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Device)

// Check device model with boolean value
@property (readonly, getter = isIPadDevice) BOOL iPadDevice;
@property (readonly, getter = isIPhoneDevice) BOOL iPhoneDevice;

// Check device jail breaked
@property (readonly, getter = isJailBreaked) BOOL jailBreaked;

// Check device model with string value
- (NSString *)deviceModel;

// Check device current use language
- (NSString *)currentLanguage;

@end
