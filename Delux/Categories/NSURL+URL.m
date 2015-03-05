//
//  NSURL+URL.m
//
//  Created by Darktt on 13/8/12.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "NSURL+URL.h"

@implementation NSURL (URL)

+ (id)URLWithString:(NSString *)string useEncoding:(NSStringEncoding)encode;
{
    NSString *encodeString = [string stringByAddingPercentEscapesUsingEncoding:encode];
    
    NSURL *encodeURL = [NSURL URLWithString:encodeString];
    
    return encodeURL;
}

- (id)initWithString:(NSString *)URLString useEncoding:(NSStringEncoding)encode
{
    NSString *encodeString = [URLString stringByAddingPercentEscapesUsingEncoding:encode];
    
    self = [self initWithString:encodeString];
    
    return self;
}

#pragma mark - Propery Method

- (NSURL *)rootURL
{
    NSString *currentURLString = [self description];
    NSString *rootURLString;
    
    if ([self port] == nil) {
        
        if ([currentURLString hasSuffix:@"/"]) {
            rootURLString = [NSString stringWithFormat:@"%@://%@/", [self scheme] , [self host]];
        } else {
            rootURLString = [NSString stringWithFormat:@"%@://%@", [self scheme] , [self host]];
        }
        
    } else {
        
        if ([currentURLString hasSuffix:@"/"]) {
            rootURLString = [NSString stringWithFormat:@"%@://%@:%@/", [self scheme] , [self host], [self port]];
        } else {
            rootURLString = [NSString stringWithFormat:@"%@://%@:%@", [self scheme] , [self host], [self port]];
        }
        
    }
    
    return [NSURL URLWithString:rootURLString];
}

- (BOOL)isRootURL
{
    NSString *currentURLString = [self description];
    NSString *domain = [[self rootURL] description];
    
    return ([currentURLString compare:domain] == NSOrderedSame);
}

@end
