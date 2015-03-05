//
//  NSArray+URLHandle.m
//
//  Created by Darktt on 13/6/5.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "NSArray+URLHandle.h"

@implementation NSArray (URLHandle)

- (NSArray *)convertURLsToStrings
{
    NSMutableArray *convertArray = [NSMutableArray array];
    
    for (id object in self) {
        if ([object isKindOfClass:[NSURL class]]) {
            NSString *strObject = [object absoluteString];
            [convertArray addObject:strObject];
        } else {
            [convertArray addObject:object];
        }
    }
    
    return convertArray;
    
}

- (NSArray *)convertStringsToURLs
{
    NSMutableArray *convertArray = [NSMutableArray array];
    
    for (id object in self) {
        if ([object isKindOfClass:[NSString class]]) {
            NSURL *urlObject = [NSURL URLWithString:object];
            [convertArray addObject:urlObject];
        } else {
            [convertArray addObject:object];
        }
    }
    
    return convertArray;
}

@end
