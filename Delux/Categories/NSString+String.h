//
//  NSString+String.h
//
//  Created by Darktt on 12/12/30.
//  Copyright (c) 2012 Darktt Personal Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (String)

@property (readonly, getter = isEmailAddress) BOOL emailAddress;

UIKIT_EXTERN NSString *NSStringFromBool(BOOL boolValue);

+ (id)stringWithInteger:(NSInteger)integer;
+ (id)stringWithFloat:(float)f numberOfDecimalPlaces:(NSUInteger)dP;
+ (id)localizedStringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

- (id)initWithInteger:(NSInteger)integer;
- (id)initWithFloat:(float)f numberOfDecimalPlaces:(NSUInteger)dP;
- (id)initLocalizedStringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

- (NSString *)lowercasePathExtension;
- (NSString *)stringByTrimmingWithFromString:(NSString *)fromString toString:(NSString *)toString;

- (long long)hexLongLongValue;
- (NSInteger)hexIntegerValue;

@end
