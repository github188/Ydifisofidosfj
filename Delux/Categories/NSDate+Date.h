//
//  NSDate+Date.h
//  DTTest
//
//  Created by Eden Li on 2013/12/23.
//  Copyright (c) 2013年 Darktt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Date)

- (NSDate *)getPastDateWithDays:(NSInteger)days;
- (NSDate *)getFutureDateWithDays:(NSInteger)days;

@end
