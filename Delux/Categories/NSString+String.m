//
//  NSString+String.m
//
//  Created by Darktt on 12/12/30.
//  Copyright (c) 2012 Darktt Personal Company. All rights reserved.
//

#import "NSString+String.h"

@implementation NSString (String)

static NSArray *base16Symbols = nil;

NSString *NSStringFromBool(BOOL boolValue)
{
    return boolValue ? @"YES" : @"NO" ;
}

+ (id)stringWithInteger:(NSInteger)integer
{
    NSString *string = [[[NSString alloc] initWithInteger:integer] autorelease];
    
    return string;
}

+ (id)stringWithFloat:(float)f numberOfDecimalPlaces:(NSUInteger)dP
{
    NSString *string = [[[NSString alloc] initWithFloat:f numberOfDecimalPlaces:dP] autorelease];
    
    return string;
}

+ (id)localizedStringWithFormat:(NSString *)format, ...
{
    va_list arg;
    va_start(arg, format);
    
    NSString *localizedString = [[[NSString alloc] initWithFormat:NSLocalizedString(format, @"") arguments:arg] autorelease];
    
    va_end(arg);
    
    return localizedString;
}

- (id)initWithInteger:(NSInteger)integer
{
    self = [self initWithFormat:@"%d", integer];
    
    return self;
}

- (id)initWithFloat:(float)f numberOfDecimalPlaces:(NSUInteger)dP
{
    self = [self initWithFormat:@"%f", f];
    
    return self;
}

- (id)initLocalizedStringWithFormat:(NSString *)format, ...
{
    va_list arg;
    va_start(arg, format);
    
    self = [self initWithFormat:NSLocalizedString(format, @"") arguments:arg];
    
    va_end(arg);
    
    return self;
}

#pragma mark - Lowercase Pathextension

- (NSString *)lowercasePathExtension
{
    NSString *pathExtension = [[self pathExtension] lowercaseString];
    NSString *mainFileName = [self stringByDeletingPathExtension];
    
    return [mainFileName stringByAppendingPathExtension:pathExtension];
}

#pragma mark - Trimming String

- (NSString *)stringByTrimmingWithFromString:(NSString *)fromString toString:(NSString *)toString
{
    // Trimming fromString
    NSRange trimmingRange = [self rangeOfString:fromString];
    
    // If current string not correspond by fromString, return nil.
    if (trimmingRange.location == NSNotFound) {
        return nil;
    }
    
    NSString *trimmedString = [self substringFromIndex:trimmingRange.location + trimmingRange.length];
    
    // Trimming toString
    trimmingRange = [trimmedString rangeOfString:toString];
    
    // If current string not correspond by toString, return nil.
    if (trimmingRange.location == NSNotFound) {
        return nil;
    }
    
    trimmedString = [trimmedString substringToIndex:trimmingRange.location];
    
    return trimmedString;
}

#pragma mark - Hex String to Integer Methods

- (void)setBase16Symbols
{
    if (base16Symbols == nil) {
        base16Symbols = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D", @"E", @"F"];
    }
}

- (NSInteger)base16ToIntegerWithString:(NSString *)string
{
    [self setBase16Symbols];
    
    return [base16Symbols indexOfObject:string];
}

- (long long)hexLongLongValue
{
    long long integer = 0.0f;
    
    for (NSInteger i = (self.length - 1); i >= 0; i--) {
        NSInteger j = self.length - i - 1;
        
        NSRange range = {i , 1};
        NSString *string = [self substringWithRange:range];
        
        double digit = [self base16ToIntegerWithString:[string uppercaseString]] * pow(16, j);

        integer += digit;
    }
    
    return integer;
}

- (NSInteger)hexIntegerValue
{
    NSNumber *hexNumber = [NSNumber numberWithLongLong:[self hexLongLongValue]];
    
    return [hexNumber integerValue];
}

#pragma mark - Override Property Method

- (BOOL)isEmailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

@end
