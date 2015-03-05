//
//  NSURL+URL.h
//
//  Created by Darktt on 13/8/12.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (URL)

@property (nonatomic, readonly) NSURL *rootURL;
//@property (readonly, getter = isRootURL) BOOL rootURL;

+ (id)URLWithString:(NSString *)string useEncoding:(NSStringEncoding)encode;
- (id)initWithString:(NSString *)URLString useEncoding:(NSStringEncoding)encode;

- (BOOL)isRootURL;

@end
