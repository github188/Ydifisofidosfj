//
//  NSArray+URLHandle.h
//
//  Created by Darktt on 13/6/5.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (URLHandle)

- (NSArray *)convertURLsToStrings;  // Convert all string to URL
- (NSArray *)convertStringsToURLs;  // Convert all URL to string

@end
