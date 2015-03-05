//
//  NSObject+PerformBlock.h
//  DTTest
//
//  Created by Darktt on 13/11/6.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformBlock)

- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay;

@end
